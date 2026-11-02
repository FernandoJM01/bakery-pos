import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/till_auth_service.dart';
import '../../sale/domain/ticket.dart';
import '../../till_catalog/data/till_catalog_repository.dart';
import '../data/stock_repository.dart';

final wasteListProvider = FutureProvider<List<WasteDue>>(
  (ref) => ref.watch(stockRepositoryProvider).wasteList(DateTime.now()),
);

const wasteReasons = ['BURNT', 'EXPIRED', 'DAMAGED', 'UNSOLD'];

String wasteReasonLabel(AppLocalizations l10n, String reason) =>
    switch (reason) {
      'BURNT' => l10n.wasteReasonBurnt,
      'EXPIRED' => l10n.wasteReasonExpired,
      'DAMAGED' => l10n.wasteReasonDamaged,
      _ => l10n.wasteReasonUnsold,
    };

/// Inventario on the till: stock by age, the waste list, waste and counts
/// (M5 brief 5). Transfers are in the back office: they need the server.
class InventoryPanel extends ConsumerWidget {
  const InventoryPanel({super.key});

  void _refresh(WidgetRef ref) {
    ref
      ..invalidate(stockViewProvider)
      ..invalidate(wasteListProvider);
  }

  Future<void> _confirm(WidgetRef ref, WasteDue w) async {
    final staff = ref.read(tillSessionProvider)?.staff;
    if (staff == null) return;
    await ref
        .read(stockRepositoryProvider)
        .waste(
          variantId: w.lot.variantId,
          quantity: w.lot.left,
          reason: 'EXPIRED',
          lotId: w.lot.id,
          staffId: staff.id,
          now: ref.read(saleClockProvider)(),
        );
    _refresh(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final session = ref.watch(tillSessionProvider);
    final stock = ref.watch(stockViewProvider).value ?? const {};
    final due = ref.watch(wasteListProvider).value ?? const <WasteDue>[];
    final catalog = ref.watch(tillCatalogProvider).value;
    final mayWaste = session?.hasPermission('stock.waste') == true;
    final mayCount = session?.hasPermission('stock.count_adjust') == true;
    return ListView(
      key: const Key('inventory-panel'),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      children: [
        Wrap(
          spacing: AppDimensions.paddingSmall,
          children: [
            if (mayWaste)
              OutlinedButton.icon(
                key: const Key('waste-open'),
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.stockRecordWaste),
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (_) => const WasteDialog(),
                  );
                  _refresh(ref);
                },
              ),
            if (mayCount)
              OutlinedButton.icon(
                key: const Key('count-open'),
                icon: const Icon(Icons.checklist),
                label: Text(l10n.stockCount),
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (_) => const StockCountDialog(),
                  );
                  _refresh(ref);
                },
              ),
          ],
        ),
        if (due.isNotEmpty && mayWaste) ...[
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(l10n.stockWasteList, style: theme.textTheme.titleMedium),
          for (final w in due)
            ListTile(
              key: Key('due-${w.lot.id}'),
              title: Text(l10n.saleLineTitle(w.productName, w.variantName)),
              subtitle: Text(l10n.stockLotLine(w.lot.producedOn, w.lot.left)),
              trailing: TextButton(
                key: Key('due-confirm-${w.lot.id}'),
                onPressed: () => _confirm(ref, w),
                child: Text(l10n.stockConfirmWaste),
              ),
            ),
        ],
        const SizedBox(height: AppDimensions.paddingMedium),
        Text(l10n.stockByAge, style: theme.textTheme.titleMedium),
        for (final p in catalog?.products ?? const <GridProduct>[])
          for (final v in p.variants)
            if (stock[v.id] != null)
              ListTile(
                key: Key('stock-${v.id}'),
                title: Text(l10n.saleLineTitle(p.name, v.name)),
                subtitle: Text(
                  l10n.stockAges(stock[v.id]!.fresh, stock[v.id]!.dayOld),
                ),
                trailing: Text(
                  stock[v.id]!.onHand.toString(),
                  style: stock[v.id]!.onHand < 0
                      ? const TextStyle(color: AppColors.alertRed)
                      : null,
                ),
              ),
      ],
    );
  }
}

class WasteDialog extends ConsumerStatefulWidget {
  const WasteDialog({super.key});

  @override
  ConsumerState<WasteDialog> createState() => _WasteDialogState();
}

class _WasteDialogState extends ConsumerState<WasteDialog> {
  final _quantity = TextEditingController();
  String? _variantId;
  String? _reason;
  String? _error;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final quantity = int.tryParse(_quantity.text) ?? 0;
    final staff = ref.read(tillSessionProvider)?.staff;
    if (_variantId == null ||
        quantity < 1 ||
        _reason == null ||
        staff == null) {
      setState(() => _error = l10n.stockWasteIncomplete);
      return;
    }
    await ref
        .read(stockRepositoryProvider)
        .waste(
          variantId: _variantId!,
          quantity: quantity,
          reason: _reason!,
          staffId: staff.id,
          now: ref.read(saleClockProvider)(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final products =
        ref.watch(tillCatalogProvider).value?.products ?? const <GridProduct>[];
    return AlertDialog(
      title: Text(l10n.stockRecordWaste),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              key: const Key('waste-variant'),
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.stockProduct),
              items: [
                for (final p in products)
                  for (final v in p.variants)
                    DropdownMenuItem(
                      value: v.id,
                      child: Text(l10n.saleLineTitle(p.name, v.name)),
                    ),
              ],
              onChanged: (v) => setState(() => _variantId = v),
            ),
            TextField(
              key: const Key('waste-quantity'),
              controller: _quantity,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: l10n.stockUnits),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Wrap(
              spacing: AppDimensions.paddingSmall,
              children: [
                for (final r in wasteReasons)
                  ChoiceChip(
                    key: Key('waste-reason-$r'),
                    label: Text(wasteReasonLabel(l10n, r)),
                    selected: _reason == r,
                    onSelected: (_) => setState(() => _reason = r),
                  ),
              ],
            ),
            if (_error != null)
              Text(
                _error!,
                key: const Key('waste-error'),
                style: const TextStyle(color: AppColors.alertRed),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('waste-save'),
          onPressed: _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

/// Counts one product or the whole shop: rows left blank are not counted.
class StockCountDialog extends ConsumerStatefulWidget {
  const StockCountDialog({super.key});

  @override
  ConsumerState<StockCountDialog> createState() => _StockCountDialogState();
}

class _StockCountDialogState extends ConsumerState<StockCountDialog> {
  final _fields = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final staff = ref.read(tillSessionProvider)?.staff;
    final counted = {
      for (final e in _fields.entries)
        if (int.tryParse(e.value.text) != null) e.key: int.parse(e.value.text),
    };
    if (staff == null || counted.isEmpty) return;
    await ref
        .read(stockRepositoryProvider)
        .count(
          counted: counted,
          staffId: staff.id,
          now: ref.read(saleClockProvider)(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final products =
        ref.watch(tillCatalogProvider).value?.products ?? const <GridProduct>[];
    return AlertDialog(
      title: Text(l10n.stockCount),
      content: SizedBox(
        width: 460,
        height: 420,
        child: ListView(
          children: [
            Text(l10n.stockCountHint),
            for (final p in products)
              for (final v in p.variants)
                TextField(
                  key: Key('count-variant-${v.id}'),
                  controller: _fields[v.id] ??= TextEditingController(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.saleLineTitle(p.name, v.name),
                  ),
                ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('count-save'),
          onPressed: _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
