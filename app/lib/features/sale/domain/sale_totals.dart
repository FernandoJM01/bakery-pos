import '../../../core/money/tax_split.dart';

/// How a discount is given: basis points or centavos.
enum DiscountKind {
  percent('PERCENT'),
  amount('AMOUNT');

  const DiscountKind(this.json);
  final String json;
}

class TotalsDiscount {
  const TotalsDiscount(this.kind, this.value);

  final DiscountKind kind;

  /// Basis points for [DiscountKind.percent], centavos for amount.
  final int value;
}

class TotalsLineInput {
  const TotalsLineInput({
    required this.lineNo,
    required this.unitPriceCents,
    required this.quantity,
    required this.ivaBp,
    required this.iepsBp,
    this.discount,
  });

  final int lineNo;
  final int unitPriceCents;
  final int quantity;
  final int ivaBp;
  final int iepsBp;
  final TotalsDiscount? discount;
}

class TotalsLine {
  const TotalsLine({
    required this.lineNo,
    required this.grossCents,
    required this.lineDiscountCents,
    required this.orderDiscountCents,
    required this.netCents,
    required this.tax,
  });

  final int lineNo;
  final int grossCents;
  final int lineDiscountCents;
  final int orderDiscountCents;
  final int netCents;
  final TaxSplit tax;

  Map<String, int> toJson() => {
    'lineNo': lineNo,
    'grossCents': grossCents,
    'lineDiscountCents': lineDiscountCents,
    'orderDiscountCents': orderDiscountCents,
    'netCents': netCents,
    'baseCents': tax.baseCents,
    'iepsCents': tax.iepsCents,
    'ivaCents': tax.ivaCents,
  };
}

class TaxByRate {
  TaxByRate(this.kind, this.rateBp);

  /// `IVA` or `IEPS`.
  final String kind;
  final int rateBp;

  /// IEPS: the base. IVA: the base plus IEPS.
  int baseCents = 0;
  int taxCents = 0;

  Map<String, Object> toJson() => {
    'kind': kind,
    'rateBp': rateBp,
    'baseCents': baseCents,
    'taxCents': taxCents,
  };
}

class SaleTotals {
  const SaleTotals({
    required this.lines,
    required this.grossCents,
    required this.discountCents,
    required this.totalCents,
    required this.taxes,
  });

  final List<TotalsLine> lines;
  final int grossCents;
  final int discountCents;
  final int totalCents;
  final List<TaxByRate> taxes;

  /// What the ticket discount took off in total.
  int get orderDiscountCents =>
      lines.fold(0, (a, l) => a + l.orderDiscountCents);

  /// The amount the ticket discount applies to (after line discounts).
  int get afterLineCents =>
      lines.fold(0, (a, l) => a + l.grossCents - l.lineDiscountCents);
}

/// A discount that cannot be applied (an amount above what it discounts).
class TotalsException implements Exception {
  const TotalsException(this.message);
  final String message;
  @override
  String toString() => message;
}

int _divRoundHalfUp(int n, int d) => (2 * n + d) ~/ (2 * d);

int _discountCents(TotalsDiscount d, int amount) {
  if (d.kind == DiscountKind.percent) {
    if (d.value > 10000) {
      throw const TotalsException('A percentage is at most 100%');
    }
    return _divRoundHalfUp(amount * d.value, 10000);
  }
  if (d.value > amount) {
    throw const TotalsException('A discount cannot exceed its amount');
  }
  return d.value;
}

/// Sale totals, M3 brief section 4.2. Same function as
/// `server/src/sales/sale-totals.ts`; both reproduce
/// `contracts/fixtures/sale-totals-cases.json` (D3).
SaleTotals computeSaleTotals(
  List<TotalsLineInput> lines, [
  TotalsDiscount? orderDiscount,
]) {
  final gross = [for (final l in lines) l.unitPriceCents * l.quantity];
  final lineDisc = [
    for (final (i, l) in lines.indexed)
      l.discount == null ? 0 : _discountCents(l.discount!, gross[i]),
  ];
  final after = [for (var i = 0; i < lines.length; i++) gross[i] - lineDisc[i]];
  final sum = after.fold(0, (a, b) => a + b);
  final ticket = orderDiscount == null ? 0 : _discountCents(orderDiscount, sum);

  final shares = List.filled(lines.length, 0);
  if (sum > 0 && ticket > 0) {
    final rem = <(int, int)>[];
    for (var i = 0; i < lines.length; i++) {
      // BigInt keeps ticket × amount exact whatever the size.
      final p = BigInt.from(ticket) * BigInt.from(after[i]);
      final s = BigInt.from(sum);
      shares[i] = (p ~/ s).toInt();
      rem.add(((p % s).toInt(), i));
    }
    var left = ticket - shares.fold(0, (a, b) => a + b);
    rem.sort((x, y) {
      final byRem = y.$1.compareTo(x.$1);
      return byRem != 0
          ? byRem
          : lines[x.$2].lineNo.compareTo(lines[y.$2].lineNo);
    });
    for (final (_, i) in rem) {
      if (left == 0) break;
      shares[i] += 1;
      left -= 1;
    }
  }

  final taxes = <String, TaxByRate>{};
  void add(String kind, int rateBp, int base, int tax) {
    final e = taxes.putIfAbsent('$kind:$rateBp', () => TaxByRate(kind, rateBp));
    e.baseCents += base;
    e.taxCents += tax;
  }

  final out = <TotalsLine>[];
  for (final (i, l) in lines.indexed) {
    final net = after[i] - shares[i];
    final t = splitTax(net, l.ivaBp, l.iepsBp);
    if (l.iepsBp != 0) add('IEPS', l.iepsBp, t.baseCents, t.iepsCents);
    add('IVA', l.ivaBp, t.baseCents + t.iepsCents, t.ivaCents);
    out.add(
      TotalsLine(
        lineNo: l.lineNo,
        grossCents: gross[i],
        lineDiscountCents: lineDisc[i],
        orderDiscountCents: shares[i],
        netCents: net,
        tax: t,
      ),
    );
  }

  final sorted = taxes.values.toList()
    ..sort((a, b) {
      final k = a.kind.compareTo(b.kind);
      return k != 0 ? k : a.rateBp.compareTo(b.rateBp);
    });
  return SaleTotals(
    lines: out,
    grossCents: out.fold(0, (a, l) => a + l.grossCents),
    discountCents: out.fold(
      0,
      (a, l) => a + l.lineDiscountCents + l.orderDiscountCents,
    ),
    totalCents: out.fold(0, (a, l) => a + l.netCents),
    taxes: sorted,
  );
}

/// Whether a discount takes more than the cashier limit (brief 4.2 step 7):
/// `cents / base > limitBp / 10000`, in integers.
bool overLimit(int cents, int base, int limitBp) =>
    base > 0 && cents * 10000 > limitBp * base;

/// Amount of refunding [units] more of a line with net [net] and quantity
/// [quantity], [already] refunded before (brief 4.3). Partial refunds add up
/// exactly to the line.
int refundAmountCents(int net, int quantity, int already, int units) =>
    _divRoundHalfUp(net * (already + units), quantity) -
    _divRoundHalfUp(net * already, quantity);
