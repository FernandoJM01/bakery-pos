import 'dart:convert';

import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/features/cash/data/shift_repository.dart';
import 'package:bakery_pos/features/cash/domain/cash_totals.dart';
import 'package:bakery_pos/features/sale/data/refund_repository.dart';
import 'package:bakery_pos/features/sale/data/sale_repository.dart';
import 'package:bakery_pos/features/sale/domain/sale_totals.dart';
import 'package:bakery_pos/features/sale/domain/ticket.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sale/sale_test_data.dart';

void main() {
  late AppDatabase db;
  late ShiftRepository shifts;
  late SaleRepository sales;
  final now = DateTime.utc(2026, 11, 2, 15);
  const thousand = {50000: 2};

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedTill(db);
    await db.delete(db.localShifts).go();
    shifts = ShiftRepository(db);
    sales = SaleRepository(db);
  });
  tearDown(() => db.close());

  Future<List<Map<String, dynamic>>> outbox(String type) async => [
    for (final r in await db.select(db.outboxEntries).get())
      if (r.type == type) jsonDecode(r.payload) as Map<String, dynamic>,
  ];

  Future<SaleReceipt> sell(int units) => sales.completeSale(
    ticket: Ticket(
      lines: [TicketLine(item: pastel, quantity: units)],
    ),
    cashier: cashier,
    tenderedCents: 100000,
    now: now,
  );

  test('E1: no sale without an open shift, and no folio is used', () async {
    await expectLater(sell(1), throwsA(isA<NoOpenShiftException>()));
    expect(await sales.lastFolioNumber(), 0);
    expect(await db.select(db.outboxEntries).get(), isEmpty);
  });

  test(
    'E2: opening writes shift, count and record; a second is refused',
    () async {
      final id = await shifts.open(staff: cashier, count: thousand, now: now);
      expect((await shifts.current())!.floatCents, 100000);
      expect(await shifts.counts(id, 'OPEN'), thousand);
      final opened = (await outbox('shift.opened')).single;
      expect(opened['floatCents'], 100000);
      expect(opened['count'], [
        {'denominationCents': 50000, 'quantity': 2},
      ]);
      await expectLater(
        shifts.open(staff: cashier, count: thousand, now: now),
        throwsA(isA<ShiftAlreadyOpenException>()),
      );
      expect(await db.select(db.localShifts).get(), hasLength(1));
    },
  );

  test(
    'a sale and a refund carry the shift, which balances at close',
    () async {
      final id = await shifts.open(staff: cashier, count: thousand, now: now);
      final receipt = await sell(2);
      expect((await outbox('sale.completed')).single['shiftId'], id);

      await shifts.addMovement(
        shiftId: id,
        kind: CashKind.cashOut,
        amountCents: 1000,
        reason: CashReason.supplierPayment,
        staffId: cashier.id,
        approverStaffId: manager.id,
        now: now,
      );
      final refunds = RefundRepository(db, null);
      final sale = await refunds.find(receipt.folio, online: false);
      await refunds.record(
        sale: sale,
        units: {1: 1},
        restock: const {},
        kind: RefundKind.refund,
        reason: RefundReason.quality,
        staffId: cashier.id,
        approverStaffId: manager.id,
        now: now,
      );
      expect((await outbox('sale.refunded')).single['shiftId'], id);

      // 1000.00 + 44.00 sold − 10.00 out − 22.00 back = 1012.00.
      final closed = await shifts.confirmCount(
        shift: (await shifts.current())!,
        staff: manager,
        count: const {100000: 1, 1000: 1, 200: 1},
        now: now,
      );
      expect(closed.status, 'CLOSED');
      expect(closed.expectedCents, 101200);
      expect(closed.varianceCents, 0);
      expect(closed.zNumber, 1);
      final record = (await outbox('shift.closed')).single;
      expect(record['expectedCents'], 101200);
      expect(record['countedCents'], 101200);
      expect(record['zNumber'], 1);
      expect(record['staffId'], manager.id);
      expect(await shifts.current(), isNull);

      final z = await shifts.zReport(id);
      expect(z.saleCount, 1);
      expect(z.netCents, 4400);
      expect(z.refundCount, 1);
      expect(z.refundCents, 2200);
      expect(z.cashOutCents, 1000);
      expect(z.movements.single.reason, 'SUPPLIER_PAYMENT');
      final totals = sumBy(z.taxes);
      expect(totals, 2200);
    },
  );

  test('E7: a flagged close waits for its note and blocks the till', () async {
    await shifts.open(staff: cashier, count: thousand, now: now);
    final counted = await shifts.confirmCount(
      shift: (await shifts.current())!,
      staff: cashier,
      count: const {50000: 1, 20000: 2},
      now: now,
    );
    expect(counted.status, 'COUNTED');
    expect(counted.flagged, isTrue);
    expect(counted.varianceCents, -10000);
    expect(await outbox('shift.closed'), isEmpty);
    await expectLater(sell(1), throwsA(isA<NoOpenShiftException>()));
    await expectLater(
      shifts.open(staff: cashier, count: thousand, now: now),
      throwsA(isA<ShiftAlreadyOpenException>()),
    );

    await shifts.finishClose(counted.id, 'Faltante revisado');
    expect((await outbox('shift.closed')).single['note'], 'Faltante revisado');
    expect(await shifts.current(), isNull);
  });

  test('Z numbers run with no gaps and the last count is remembered', () async {
    for (final n in [1, 2]) {
      await shifts.open(staff: cashier, count: thousand, now: now);
      final s = await shifts.confirmCount(
        shift: (await shifts.current())!,
        staff: cashier,
        count: thousand,
        now: now.add(Duration(hours: n)),
      );
      expect(s.zNumber, n);
    }
    expect(await shifts.lastCountedCents(), 100000);
    expect(formatZLabel('SUC1-02', 12), 'SUC1-02-Z0012');
  });
}

/// Base plus taxes of the IVA rows: what stayed sold after the refund.
int sumBy(List<TaxByRate> taxes) => taxes
    .where((t) => t.kind == 'IVA')
    .fold(0, (a, t) => a + t.baseCents + t.taxCents);
