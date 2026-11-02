import '../../../core/money/money.dart';
import '../../../l10n/app_localizations.dart';
import '../../sale/data/sale_repository.dart';
import '../../sale/domain/sale_totals.dart';
import 'escpos.dart';
import 'z_document.dart';

export 'z_document.dart';

/// The printed ticket: what the receipt screen shows (M3 brief 4.1).
List<PrintLine> receiptDocument(
  AppLocalizations l10n,
  SaleReceipt r,
  String? branch,
) {
  final t = r.totals;
  return [
    if (branch != null) PrintLine(branch, bold: true, center: true),
    PrintLine(l10n.receiptFolio(r.folio), bold: true, center: true),
    PrintLine(formatPrintDate(r.occurredAt), center: true),
    PrintLine(l10n.receiptCashier(r.cashierName), center: true),
    const PrintLine.rule(),
    for (final (i, l) in r.ticket.lines.indexed) ...[
      PrintLine(
        '${l.item.productName} · ${l.item.variantName}',
        right: formatCents(t.lines[i].grossCents),
      ),
      PrintLine(
        l10n.saleLineQuantityPrice(
          l.quantity,
          formatCents(l.item.unitPriceCents),
        ),
      ),
      if (l.discount != null)
        PrintLine(
          l.discount!.kind == DiscountKind.percent
              ? l10n.receiptLineDiscountPercent(
                  formatPercentBp(l.discount!.value),
                )
              : l10n.saleDiscountButton,
          right: '-${formatCents(t.lines[i].lineDiscountCents)}',
        ),
    ],
    if (r.ticket.orderDiscount != null)
      PrintLine(
        l10n.saleDiscountTicketLabel,
        right: '-${formatCents(t.orderDiscountCents)}',
      ),
    const PrintLine.rule(),
    PrintLine(l10n.saleTotal, right: formatCents(t.totalCents), bold: true),
    PrintLine(l10n.receiptTaxIncluded),
    for (final x in t.taxes)
      PrintLine(
        l10n.receiptTaxLine(
          x.kind,
          formatPercentBp(x.rateBp),
          formatCents(x.baseCents),
          formatCents(x.taxCents),
        ),
      ),
    const PrintLine.rule(),
    PrintLine(l10n.receiptReceived, right: formatCents(r.tenderedCents)),
    PrintLine(
      l10n.receiptChange,
      right: formatCents(r.changeCents),
      bold: true,
    ),
  ];
}
