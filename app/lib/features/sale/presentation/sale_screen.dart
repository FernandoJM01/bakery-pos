import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/till_auth_service.dart';
import '../../auth/domain/approval_models.dart';
import '../../till_catalog/data/till_catalog_repository.dart';
import '../../till_catalog/presentation/product_grid_screen.dart';
import '../data/held_ticket_repository.dart';
import '../data/refund_repository.dart';
import '../data/sale_repository.dart';
import '../domain/ticket.dart';
import 'discount_dialog.dart';
import 'held_tickets.dart';
import 'payment_dialog.dart';
import 'receipt_dialog.dart';
import 'refund_dialog.dart';

SaleItem saleItemOf(GridProduct p, GridVariant v) => SaleItem(
  variantId: v.id,
  productName: p.name,
  variantName: v.name,
  unitPriceCents: v.priceCents,
  ivaRateId: p.ivaRateId,
  ivaBp: p.ivaBp,
  iepsRateId: p.iepsRateId,
  iepsBp: p.iepsBp,
);

/// Asks before throwing away a ticket with lines, and records it
/// (`sale.ticket_discarded`). True when the ticket is now empty.
Future<bool> confirmDiscardTicket(BuildContext context, WidgetRef ref) async {
  final ticket = ref.read(ticketProvider);
  if (ticket.isEmpty) return true;
  final l10n = AppLocalizations.of(context)!;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.saleClearTitle),
      content: Text(l10n.saleClearBody(ticket.unitCount)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('ticket-clear-confirm'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.alertRed),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.saleClearConfirm),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  final staffId = ref.read(tillSessionProvider)?.staff.id;
  if (staffId != null) {
    await ref
        .read(saleRepositoryProvider)
        .discardTicket(ticket, staffId, ref.read(saleClockProvider)());
  }
  ref.read(ticketProvider.notifier).clear();
  return true;
}

/// The sale screen (approved wireframe): the product grid on the left, the
/// ticket on the right.
class SaleScreen extends ConsumerWidget {
  const SaleScreen({super.key});

  Future<void> _onProduct(
    BuildContext context,
    WidgetRef ref,
    GridProduct p,
  ) async {
    final notifier = ref.read(ticketProvider.notifier);
    if (p.variants.length == 1) {
      notifier.add(saleItemOf(p, p.variants.single));
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final v = await showDialog<GridVariant>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.saleChooseVariantTitle(p.name)),
        children: [
          for (final v in p.variants)
            SimpleDialogOption(
              key: Key('variant-${v.id}'),
              onPressed: () => Navigator.of(context).pop(v),
              child: SizedBox(
                height: AppDimensions.preferredTouchTarget,
                child: Row(
                  children: [
                    Expanded(child: Text(v.name)),
                    Text(formatCents(v.priceCents)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    if (v != null) notifier.add(saleItemOf(p, v));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ProductGridScreen(
            onProductTap: (p) => _onProduct(context, ref, p),
          ),
        ),
        const VerticalDivider(width: 1, color: AppColors.surfaceHighlight),
        const SizedBox(width: 380, child: TicketPanel()),
      ],
    );
  }
}

class TicketPanel extends ConsumerWidget {
  const TicketPanel({super.key});

  Future<void> _pay(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(saleRepositoryProvider);
    final session = ref.read(tillSessionProvider);
    if (session == null || ref.read(ticketProvider).isEmpty) return;
    var ticket = ref.read(ticketProvider).withoutApprovalsBy(session.staff.id);
    final prefix = await repo.folioPrefix();
    if (!context.mounted) return;
    if (prefix == null || prefix.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.saleNoFolio)));
      return;
    }
    final limit = await repo.discountLimitBp();
    if (!context.mounted) return;
    if (ticket.needsApproval(limit) &&
        !session.hasPermission('sale.discount_over_limit')) {
      final result = await ref.read(approvalRequesterProvider)(
        context,
        action: 'sale.discount_over_limit',
      );
      if (!context.mounted) return;
      if (result == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.saleDiscountApprovalNeeded)),
        );
        return;
      }
      ticket = ticket.approvedBy(switch (result) {
        OnlineApprovalResult r => r.approverStaffId,
        OfflineApprovalResult r => r.approverStaffId,
      }, limit);
      ref.read(ticketProvider.notifier).restore(ticket);
    }
    final toPay = ticket;
    final receipt = await showDialog<SaleReceipt>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentDialog(
        totalCents: toPay.totals.totalCents,
        onFinish: (tendered) => repo.completeSale(
          ticket: toPay,
          cashier: session.staff,
          tenderedCents: tendered,
          now: ref.read(saleClockProvider)(),
        ),
      ),
    );
    if (receipt == null || !context.mounted) return;
    ref.read(ticketProvider.notifier).clear();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ReceiptDialog(receipt: receipt),
    );
  }

  Future<void> _refund(BuildContext context, RefundKind kind) async {
    final result = await showRefundFlow(context, kind);
    if (result != null && context.mounted) {
      await showRefundDone(context, kind, result);
    }
  }

  Future<void> _ticketDiscount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final ticket = ref.read(ticketProvider);
    final choice = await showDiscountDialog(
      context,
      title: l10n.saleDiscountTicketTitle,
      baseCents: ticket.totals.afterLineCents,
      current: ticket.orderDiscount,
    );
    if (choice != null) {
      ref.read(ticketProvider.notifier).setOrderDiscount(choice.discount);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ticket = ref.watch(ticketProvider);
    final totals = ticket.totals;
    final heldCount = ref.watch(heldTicketsProvider).value?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.saleTicketTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                key: const Key('ticket-clear'),
                tooltip: l10n.saleClear,
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: ticket.isEmpty
                    ? null
                    : () => confirmDiscardTicket(context, ref),
              ),
            ],
          ),
          Row(
            children: [
              OutlinedButton.icon(
                key: const Key('ticket-hold'),
                icon: const Icon(Icons.pause_circle_outline),
                label: Text(l10n.saleHold),
                onPressed: ticket.isEmpty
                    ? null
                    : () => holdCurrentTicket(context, ref),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: TextButton(
                  key: const Key('held-open'),
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const HeldTicketsDialog(),
                  ),
                  child: Text(l10n.saleHeldOpen(heldCount)),
                ),
              ),
              PopupMenuButton<RefundKind>(
                key: const Key('sale-menu'),
                tooltip: l10n.saleMenu,
                onSelected: (kind) => _refund(context, kind),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    key: const Key('menu-refund'),
                    value: RefundKind.refund,
                    child: Text(l10n.saleMenuRefund),
                  ),
                  PopupMenuItem(
                    key: const Key('menu-void'),
                    value: RefundKind.voidSale,
                    child: Text(l10n.saleMenuVoid),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ticket.isEmpty
                ? Center(
                    child: Text(
                      l10n.saleTicketEmpty,
                      key: const Key('ticket-empty'),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    key: const Key('ticket-lines'),
                    itemCount: ticket.lines.length,
                    itemBuilder: (context, i) => _LineTile(
                      index: i,
                      line: ticket.lines[i],
                      lineGross: totals.lines[i].grossCents,
                      lineDiscount: totals.lines[i].lineDiscountCents,
                    ),
                  ),
          ),
          const Divider(),
          if (totals.discountCents > 0) ...[
            _Amount(l10n.saleSubtotal, formatCents(totals.grossCents)),
            _Amount(
              l10n.saleDiscounts,
              '−${formatCents(totals.discountCents)}',
              valueKey: const Key('ticket-discounts'),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: Text(l10n.saleTotal, style: theme.textTheme.titleLarge),
              ),
              Text(
                formatCents(totals.totalCents),
                key: const Key('ticket-total'),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Row(
            children: [
              SizedBox(
                height: AppDimensions.preferredTouchTarget,
                child: OutlinedButton.icon(
                  key: const Key('ticket-discount'),
                  icon: const Icon(Icons.percent),
                  label: Text(l10n.saleDiscountButton),
                  onPressed: ticket.isEmpty
                      ? null
                      : () => _ticketDiscount(context, ref),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: SizedBox(
                  height: AppDimensions.largeTouchTarget,
                  child: FilledButton(
                    key: const Key('ticket-pay'),
                    onPressed: ticket.isEmpty ? null : () => _pay(context, ref),
                    child: Text(
                      l10n.salePay,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount(this.label, this.value, {this.valueKey});

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, key: valueKey),
      ],
    ),
  );
}

class _LineTile extends ConsumerWidget {
  const _LineTile({
    required this.index,
    required this.line,
    required this.lineGross,
    required this.lineDiscount,
  });

  final int index;
  final TicketLine line;
  final int lineGross;
  final int lineDiscount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      key: Key('ticket-line-${index + 1}'),
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: AppDimensions.paddingSmall,
      title: Text(
        line.item.variantName.isEmpty
            ? line.item.productName
            : l10n.saleLineTitle(line.item.productName, line.item.variantName),
      ),
      subtitle: Text(
        [
          l10n.saleLineQuantityPrice(
            line.quantity,
            formatCents(line.item.unitPriceCents),
          ),
          if (lineDiscount > 0) '−${formatCents(lineDiscount)}',
        ].join('   '),
      ),
      trailing: Text(
        formatCents(lineGross - lineDiscount),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => LineDialog(index: index),
      ),
    );
  }
}

/// Change a line's quantity, remove it, or give it a discount.
class LineDialog extends ConsumerWidget {
  const LineDialog({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ticket = ref.watch(ticketProvider);
    if (index >= ticket.lines.length) {
      // The line was removed; close on the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }
    final line = ticket.lines[index];
    final staffId = ref.watch(tillSessionProvider)?.staff.id ?? '';
    final notifier = ref.read(ticketProvider.notifier);

    return AlertDialog(
      title: Text(
        l10n.saleLineTitle(line.item.productName, line.item.variantName),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                key: const Key('line-minus'),
                iconSize: 32,
                icon: const Icon(Icons.remove),
                onPressed: () => notifier.setQuantity(
                  index,
                  line.quantity - 1,
                  staffId: staffId,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                ),
                child: Text(
                  line.quantity.toString(),
                  key: const Key('line-quantity'),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              IconButton.filledTonal(
                key: const Key('line-plus'),
                iconSize: 32,
                icon: const Icon(Icons.add),
                onPressed: () => notifier.setQuantity(
                  index,
                  line.quantity + 1,
                  staffId: staffId,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          OutlinedButton.icon(
            key: const Key('line-discount'),
            icon: const Icon(Icons.percent),
            label: Text(l10n.saleLineDiscount),
            onPressed: () async {
              final choice = await showDiscountDialog(
                context,
                title: l10n.saleDiscountLineTitle(line.item.productName),
                baseCents: line.item.unitPriceCents * line.quantity,
                current: line.discount,
              );
              if (choice != null) {
                notifier.setLineDiscount(index, choice.discount);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('line-remove'),
          style: TextButton.styleFrom(foregroundColor: AppColors.alertRed),
          onPressed: () {
            notifier.remove(index, staffId: staffId);
            Navigator.of(context).pop();
          },
          child: Text(l10n.saleLineRemove),
        ),
        FilledButton(
          key: const Key('line-done'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.saleLineDone),
        ),
      ],
    );
  }
}
