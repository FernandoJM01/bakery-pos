import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/till_auth_service.dart';
import '../../printing/data/printer_service.dart';
import '../../printing/domain/documents.dart';
import '../../printing/domain/escpos.dart';
import '../../sale/data/sale_repository.dart';
import '../../sale/domain/ticket.dart';
import '../../sale/presentation/payment_dialog.dart';
import '../data/oven_repository.dart';
import '../domain/oven_fee.dart';

final ovenRulesProvider = FutureProvider<List<LocalOvenRule>>(
  (ref) => ref.watch(ovenRepositoryProvider).rules(),
);

final ovenEnabledProvider = FutureProvider<bool>(
  (ref) => ref.watch(ovenRepositoryProvider).enabled(),
);

String _hm(DateTime d) {
  final t = d.toLocal();
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

String _kg(int grams) =>
    (grams / 1000).toStringAsFixed(grams % 100 == 0 ? 1 : 2);

/// The slip with the tag number the customer keeps (M8.1).
List<PrintLine> ovenClaimDocument(
  AppLocalizations l10n,
  OvenDish d,
  String ruleName,
  String? branch,
) => [
  if (branch != null) PrintLine(branch, bold: true, center: true),
  PrintLine(l10n.ovenClaimTitle, bold: true, center: true),
  PrintLine(l10n.ovenTag(d.tag), bold: true, center: true, large: true),
  const PrintLine.rule(),
  PrintLine(d.customerName, bold: true),
  if (d.phone != null) PrintLine(d.phone!),
  PrintLine(d.description),
  PrintLine(l10n.ovenDishWeight(ruleName, _kg(d.weightGrams))),
  PrintLine(l10n.ovenRequested(formatPrintDate(d.requestedAt))),
  if (d.readyAt != null) PrintLine(l10n.ovenReadyAt(_hm(d.readyAt!))),
  const PrintLine.rule(),
  PrintLine(
    d.paid ? l10n.ovenFeePaid : l10n.ovenFeeDue,
    right: formatCents(d.feeCents),
    bold: true,
  ),
];

/// Horno on the till (M8): drop-off and pickup at the counter, and the board
/// for the bakers. Each part shows only with its permission.
class OvenScreen extends ConsumerWidget {
  const OvenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(tillSessionProvider);
    final enabled = ref.watch(ovenEnabledProvider).value ?? false;
    if (!enabled) {
      return Center(child: Text(l10n.ovenOff, key: const Key('oven-off')));
    }
    final counter = session?.hasPermission('oven.intake_pickup') == true;
    final board = session?.hasPermission('oven.board') == true;
    if (counter && board) {
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(key: const Key('tab-counter'), text: l10n.ovenCounter),
                Tab(key: const Key('tab-board'), text: l10n.ovenBoard),
              ],
            ),
            const Expanded(child: TabBarView(children: [_Counter(), _Board()])),
          ],
        ),
      );
    }
    return board && !counter ? const _Board() : const _Counter();
  }
}

class _Counter extends ConsumerWidget {
  const _Counter();

  Future<void> _print(
    WidgetRef ref,
    AppLocalizations l10n,
    OvenDish d,
    List<LocalOvenRule> rules,
  ) async {
    final name = rules.where((r) => r.id == d.ruleId).firstOrNull?.name ?? '';
    await ref
        .read(printerServiceProvider)
        .print(
          ovenClaimDocument(
            l10n,
            d,
            name,
            ref.read(enrolledBranchNameProvider).value,
          ),
        );
  }

  /// Takes the fee as a sale; null when the cashier closes the dialog.
  static Future<String?> payFee(
    BuildContext context,
    WidgetRef ref,
    LocalOvenRule rule,
    int feeCents,
  ) async {
    final session = ref.read(tillSessionProvider);
    if (session == null) return null;
    final receipt = await showDialog<SaleReceipt>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentDialog(
        totalCents: feeCents,
        onFinish: (tendered) => ref
            .read(ovenRepositoryProvider)
            .payFee(
              rule: rule,
              feeCents: feeCents,
              cashier: session.staff,
              tenderedCents: tendered,
              now: ref.read(saleClockProvider)(),
            ),
      ),
    );
    if (receipt == null) return null;
    await ref.read(printerServiceProvider).kickDrawer();
    return receipt.saleId;
  }

  Future<void> _pickUp(
    BuildContext context,
    WidgetRef ref,
    OvenDish d,
    List<LocalOvenRule> rules,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final session = ref.read(tillSessionProvider);
    if (session == null) return;
    String? saleId;
    if (!d.paid) {
      final rule = rules.where((r) => r.id == d.ruleId).firstOrNull;
      if (rule == null) return;
      try {
        saleId = await payFee(context, ref, rule, d.feeCents);
      } on NoOpenShiftException {
        messenger.showSnackBar(SnackBar(content: Text(l10n.saleNoShift)));
        return;
      }
      if (saleId == null) return;
    }
    await ref
        .read(ovenRepositoryProvider)
        .pickUp(
          d.id,
          session.staff.id,
          ref.read(saleClockProvider)(),
          feeSaleId: saleId,
        );
    ref.invalidate(ovenDishesProvider);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.ovenPickedUp(d.tag, d.customerName))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dishes = ref.watch(ovenDishesProvider).value ?? const <OvenDish>[];
    final rules = ref.watch(ovenRulesProvider).value ?? const <LocalOvenRule>[];
    final ready = [
      for (final d in dishes)
        if (d.status == 'READY') d,
    ];
    final waiting = [
      for (final d in dishes)
        if (d.status == 'RECEIVED' || d.status == 'IN_OVEN') d,
    ];
    return ListView(
      key: const Key('oven-counter'),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const Key('oven-new'),
            icon: const Icon(Icons.add),
            label: Text(l10n.ovenNewDish),
            onPressed: rules.isEmpty
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final d = await showDialog<OvenDish>(
                      context: context,
                      builder: (_) => _IntakeDialog(rules: rules),
                    );
                    if (d == null) return;
                    ref.invalidate(ovenDishesProvider);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.ovenReceivedTag(d.tag, d.customerName),
                        ),
                      ),
                    );
                    await _print(ref, l10n, d, rules);
                  },
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Text(l10n.ovenReadyToCall, style: theme.textTheme.titleMedium),
        if (ready.isEmpty) Text(l10n.ovenNoneReady),
        for (final d in ready)
          Card(
            key: Key('ready-${d.id}'),
            child: ListTile(
              leading: CircleAvatar(child: Text(d.tag)),
              title: Text(d.customerName),
              subtitle: Text(
                l10n.ovenReadyLine(
                  d.description,
                  _hm(d.readyAt ?? d.requestedAt),
                  d.phone ?? '',
                ),
              ),
              isThreeLine: true,
              trailing: FilledButton(
                key: Key('pickup-${d.id}'),
                onPressed: () => _pickUp(context, ref, d, rules),
                child: Text(
                  d.paid
                      ? l10n.ovenHandOver
                      : l10n.ovenChargeAndHandOver(formatCents(d.feeCents)),
                ),
              ),
            ),
          ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Text(l10n.ovenWaiting, style: theme.textTheme.titleMedium),
        for (final d in waiting)
          ListTile(
            key: Key('waiting-${d.id}'),
            leading: CircleAvatar(child: Text(d.tag)),
            title: Text(d.customerName),
            subtitle: Text(l10n.ovenRequested(formatPrintDate(d.requestedAt))),
            trailing: Text(
              d.status == 'IN_OVEN' ? l10n.ovenInOven : l10n.ovenReceived,
            ),
            onTap: () => _print(ref, l10n, d, rules),
          ),
      ],
    );
  }
}

class _IntakeDialog extends ConsumerStatefulWidget {
  const _IntakeDialog({required this.rules});

  final List<LocalOvenRule> rules;

  @override
  ConsumerState<_IntakeDialog> createState() => _IntakeDialogState();
}

class _IntakeDialogState extends ConsumerState<_IntakeDialog> {
  final _tag = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  final _kg = TextEditingController();
  late LocalOvenRule _rule = widget.rules.first;
  TimeOfDay _time = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 3)),
  );
  bool _payNow = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_tag, _name, _phone, _description, _kg]) {
      c.dispose();
    }
    super.dispose();
  }

  int? get _grams {
    final v = double.tryParse(_kg.text.replaceAll(',', '.'));
    if (v == null || v <= 0) return null;
    final g = (v * 1000).round();
    return g < 1 || g > ovenMaxGrams ? null : g;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final grams = _grams;
    final session = ref.read(tillSessionProvider);
    if (session == null ||
        grams == null ||
        _tag.text.trim().isEmpty ||
        _name.text.trim().isEmpty ||
        _description.text.trim().isEmpty) {
      setState(() => _error = l10n.ovenIncomplete);
      return;
    }
    if (cleanOvenPhone(_phone.text) == '') {
      setState(() => _error = l10n.ovenBadPhone);
      return;
    }
    final now = ref.read(saleClockProvider)();
    final fee = ovenFee(_rule.baseCents, _rule.perKgCents, grams);
    String? saleId;
    if (_payNow) {
      try {
        saleId = await _Counter.payFee(context, ref, _rule, fee);
      } on NoOpenShiftException {
        setState(() => _error = l10n.saleNoShift);
        return;
      }
      if (saleId == null) return;
    }
    final today = DateTime(
      now.year,
      now.month,
      now.day,
      _time.hour,
      _time.minute,
    );
    final requested = today.isBefore(now)
        ? today.add(const Duration(days: 1))
        : today;
    final id = await ref
        .read(ovenRepositoryProvider)
        .receive(
          tag: _tag.text,
          customerName: _name.text,
          phone: _phone.text,
          description: _description.text,
          rule: _rule,
          weightGrams: grams,
          requestedAt: requested,
          staffId: session.staff.id,
          feeSaleId: saleId,
          now: now,
        );
    if (!mounted) return;
    Navigator.of(context).pop(
      OvenDish(
        id: id,
        tag: _tag.text.trim(),
        customerName: _name.text.trim(),
        phone: cleanOvenPhone(_phone.text),
        description: _description.text.trim(),
        ruleId: _rule.id,
        weightGrams: grams,
        feeCents: fee,
        requestedAt: requested,
        status: 'RECEIVED',
        readyAt: null,
        paid: saleId != null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final grams = _grams;
    final fee = grams == null
        ? null
        : ovenFee(_rule.baseCents, _rule.perKgCents, grams);
    return AlertDialog(
      title: Text(l10n.ovenNewDish),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('oven-tag'),
                controller: _tag,
                autofocus: true,
                maxLength: 10,
                decoration: InputDecoration(labelText: l10n.ovenTagLabel),
              ),
              TextField(
                key: const Key('oven-name'),
                controller: _name,
                maxLength: 120,
                decoration: InputDecoration(labelText: l10n.ordersCustomerName),
              ),
              TextField(
                key: const Key('oven-phone'),
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.ordersCustomerPhone,
                ),
              ),
              TextField(
                key: const Key('oven-description'),
                controller: _description,
                maxLength: 200,
                decoration: InputDecoration(labelText: l10n.ovenDescription),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Wrap(
                spacing: AppDimensions.paddingSmall,
                children: [
                  for (final r in widget.rules)
                    ChoiceChip(
                      key: Key('oven-rule-${r.id}'),
                      label: Text(r.name),
                      selected: _rule.id == r.id,
                      onSelected: (_) => setState(() => _rule = r),
                    ),
                ],
              ),
              TextField(
                key: const Key('oven-kg'),
                controller: _kg,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(labelText: l10n.ovenWeightKg),
                onChanged: (_) => setState(() {}),
              ),
              ListTile(
                key: const Key('oven-time'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.ovenRequestedAt(_time.format(context))),
                trailing: const Icon(Icons.schedule),
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (t != null) setState(() => _time = t);
                },
              ),
              if (fee != null)
                Text(
                  l10n.ovenFeeLine(
                    formatCents(_rule.baseCents),
                    formatCents(_rule.perKgCents),
                    formatCents(fee),
                  ),
                  key: const Key('oven-fee'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              SwitchListTile(
                key: const Key('oven-pay-now'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.ovenPayNow),
                value: _payNow,
                onChanged: (v) => setState(() => _payNow = v),
              ),
              if (_error != null)
                Text(
                  _error!,
                  key: const Key('oven-error'),
                  style: const TextStyle(color: AppColors.alertRed),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('oven-save'),
          onPressed: _save,
          child: Text(l10n.ovenSave),
        ),
      ],
    );
  }
}

/// The bakers' queue by requested time (M8.2).
class _Board extends ConsumerWidget {
  const _Board();

  Future<void> _step(WidgetRef ref, OvenDish d, String status) async {
    final staff = ref.read(tillSessionProvider)?.staff;
    if (staff == null) return;
    await ref
        .read(ovenRepositoryProvider)
        .mark(d.id, status, staff.id, ref.read(saleClockProvider)());
    ref.invalidate(ovenDishesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dishes = ref.watch(ovenDishesProvider).value ?? const <OvenDish>[];
    final queue = [
      for (final d in dishes)
        if (d.status == 'RECEIVED' || d.status == 'IN_OVEN') d,
    ];
    if (queue.isEmpty) {
      return Center(child: Text(l10n.ovenQueueEmpty));
    }
    return ListView(
      key: const Key('oven-board'),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      children: [
        for (final d in queue)
          Card(
            key: Key('board-${d.id}'),
            color: d.status == 'IN_OVEN' ? AppColors.amberGlow : null,
            child: ListTile(
              leading: CircleAvatar(child: Text(d.tag)),
              title: Text(d.description),
              subtitle: Text(
                l10n.ovenBoardLine(
                  d.customerName,
                  _kg(d.weightGrams),
                  _hm(d.requestedAt),
                ),
              ),
              trailing: d.status == 'RECEIVED'
                  ? FilledButton(
                      key: Key('in-oven-${d.id}'),
                      onPressed: () => _step(ref, d, 'IN_OVEN'),
                      child: Text(l10n.ovenToOven),
                    )
                  : FilledButton(
                      key: Key('ready-btn-${d.id}'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                      ),
                      onPressed: () => _step(ref, d, 'READY'),
                      child: Text(l10n.ovenMarkReady),
                    ),
            ),
          ),
      ],
    );
  }
}
