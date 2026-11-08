import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/models/customer.dart';
import '../../../core/money/money.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/till_auth_service.dart';
import '../../cash/data/shift_repository.dart';
import '../../printing/data/printer_service.dart';
import '../../printing/domain/documents.dart';
import '../../sale/data/sale_repository.dart';
import '../../sale/domain/ticket.dart';
import '../../sale/presentation/receipt_dialog.dart';
import '../../stock/data/stock_repository.dart';
import '../data/orders_repository.dart';

/// Pedidos on the till (M6 brief 5): today's tickets by pickup time, one tap
/// to hand over, and prepayments. Works offline from the pulled tickets.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  Future<bool> _hasShift(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final shift = await ref.read(shiftRepositoryProvider).current();
    if (shift?.status == 'OPEN') return true;
    messenger.showSnackBar(SnackBar(content: Text(l10n.ordersNoShift)));
    return false;
  }

  Future<void> _handOver(
    BuildContext context,
    WidgetRef ref,
    TillTicket t,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final session = ref.read(tillSessionProvider);
    if (session == null || !await _hasShift(context, ref)) return;
    final SaleReceipt receipt;
    try {
      receipt =
          (await ref
                  .read(ordersRepositoryProvider)
                  .pickUp(
                    ticket: t,
                    cashier: session.staff,
                    now: ref.read(saleClockProvider)(),
                  ))
              .withBalance(t.balanceCents - t.row.totalCents);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.ordersPickupFailed)));
      return;
    }
    ref
      ..invalidate(todayTicketsProvider)
      ..invalidate(stockViewProvider);
    if (!context.mounted) return;
    final printer = ref.read(printerServiceProvider);
    final hasPrinter = await printer.config() != null;
    final doc = receiptDocument(
      l10n,
      receipt,
      ref.read(enrolledBranchNameProvider).value,
    );
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => ReceiptDialog(
        receipt: receipt,
        firstPrint: hasPrinter ? printer.print(doc) : null,
        onPrint: hasPrinter ? () => printer.print(doc) : null,
      ),
    );
  }

  Future<void> _prepay(
    BuildContext context,
    WidgetRef ref, {
    required String customerId,
    required String customerName,
    required int balanceCents,
    List<String> orderLines = const [],
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final session = ref.read(tillSessionProvider);
    if (session == null || !await _hasShift(context, ref)) return;
    if (!context.mounted) return;
    final amount = await showDialog<int>(
      context: context,
      builder: (_) => _AmountDialog(customerName: customerName),
    );
    if (amount == null) return;
    final now = ref.read(saleClockProvider)();
    await ref
        .read(ordersRepositoryProvider)
        .prepay(
          customerId: customerId,
          customerName: customerName,
          amountCents: amount,
          staffId: session.staff.id,
          now: now,
        );
    ref.invalidate(todayTicketsProvider);
    // Cash goes in the drawer, and the customer takes a slip.
    final printer = ref.read(printerServiceProvider);
    await printer.print(
      claimDocument(
        l10n,
        branch: ref.read(enrolledBranchNameProvider).value,
        customerName: customerName,
        amountCents: amount,
        balanceCents: balanceCents + amount,
        at: now,
        cashierName: session.staff.displayName,
        orderLines: orderLines,
      ),
      openDrawer: true,
    );
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.ordersPrepaid(formatCents(amount)))),
    );
  }

  Future<void> _prepayOther(BuildContext context, WidgetRef ref) async {
    final c = await showDialog<Customer>(
      context: context,
      builder: (_) => const _CustomerSearchDialog(),
    );
    if (c == null || !context.mounted) return;
    await _prepay(
      context,
      ref,
      customerId: c.id,
      customerName: c.name,
      balanceCents: c.balanceCents,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final session = ref.watch(tillSessionProvider);
    final tickets = ref.watch(todayTicketsProvider);
    final mayPrepay = session?.hasPermission('orders.pickup') == true;
    return ListView(
      key: const Key('orders-screen'),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.ordersToday,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            if (mayPrepay)
              TextButton.icon(
                key: const Key('prepay-other'),
                icon: const Icon(Icons.person_search_outlined),
                label: Text(l10n.ordersPrepayOther),
                onPressed: () => _prepayOther(context, ref),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        tickets.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Text(l10n.ordersEmpty),
          data: (list) => list.isEmpty
              ? Center(
                  child: Text(l10n.ordersEmpty, key: const Key('orders-empty')),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final t in list)
                      _TicketCard(
                        ticket: t,
                        onHandOver: () => _handOver(context, ref, t),
                        onPrepay: () => _prepay(
                          context,
                          ref,
                          customerId: t.row.customerId,
                          customerName: t.row.customerName,
                          balanceCents: t.balanceCents,
                          orderLines: [
                            for (final l in t.lines)
                              l10n.ordersLine(
                                '${l['productName']}',
                                l['quantity'] as int,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.onHandOver,
    required this.onPrepay,
  });

  final TillTicket ticket;
  final VoidCallback onHandOver;
  final VoidCallback onPrepay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final t = ticket;
    final low = t.pending && t.balanceCents < t.row.totalCents;
    return Card(
      key: Key('ticket-${t.row.id}'),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(t.row.pickupTime, style: theme.textTheme.titleLarge),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.row.customerName, style: theme.textTheme.titleMedium),
                  for (final l in t.lines)
                    Text(
                      l10n.ordersLine(
                        '${l['productName']}',
                        l['quantity'] as int,
                      ),
                    ),
                  Text(
                    low
                        ? '${l10n.ordersLowBalance} · ${l10n.ordersBalance(formatCents(t.balanceCents))}'
                        : l10n.ordersBalance(formatCents(t.balanceCents)),
                    key: Key('balance-${t.row.id}'),
                    style: TextStyle(color: low ? AppColors.alertRed : null),
                  ),
                ],
              ),
            ),
            Text(
              formatCents(t.row.totalCents),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (t.pending)
                    SizedBox(
                      height: AppDimensions.preferredTouchTarget,
                      child: FilledButton(
                        key: Key('handover-${t.row.id}'),
                        onPressed: onHandOver,
                        child: Text(l10n.ordersHandOver),
                      ),
                    )
                  else
                    Chip(
                      key: Key('handed-${t.row.id}'),
                      label: Text(l10n.ordersHandedOver),
                    ),
                  TextButton(
                    key: Key('prepay-${t.row.id}'),
                    onPressed: onPrepay,
                    child: Text(l10n.ordersPrepay),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({required this.customerName});

  final String customerName;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _amount = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cents = parseCents(_amount.text);
    return AlertDialog(
      title: Text(l10n.ordersPrepayTitle(widget.customerName)),
      content: TextField(
        key: const Key('prepay-amount'),
        controller: _amount,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: l10n.ordersAmount),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('prepay-save'),
          onPressed: cents == null || cents < 1
              ? null
              : () => Navigator.of(context).pop(cents),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

/// Online search, for a customer with no ticket today.
class _CustomerSearchDialog extends ConsumerStatefulWidget {
  const _CustomerSearchDialog();

  @override
  ConsumerState<_CustomerSearchDialog> createState() =>
      _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends ConsumerState<_CustomerSearchDialog> {
  final _q = TextEditingController();
  List<Customer> _found = const [];
  bool _failed = false;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    try {
      final res = await ref
          .read(restClientProvider)
          .orders
          .listCustomers(q: _q.text.trim());
      if (mounted) {
        setState(() {
          _found = res.items;
          _failed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.ordersPrepayOther),
      content: SizedBox(
        width: 420,
        height: 360,
        child: Column(
          children: [
            TextField(
              key: const Key('customer-search'),
              controller: _q,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                labelText: l10n.ordersSearchCustomer,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
            ),
            if (_failed)
              Text(
                l10n.ordersNeedsServer,
                style: const TextStyle(color: AppColors.alertRed),
              ),
            Expanded(
              child: ListView(
                children: [
                  for (final c in _found)
                    ListTile(
                      key: Key('customer-${c.id}'),
                      title: Text(c.name),
                      subtitle: Text(c.phone ?? ''),
                      trailing: Text(formatCents(c.balanceCents)),
                      onTap: () => Navigator.of(context).pop(c),
                    ),
                ],
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
      ],
    );
  }
}
