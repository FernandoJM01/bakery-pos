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

  test(
    'E8: a day of 200 sales gives a Z report that matches to the centavo',
    () async {
      final id = await shifts.open(staff: cashier, count: thousand, now: now);
      final refunds = RefundRepository(db, null);
      const off = TicketDiscount(
        kind: DiscountKind.percent,
        value: 700,
        reason: DiscountReason.promotion,
      );
      final folios = <String>[];
      for (var i = 0; i < 200; i++) {
        final r = await sales.completeSale(
          ticket: Ticket(
            lines: [
              TicketLine(
                item: pastel,
                quantity: i % 3 + 1,
                discount: i % 4 == 0 ? off : null,
              ),
              TicketLine(item: galletas, quantity: i % 2 + 1),
              if (i % 5 == 0) const TicketLine(item: concha, quantity: 2),
            ],
            orderDiscount: i % 7 == 0 ? off : null,
          ),
          cashier: cashier,
          tenderedCents: 1000000,
          now: now.add(Duration(minutes: i)),
        );
        folios.add(r.folio);
      }
      Future<void> give(
        String folio,
        Map<int, int> units,
        RefundKind kind,
      ) async {
        final sale = await refunds.find(folio, online: false);
        await refunds.record(
          sale: sale,
          units: units,
          restock: const {},
          kind: kind,
          reason: RefundReason.quality,
          staffId: cashier.id,
          approverStaffId: manager.id,
          now: now.add(const Duration(hours: 5)),
        );
      }

      await give(folios[10], {1: 1}, RefundKind.refund);
      await give(folios[20], {1: 1, 2: 1}, RefundKind.refund);
      final toVoid = await refunds.find(folios[30], online: false);
      await give(folios[30], {
        for (final l in toVoid.lines) l.lineNo: l.left,
      }, RefundKind.voidSale);
      await shifts.addMovement(
        shiftId: id,
        kind: CashKind.cashIn,
        amountCents: 20000,
        reason: CashReason.changeFund,
        staffId: manager.id,
        now: now,
      );
      await shifts.addMovement(
        shiftId: id,
        kind: CashKind.cashOut,
        amountCents: 7550,
        reason: CashReason.bankDrop,
        staffId: manager.id,
        now: now,
      );

      final saleRows = await db.select(db.localSales).get();
      final lineRows = await db.select(db.localSaleLines).get();
      final refundRows = await db.select(db.localRefunds).get();
      final z = await shifts.zReport(id);
      int sum<T>(Iterable<T> xs, int Function(T) f) =>
          xs.fold(0, (a, x) => a + f(x));

      expect(z.saleCount, 200);
      expect(z.grossCents, sum(saleRows, (s) => s.grossCents));
      expect(z.discountCents, sum(saleRows, (s) => s.discountCents));
      expect(z.netCents, sum(saleRows, (s) => s.totalCents));
      expect(z.refundCount, 2);
      expect(z.voidCount, 1);
      final back = sum(refundRows, (r) => r.totalCents);
      expect(z.refundCents + z.voidCents, back);
      expect(z.cashInCents, 20000);
      expect(z.cashOutCents, 7550);

      // Tax parts always add back to the money: sold minus returned.
      final parts = sum(
        z.taxes.where((t) => t.kind == 'IVA'),
        (t) => t.baseCents + t.taxCents,
      );
      expect(parts, z.netCents - back);
      expect(z.grossCents - z.discountCents, z.netCents);
      expect(
        sum(lineRows, (l) => l.baseCents + l.iepsCents + l.ivaCents),
        z.netCents,
      );

      final expected = 100000 + z.netCents + 20000 - 7550 - back;
      final closed = await shifts.confirmCount(
        shift: (await shifts.current())!,
        staff: manager,
        count: {100000: expected ~/ 100000, 50: (expected % 100000) ~/ 50},
        now: now.add(const Duration(hours: 9)),
      );
      expect(closed.expectedCents, expected);
    },
  );

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
