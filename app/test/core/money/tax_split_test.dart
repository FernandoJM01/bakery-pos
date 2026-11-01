import 'dart:convert';
import 'dart:io';

import 'package:bakery_pos/core/money/tax_split.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('C5: \$10.00 with IVA 16% and with IEPS 8% plus IVA 16%', () {
    expect(
      splitTax(1000, 1600, 0),
      const TaxSplit(baseCents: 862, iepsCents: 0, ivaCents: 138),
    );
    expect(
      splitTax(1000, 1600, 800),
      const TaxSplit(baseCents: 798, iepsCents: 64, ivaCents: 138),
    );
  });

  test('C5: every row of contracts/fixtures/tax-split-cases.json', () {
    // flutter test runs from app/, so the shared fixture is one level up.
    final file = File('../contracts/fixtures/tax-split-cases.json');
    final cases =
        (jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)['cases']
            as List<dynamic>;
    expect(cases, isNotEmpty);
    for (final raw in cases) {
      final c = raw as Map<String, dynamic>;
      final split = splitTax(
        c['priceCents'] as int,
        c['ivaBp'] as int,
        c['iepsBp'] as int,
      );
      expect(
        split,
        TaxSplit(
          baseCents: c['baseCents'] as int,
          iepsCents: c['iepsCents'] as int,
          ivaCents: c['ivaCents'] as int,
        ),
        reason: 'case $c',
      );
      expect(
        split.baseCents + split.iepsCents + split.ivaCents,
        c['priceCents'],
      );
    }
  });

  test('the parts add up for every price up to \$100 at the seeded rates', () {
    for (var price = 1; price <= 10000; price++) {
      for (final (iva, ieps) in [(0, 0), (1600, 0), (1600, 800), (0, 800)]) {
        final s = splitTax(price, iva, ieps);
        expect(s.baseCents + s.iepsCents + s.ivaCents, price);
        expect(s.baseCents, greaterThanOrEqualTo(0));
        expect(s.iepsCents, greaterThanOrEqualTo(0));
        expect(s.ivaCents, greaterThanOrEqualTo(0));
      }
    }
  });
}
