import 'dart:convert';
import 'dart:io';

import 'package:bakery_pos/features/cash/domain/cash_totals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cases =
      (jsonDecode(
            File('../contracts/fixtures/shift-cash-cases.json')
                .readAsStringSync(),
          ) as Map<String, dynamic>)['cases']
          as List;

  group('E3: expected cash', () {
    for (final c in cases.cast<Map<String, dynamic>>()) {
      test(c['name'] as String, () {
        List<int> ints(String k) => (c[k] as List).cast<int>();
        final r = closeResult(
          floatCents: c['floatCents'] as int,
          saleAmountsCents: ints('saleAmountsCents'),
          cashInCents: ints('cashInCents'),
          cashOutCents: ints('cashOutCents'),
          refundsCents: ints('refundsCents'),
          prepaymentsCents: ints('prepaymentsCents'),
          countedCents: c['countedCents'] as int,
          flagCents: c['cashVarianceFlagCents'] as int,
        );
        final e = c['expected'] as Map<String, dynamic>;
        expect(r.expectedCents, e['expectedCents']);
        expect(r.varianceCents, e['varianceCents']);
        expect(r.flagged, e['flagged']);
      });
    }
  });

  test('countTotal adds value times quantity', () {
    expect(countTotal({50000: 2, 50: 3}), 100150);
  });
}
