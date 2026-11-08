import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/generated/models/customer.dart';
import 'package:bakery_pos/core/api/generated/models/customer_create.dart';
import 'package:bakery_pos/core/api/generated/models/customer_detail.dart';
import 'package:bakery_pos/core/api/generated/models/customer_order.dart';
import 'package:bakery_pos/core/api/generated/models/missed_rule.dart';
import 'package:bakery_pos/core/api/generated/models/order_create.dart';
import 'package:bakery_pos/core/api/generated/models/order_kind.dart';
import 'package:bakery_pos/core/api/generated/models/order_line_input.dart';
import 'package:bakery_pos/core/api/generated/models/order_status.dart';
import 'package:bakery_pos/core/api/generated/models/prepaid_kind.dart';
import 'package:bakery_pos/core/api/generated/models/v1_orders_order_id_pause_request_body.dart';
import 'package:bakery_pos/core/api/generated/models/v1_orders_order_id_skips_request_body.dart';
import 'package:bakery_pos/core/api/generated/models/variant_cost.dart';
import 'package:bakery_pos/core/money/money.dart';
import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/features/branches/data/branches_service.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _day(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// `L M M J V` from the Monday = 1 bit set.
String weekdayLetters(AppLocalizations l10n, int bits) {
  final letters = l10n.ordersWeekdayLetters.split(',');
  return [
    for (var i = 0; i < 7; i++)
      if (bits & (1 << i) != 0) letters[i],
  ].join(' ');
}

String orderSchedule(AppLocalizations l10n, CustomerOrder o) {
  if (o.kind == OrderKind.oneOff) {
    return l10n.ordersOneOffOn(o.startDate, o.pickupTime);
  }
  return l10n.ordersStandingOn(weekdayLetters(l10n, o.weekdays), o.pickupTime);
}

String orderStatusLabel(AppLocalizations l10n, CustomerOrder o) =>
    switch (o.status) {
      OrderStatus.paused => l10n.ordersPaused,
      OrderStatus.ended => l10n.ordersEnded,
      _ => l10n.ordersActive,
    };

String prepaidKindLabel(AppLocalizations l10n, PrepaidKind k) => switch (k) {
  PrepaidKind.payment => l10n.ordersEntryPayment,
  PrepaidKind.pickup => l10n.ordersEntryPickup,
  PrepaidKind.missed => l10n.ordersEntryMissed,
  _ => l10n.ordersEntryAdjustment,
};

/// Back office Pedidos (M6 brief 5): customers with their balance, their
/// standing orders and pre-orders, and what can change on them.
class OrdersAdminScreen extends ConsumerStatefulWidget {
  const OrdersAdminScreen({super.key});

  @override
  ConsumerState<OrdersAdminScreen> createState() => _OrdersAdminScreenState();
}

class _OrdersAdminScreenState extends ConsumerState<OrdersAdminScreen> {
  final _q = TextEditingController();
  late Future<List<Customer>> _customers = _load();

  Future<List<Customer>> _load() async =>
      (await ref
              .read(restClientProvider)
              .orders
              .listCustomers(q: _q.text.trim().isEmpty ? null : _q.text.trim()))
          .items;

  void _reload() => setState(() {
    _customers = _load();
  });

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _newCustomer() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const _CustomerDialog(),
    );
    if (created == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navOrders),
        actions: [
          TextButton.icon(
            key: const Key('customer-new'),
            icon: const Icon(Icons.person_add_alt),
            label: Text(l10n.ordersNewCustomer),
            onPressed: _newCustomer,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: TextField(
              key: const Key('customers-search'),
              controller: _q,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _reload(),
              decoration: InputDecoration(
                labelText: l10n.ordersSearchCustomer,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _reload,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Customer>>(
              future: _customers,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: AdminErrorBanner(
                      message: commonAdminError(l10n, snap.error!),
                    ),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final rows = snap.data!;
                if (rows.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.ordersNoCustomers,
                      key: const Key('customers-empty'),
                    ),
                  );
                }
                return ListView(
                  key: const Key('customers-list'),
                  children: [
                    for (final c in rows)
                      ListTile(
                        key: Key('customer-${c.id}'),
                        title: Text(c.name),
                        subtitle: Text(c.phone ?? ''),
                        trailing: Text(
                          formatCents(c.balanceCents),
                          style: TextStyle(
                            color: c.balanceCents < 0
                                ? AppColors.alertRed
                                : null,
                          ),
                        ),
                        onTap: () async {
                          await showDialog<void>(
                            context: context,
                            builder: (_) => CustomerDialog(customerId: c.id),
                          );
                          _reload();
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerDialog extends ConsumerStatefulWidget {
  const _CustomerDialog();

  @override
  ConsumerState<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends ConsumerState<_CustomerDialog> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.ordersNameRequired);
      return;
    }
    try {
      await ref
          .read(restClientProvider)
          .orders
          .createCustomer(
            body: CustomerCreate(
              name: _name.text.trim(),
              phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            ),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = apiErrorCode(e) == 'CONFLICT'
              ? l10n.ordersPhoneInUse
              : commonAdminError(l10n, e),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.ordersNewCustomer),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('customer-name'),
              controller: _name,
              decoration: InputDecoration(labelText: l10n.ordersCustomerName),
            ),
            TextField(
              key: const Key('customer-phone'),
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.ordersCustomerPhone),
            ),
            if (_error != null)
              Text(
                _error!,
                key: const Key('customer-error'),
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
          key: const Key('customer-save'),
          onPressed: _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

/// A customer: balance, history and orders, with what can change on each.
class CustomerDialog extends ConsumerStatefulWidget {
  const CustomerDialog({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<CustomerDialog> createState() => _CustomerDetailState();
}

class _CustomerDetailState extends ConsumerState<CustomerDialog> {
  late Future<CustomerDetail> _detail = _load();

  Future<CustomerDetail> _load() => ref
      .read(restClientProvider)
      .orders
      .getCustomer(customerId: widget.customerId);

  void _reload() => setState(() {
    _detail = _load();
  });

  Future<void> _act(Future<Object?> Function() call) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await call();
      _reload();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(commonAdminError(l10n, e))),
      );
    }
  }

  Future<String?> _pickDay() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    return d == null ? null : _day(d);
  }

  Widget _orderTile(CustomerOrder o) {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(restClientProvider).orders;
    final ended = o.status == OrderStatus.ended;
    return Card(
      key: Key('order-${o.id}'),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.ordersScheduleStatus(
                orderSchedule(l10n, o),
                orderStatusLabel(l10n, o),
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (final l in o.lines)
              Text(l10n.ordersLine(l.productName, l.quantity)),
            if (!ended)
              Wrap(
                spacing: AppDimensions.paddingSmall,
                children: [
                  TextButton(
                    key: Key('order-skip-${o.id}'),
                    onPressed: () async {
                      final day = await _pickDay();
                      if (day == null) return;
                      await _act(
                        () => api.skipOrderDate(
                          orderId: o.id,
                          body: V1OrdersOrderIdSkipsRequestBody(date: day),
                        ),
                      );
                    },
                    child: Text(l10n.ordersSkipDay),
                  ),
                  if (o.status == OrderStatus.paused)
                    TextButton(
                      key: Key('order-resume-${o.id}'),
                      onPressed: () =>
                          _act(() => api.resumeOrder(orderId: o.id)),
                      child: Text(l10n.ordersResume),
                    )
                  else
                    TextButton(
                      key: Key('order-pause-${o.id}'),
                      onPressed: () async {
                        final day = await _pickDay();
                        if (day == null) return;
                        await _act(
                          () => api.pauseOrder(
                            orderId: o.id,
                            body: V1OrdersOrderIdPauseRequestBody(from: day),
                          ),
                        );
                      },
                      child: Text(l10n.ordersPause),
                    ),
                  TextButton(
                    key: Key('order-end-${o.id}'),
                    onPressed: () => _act(() => api.endOrder(orderId: o.id)),
                    child: Text(l10n.ordersEnd),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      content: SizedBox(
        width: 560,
        height: 560,
        child: FutureBuilder<CustomerDetail>(
          future: _detail,
          builder: (context, snap) {
            if (snap.hasError) {
              return AdminErrorBanner(
                message: commonAdminError(l10n, snap.error!),
              );
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final c = snap.data!;
            return ListView(
              key: const Key('customer-detail'),
              children: [
                Text(c.name, style: Theme.of(context).textTheme.titleLarge),
                Text(
                  l10n.ordersBalance(formatCents(c.balanceCents)),
                  key: const Key('customer-balance'),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.ordersOrders,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    FilledButton.icon(
                      key: const Key('order-new'),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.ordersNewOrder),
                      onPressed: () async {
                        final saved = await showDialog<bool>(
                          context: context,
                          builder: (_) => OrderFormDialog(customerId: c.id),
                        );
                        if (saved == true) _reload();
                      },
                    ),
                  ],
                ),
                for (final o in c.orders) _orderTile(o),
                const SizedBox(height: AppDimensions.paddingMedium),
                Text(
                  l10n.ordersHistory,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final e in c.entries)
                  ListTile(
                    dense: true,
                    title: Text(prepaidKindLabel(l10n, e.kind)),
                    subtitle: Text(formatAdminDateTime(e.occurredAt)),
                    trailing: Text(formatCents(e.amountCents)),
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          key: const Key('customer-close'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}

/// New standing order or pre-order (M6 brief 4.2).
class OrderFormDialog extends ConsumerStatefulWidget {
  const OrderFormDialog({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<OrderFormDialog> createState() => _OrderFormState();
}

class _OrderFormState extends ConsumerState<OrderFormDialog> {
  OrderKind _kind = OrderKind.standing;
  int _weekdays = 31;
  late String _start = _day(DateTime.now());
  final _time = TextEditingController(text: '07:30');
  bool _charge = true;
  String? _branchId;
  final _quantities = <String, TextEditingController>{};
  late final Future<List<VariantCost>> _variants = ref
      .read(restClientProvider)
      .catalog
      .listCosts()
      .then((r) => r.items);
  String? _error;

  @override
  void dispose() {
    _time.dispose();
    for (final c in _quantities.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final branches = ref.read(branchesServiceProvider).value ?? const [];
    final branchId = _branchId ?? branches.firstOrNull?.id;
    final lines = [
      for (final e in _quantities.entries)
        if ((int.tryParse(e.value.text) ?? 0) > 0)
          OrderLineInput(variantId: e.key, quantity: int.parse(e.value.text)),
    ];
    final time = _time.text.trim();
    if (branchId == null ||
        lines.isEmpty ||
        !RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(time) ||
        (_kind == OrderKind.standing && _weekdays == 0)) {
      setState(() => _error = l10n.ordersFormIncomplete);
      return;
    }
    try {
      await ref
          .read(restClientProvider)
          .orders
          .createOrder(
            body: OrderCreate(
              customerId: widget.customerId,
              branchId: branchId,
              kind: _kind,
              weekdays: _kind == OrderKind.standing ? _weekdays : 0,
              startDate: _start,
              pickupTime: time,
              missedRule: _charge ? MissedRule.charge : MissedRule.noCharge,
              lines: lines,
            ),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _error = commonAdminError(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final letters = l10n.ordersWeekdayLetters.split(',');
    final branches = ref.watch(branchesServiceProvider).value ?? const [];
    return AlertDialog(
      title: Text(l10n.ordersNewOrder),
      content: SizedBox(
        width: 520,
        height: 520,
        child: ListView(
          children: [
            SegmentedButton<OrderKind>(
              key: const Key('order-kind'),
              segments: [
                ButtonSegment(
                  value: OrderKind.standing,
                  label: Text(l10n.ordersStanding),
                ),
                ButtonSegment(
                  value: OrderKind.oneOff,
                  label: Text(l10n.ordersOneOff),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            if (branches.length > 1)
              DropdownButtonFormField<String>(
                key: const Key('order-branch'),
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.staffBranch),
                items: [
                  for (final b in branches)
                    DropdownMenuItem(value: b.id, child: Text(b.name)),
                ],
                onChanged: (v) => setState(() => _branchId = v),
              ),
            if (_kind == OrderKind.standing) ...[
              const SizedBox(height: AppDimensions.paddingSmall),
              Wrap(
                spacing: AppDimensions.paddingSmall,
                children: [
                  for (var i = 0; i < 7; i++)
                    FilterChip(
                      key: Key('weekday-$i'),
                      label: Text(letters[i]),
                      selected: _weekdays & (1 << i) != 0,
                      onSelected: (on) => setState(
                        () => _weekdays = on
                            ? _weekdays | (1 << i)
                            : _weekdays & ~(1 << i),
                      ),
                    ),
                ],
              ),
            ],
            ListTile(
              key: const Key('order-date'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                _kind == OrderKind.standing
                    ? l10n.ordersStartsOn(_start)
                    : l10n.ordersDate(_start),
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final now = DateTime.now();
                final d = await showDatePicker(
                  context: context,
                  firstDate: now,
                  lastDate: DateTime(now.year + 1),
                );
                if (d != null) setState(() => _start = _day(d));
              },
            ),
            TextField(
              key: const Key('order-time'),
              controller: _time,
              decoration: InputDecoration(labelText: l10n.ordersPickupTime),
            ),
            SwitchListTile(
              key: const Key('order-charge'),
              contentPadding: EdgeInsets.zero,
              value: _charge,
              title: Text(l10n.ordersChargeMissed),
              onChanged: (v) => setState(() => _charge = v),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              l10n.ordersProducts,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            FutureBuilder<List<VariantCost>>(
              future: _variants,
              builder: (context, snap) => Column(
                children: [
                  for (final v in snap.data ?? const <VariantCost>[])
                    TextField(
                      key: Key('order-qty-${v.variantId}'),
                      controller: _quantities[v.variantId] ??=
                          TextEditingController(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l10n.ordersQuantityOf(
                          v.productName,
                          formatCents(v.priceCents),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_error != null)
              Text(
                _error!,
                key: const Key('order-error'),
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
          key: const Key('order-save'),
          onPressed: _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
