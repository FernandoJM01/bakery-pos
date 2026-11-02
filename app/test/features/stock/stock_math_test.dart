import 'dart:convert';
import 'dart:io';

import 'package:bakery_pos/features/stock/domain/stock_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cases =
      (jsonDecode(
            File('../contracts/fixtures/stock-fifo-cases.json')
                .readAsStringSync(),
          ) as Map<String, dynamic>)['cases']
          as List;

  group('F2: oldest first', () {
    for (final c in cases.cast<Map<String, dynamic>>()) {
      test(c['name'] as String, () {
        final r = assignLots(
          [
            for (final l in (c['lots'] as List).cast<Map<String, dynamic>>())
              FifoLot(
                id: l['id'] as String,
                producedOn: l['producedOn'] as String,
                left: l['left'] as int,
              ),
          ],
          c['quantity'] as int,
          c['dayOld'] == true ? c['agedOnOrBefore'] as String : null,
        );
        final e = c['expected'] as Map<String, dynamic>;
        expect(r.unassigned, e['unassigned']);
        expect(r.takes, [
          for (final t in (e['takes'] as List).cast<Map<String, dynamic>>())
            (t['lotId'] as String, t['quantity'] as int),
        ]);
      });
    }
  });

  test('day-old price rounds half up, like the server', () {
    expect(dayOldPrice(1500, 3000), 1050);
    expect(dayOldPrice(1250, 3300), 838);
  });

  test('F10: calendar days cross months and clock changes', () {
    expect(daysBefore('2026-11-01', 1), '2026-10-31');
    expect(daysBetween('2026-10-24', '2026-10-26'), 2);
    expect(daysBetween('2027-03-27', '2027-03-29'), 2);
    expect(isDayOld(1, 1), isTrue);
    expect(isDayOld(0, 1), isFalse);
    expect(isDayOld(9, null), isFalse);
  });
}
