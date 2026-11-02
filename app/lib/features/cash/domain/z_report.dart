import '../../sale/domain/sale_totals.dart';

class ZLine {
  const ZLine({
    required this.ivaBp,
    required this.iepsBp,
    required this.baseCents,
    required this.iepsCents,
    required this.ivaCents,
  });

  final int ivaBp;
  final int iepsBp;
  final int baseCents;
  final int iepsCents;
  final int ivaCents;
}

class ZSale {
  const ZSale({
    required this.grossCents,
    required this.discountCents,
    required this.totalCents,
    required this.lines,
  });

  final int grossCents;
  final int discountCents;
  final int totalCents;
  final List<ZLine> lines;
}

class ZRefund {
  const ZRefund({
    required this.isVoid,
    required this.totalCents,
    required this.lines,
  });

  final bool isVoid;
  final int totalCents;
  final List<ZLine> lines;
}

class ZMovement {
  const ZMovement({
    required this.kind,
    required this.reason,
    required this.amountCents,
  });

  /// `IN` or `OUT`, and a `CashMovementReason`.
  final String kind;
  final String reason;
  final int amountCents;
}

class ZReport {
  const ZReport({
    required this.saleCount,
    required this.grossCents,
    required this.discountCents,
    required this.netCents,
    required this.taxes,
    required this.refundCount,
    required this.refundCents,
    required this.voidCount,
    required this.voidCents,
    required this.cashInCents,
    required this.cashOutCents,
    required this.movements,
    this.prepaidCollectedCents = 0,
  });

  final int saleCount;
  final int grossCents;
  final int discountCents;
  final int netCents;
  final List<TaxByRate> taxes;
  final int refundCount;
  final int refundCents;
  final int voidCount;
  final int voidCents;
  final int prepaidCollectedCents;
  final int cashInCents;
  final int cashOutCents;
  final List<ZMovement> movements;
}

/// The Z report of a shift from its stored rows (M4 brief 4.5). Same function
/// as `server/src/shifts/z-report.ts`. Tax by rate is net of refunds and is
/// never recomputed from prices.
ZReport computeZReport(
  List<ZSale> sales,
  List<ZRefund> refunds,
  List<ZMovement> movements,
) {
  final taxes = <String, TaxByRate>{};
  void add(String kind, int rateBp, int base, int tax) {
    final e = taxes.putIfAbsent('$kind:$rateBp', () => TaxByRate(kind, rateBp));
    e.baseCents += base;
    e.taxCents += tax;
  }

  void addLine(ZLine l, int sign) {
    if (l.iepsBp != 0) {
      add('IEPS', l.iepsBp, sign * l.baseCents, sign * l.iepsCents);
    }
    add('IVA', l.ivaBp, sign * (l.baseCents + l.iepsCents), sign * l.ivaCents);
  }

  for (final s in sales) {
    for (final l in s.lines) {
      addLine(l, 1);
    }
  }
  for (final r in refunds) {
    for (final l in r.lines) {
      addLine(l, -1);
    }
  }

  int total<T>(Iterable<T> xs, int Function(T) f) =>
      xs.fold(0, (a, x) => a + f(x));
  final voids = refunds.where((r) => r.isVoid);
  final plain = refunds.where((r) => !r.isVoid);

  final grouped = <String, int>{};
  for (final m in movements) {
    final key = '${m.kind}:${m.reason}';
    grouped[key] = (grouped[key] ?? 0) + m.amountCents;
  }
  final keys = grouped.keys.toList()..sort();

  final sortedTaxes = taxes.values.toList()
    ..sort((a, b) {
      final k = a.kind.compareTo(b.kind);
      return k != 0 ? k : a.rateBp.compareTo(b.rateBp);
    });
  return ZReport(
    saleCount: sales.length,
    grossCents: total(sales, (s) => s.grossCents),
    discountCents: total(sales, (s) => s.discountCents),
    netCents: total(sales, (s) => s.totalCents),
    taxes: sortedTaxes,
    refundCount: plain.length,
    refundCents: total(plain, (r) => r.totalCents),
    voidCount: voids.length,
    voidCents: total(voids, (r) => r.totalCents),
    cashInCents: total(
      movements.where((m) => m.kind == 'IN'),
      (m) => m.amountCents,
    ),
    cashOutCents: total(
      movements.where((m) => m.kind == 'OUT'),
      (m) => m.amountCents,
    ),
    movements: [
      for (final k in keys)
        ZMovement(
          kind: k.split(':').first,
          reason: k.split(':').last,
          amountCents: grouped[k]!,
        ),
    ],
  );
}
