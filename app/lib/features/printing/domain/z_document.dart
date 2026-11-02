import '../../../core/money/money.dart';
import '../../../l10n/app_localizations.dart';
import '../../cash/domain/z_report.dart';
import 'escpos.dart';

// No till storage here: the back office shows the same Z report on the web.

String _two(int n) => n.toString().padLeft(2, '0');

/// `01/11/2026 14:05`, in the till's local time.
String formatPrintDate(DateTime at) {
  final t = at.toLocal();
  return '${_two(t.day)}/${_two(t.month)}/${t.year} '
      '${_two(t.hour)}:${_two(t.minute)}';
}

/// Who, when and how the drawer ended, around a [ZReport].
class ZHeader {
  const ZHeader({
    required this.zLabel,
    required this.branch,
    required this.openedAt,
    required this.openedBy,
    required this.closedAt,
    required this.closedBy,
    required this.floatCents,
    required this.expectedCents,
    required this.countedCents,
    required this.varianceCents,
    this.note,
  });

  final String zLabel;
  final String? branch;
  final DateTime openedAt;
  final String openedBy;
  final DateTime closedAt;
  final String closedBy;
  final int floatCents;
  final int expectedCents;
  final int countedCents;
  final int varianceCents;
  final String? note;
}

String cashReasonLabel(AppLocalizations l10n, String reason) =>
    switch (reason) {
      'CHANGE_FUND' => l10n.cashReasonChangeFund,
      'SUPPLIER_PAYMENT' => l10n.cashReasonSupplier,
      'BANK_DROP' => l10n.cashReasonBankDrop,
      _ => l10n.cashReasonOther,
    };

/// The Z report (M4 brief 4.5), printed and on screen from the same lines.
List<PrintLine> zDocument(AppLocalizations l10n, ZHeader h, ZReport z) {
  PrintLine money(String label, int cents, {bool bold = false}) =>
      PrintLine(label, right: formatCents(cents), bold: bold);
  return [
    if (h.branch != null) PrintLine(h.branch!, bold: true, center: true),
    PrintLine(l10n.zTitle(h.zLabel), bold: true, center: true),
    PrintLine(l10n.zOpened(formatPrintDate(h.openedAt), h.openedBy)),
    PrintLine(l10n.zClosed(formatPrintDate(h.closedAt), h.closedBy)),
    const PrintLine.rule(),
    PrintLine(l10n.zSaleCount, right: '${z.saleCount}'),
    money(l10n.zGross, z.grossCents),
    money(l10n.zDiscounts, z.discountCents),
    money(l10n.zNet, z.netCents, bold: true),
    const PrintLine.rule(),
    PrintLine(l10n.zTaxes, bold: true),
    for (final t in z.taxes)
      PrintLine(
        l10n.receiptTaxLine(
          t.kind,
          formatPercentBp(t.rateBp),
          formatCents(t.baseCents),
          formatCents(t.taxCents),
        ),
      ),
    const PrintLine.rule(),
    PrintLine(l10n.zRefunds(z.refundCount), right: formatCents(z.refundCents)),
    PrintLine(l10n.zVoids(z.voidCount), right: formatCents(z.voidCents)),
    money(l10n.zPrepaid, z.prepaidCollectedCents),
    money(l10n.zCashIn, z.cashInCents),
    money(l10n.zCashOut, z.cashOutCents),
    for (final m in z.movements)
      PrintLine(
        '  ${cashReasonLabel(l10n, m.reason)}',
        right: formatCents(m.amountCents),
      ),
    const PrintLine.rule(),
    money(l10n.cashFloat, h.floatCents),
    money(l10n.cashExpected, h.expectedCents),
    money(l10n.cashCounted, h.countedCents),
    money(l10n.cashDifference, h.varianceCents, bold: true),
    if (h.note != null) PrintLine(l10n.zNote(h.note!)),
  ];
}
