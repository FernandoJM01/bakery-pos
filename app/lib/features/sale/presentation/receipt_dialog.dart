import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/sale_repository.dart';
import '../domain/sale_totals.dart';
import 'discount_dialog.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// `01/11/2026 14:05`, in the till's local time.
String formatReceiptDate(DateTime at) {
  final t = at.toLocal();
  return '${_two(t.day)}/${_two(t.month)}/${t.year} ${_two(t.hour)}:${_two(t.minute)}';
}

/// The receipt on screen (M3 brief 4.1): exactly what the printed ticket
/// will show in Sprint 4.
class ReceiptDialog extends ConsumerWidget {
  const ReceiptDialog({super.key, required this.receipt});

  final SaleReceipt receipt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final branch = ref.watch(enrolledBranchNameProvider).value;
    final t = receipt.totals;
    final ticket = receipt.ticket;

    Widget row(String left, String right, {Key? key, TextStyle? style}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(child: Text(left, style: style)),
              Text(right, key: key, style: style),
            ],
          ),
        );

    return AlertDialog(
      title: Text(l10n.receiptTitle),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            key: const Key('receipt'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (branch != null)
                Text(
                  branch,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              Text(
                l10n.receiptFolio(receipt.folio),
                key: const Key('receipt-folio'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              Text(
                formatReceiptDate(receipt.occurredAt),
                textAlign: TextAlign.center,
              ),
              Text(
                l10n.receiptCashier(receipt.cashierName),
                textAlign: TextAlign.center,
              ),
              const Divider(),
              for (final (i, l) in ticket.lines.indexed) ...[
                row(
                  '${l.item.productName} · ${l.item.variantName}',
                  formatCents(t.lines[i].grossCents),
                ),
                Text(
                  l10n.saleLineQuantityPrice(
                    l.quantity,
                    formatCents(l.item.unitPriceCents),
                  ),
                  style: theme.textTheme.bodySmall,
                ),
                if (l.discount != null)
                  row(
                    l.discount!.kind == DiscountKind.percent
                        ? l10n.receiptLineDiscountPercent(
                            formatPercentBp(l.discount!.value),
                          )
                        : l10n.saleDiscountButton,
                    '−${formatCents(t.lines[i].lineDiscountCents)}',
                    key: Key('receipt-line-discount-${i + 1}'),
                  ),
              ],
              if (ticket.orderDiscount != null)
                row(
                  l10n.saleDiscountTicketLabel,
                  '−${formatCents(t.orderDiscountCents)}',
                  key: const Key('receipt-ticket-discount'),
                ),
              const Divider(),
              row(
                l10n.saleTotal,
                formatCents(t.totalCents),
                key: const Key('receipt-total'),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(l10n.receiptTaxIncluded, style: theme.textTheme.labelLarge),
              for (final x in t.taxes)
                Text(
                  l10n.receiptTaxLine(
                    x.kind,
                    formatPercentBp(x.rateBp),
                    formatCents(x.baseCents),
                    formatCents(x.taxCents),
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              const Divider(),
              row(l10n.receiptReceived, formatCents(receipt.tenderedCents)),
              row(
                l10n.receiptChange,
                formatCents(receipt.changeCents),
                key: const Key('receipt-change'),
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          height: AppDimensions.preferredTouchTarget,
          child: FilledButton(
            key: const Key('receipt-new-sale'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.receiptNewSale),
          ),
        ),
      ],
    );
  }
}
