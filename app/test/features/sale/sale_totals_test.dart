import 'dart:convert';
import 'dart:io';

import 'package:bakery_pos/features/sale/domain/sale_totals.dart';
import 'package:flutter_test/flutter_test.dart';

TotalsDiscount? _discount(Object? json) {
  if (json == null) return null;
  final m = json as Map<String, dynamic>;
  return TotalsDiscount(
    m['kind'] == 'PERCENT' ? DiscountKind.percent : DiscountKind.amount,
    m['value'] as int,
  );
}

void main() {
  final fixture = jsonDecode(
    File('../contracts/fixtures/sale-totals-cases.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final cases = (fixture['cases'] as List).cast<Map<String, dynamic>>();

  test('the fixture has the shared cases', () {
    expect(cases.length, greaterThanOrEqualTo(12));
  });

  for (final c in cases) {
    test('D3: ${c['name']}', () {
      final lines = [
        for (final l in (c['lines'] as List).cast<Map<String, dynamic>>())
          TotalsLineInput(
            lineNo: l['lineNo'] as int,
            unitPriceCents: l['unitPriceCents'] as int,
            quantity: l['quantity'] as int,
            ivaBp: l['ivaBp'] as int,
            iepsBp: l['iepsBp'] as int,
            discount: _discount(l['discount']),
          ),
      ];
      final t = computeSaleTotals(lines, _discount(c['orderDiscount']));
      expect({
        'lines': [for (final l in t.lines) l.toJson()],
        'grossCents': t.grossCents,
        'discountCents': t.discountCents,
        'totalCents': t.totalCents,
        'taxes': [for (final x in t.taxes) x.toJson()],
      }, c['expected']);
    });
  }

  test('an amount discount above the line is refused', () {
    expect(
      () => computeSaleTotals([
        const TotalsLineInput(
          lineNo: 1,
          unitPriceCents: 100,
          quantity: 1,
          ivaBp: 0,
          iepsBp: 0,
          discount: TotalsDiscount(DiscountKind.amount, 101),
        ),
      ]),
      throwsA(isA<TotalsException>()),
    );
  });

  test('the limit allows exactly 10% and refuses a centavo more', () {
    expect(overLimit(100, 1000, 1000), isFalse);
    expect(overLimit(101, 1000, 1000), isTrue);
  });

  test('partial refunds add up to the line', () {
    final parts = [
      for (var r = 0; r < 3; r++) refundAmountCents(1000, 3, r, 1),
    ];
    expect(parts, [333, 334, 333]);
  });
}
