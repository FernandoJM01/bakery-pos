import 'dart:convert';

import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/features/cash/data/shift_repository.dart';
import 'package:bakery_pos/features/orders/data/orders_repository.dart';
import 'package:bakery_pos/features/sale/data/refund_repository.dart';
import 'package:bakery_pos/features/sale/data/sale_repository.dart';
import 'package:bakery_pos/features/stock/domain/stock_math.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sale/sale_test_data.dart';

void main() {
  late AppDatabase db;
  late OrdersRepository orders;
  final now = DateTime(2026, 11, 9, 7, 25);
  final today = localDayOf(now);

  Future<void> ticket(
    String id, {
    String day = '',
    String status = 'PENDING',
    int balance = 10000,
  }) => db
      .into(db.localOrderTickets)
      .insert(
        LocalOrderTicketsCompanion.insert(
          id: id,
          orderId: 'o-$id',
          customerId: 'c1',
          customerName: 'Fonda Doña Mary',
          balanceCents: balance,
          dueDate: day.isEmpty ? today : day,
          pickupTime: '07:30',
          status: status,
          totalCents: 4500,
          linesJson: jsonEncode([
            {
              'lineNo': 1,
              'variantId': concha.variantId,
              'productName': 'Concha',
              'variantName': 'Pieza',
              'quantity': 3,
              'unitPriceCents': 1500,
              'ivaRateId': iva0,
              'ivaBp': 0,
              'iepsBp': 0,
            },
          ]),
        ),
      );

  Future<List<Map<String, dynamic>>> outbox(String type) async => [
    for (final r in await db.select(db.outboxEntries).get())
      if (r.type == type) jsonDecode(r.payload) as Map<String, dynamic>,
  ];

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedTill(db);
    orders = OrdersRepository(db, null);
  });
  tearDown(() => db.close());

  test('G6: a pickup offline is a sale paid from the balance, copied from the ticket', () async {
    await ticket('t1');
    final [t] = await orders.today(now);
    expect(t.pending, isTrue);
    final receipt = await orders.pickUp(ticket: t, cashier: cashier, now: now);
    expect(receipt.prepaid, isTrue);
    expect(receipt.tenderedCents, 0);
    final sale = (await outbox('sale.completed')).single;
    expect(sale['orderTicketId'], 't1');
    expect((sale['payments'] as List).single, {
      'method': 'PREPAID',
      'amountCents': 4500,
      'tenderedCents': 0,
      'changeCents': 0,
    });
    final line = (sale['lines'] as List).single as Map;
    expect(line['quantity'], 3);
    expect(line['unitPriceCents'], 1500);

    final [after] = await orders.today(now);
    expect(after.pending, isFalse);
    expect(after.balanceCents, 5500);
  });

  test(
    'G4: a prepayment needs a shift, raises the balance and counts as cash',
    () async {
      await ticket('t1');
      await orders.prepay(
        customerId: 'c1',
        customerName: 'Fonda Doña Mary',
        amountCents: 20000,
        staffId: cashier.id,
        now: now,
      );
      expect((await outbox('order.prepaid')).single['amountCents'], 20000);
      expect((await orders.today(now)).single.balanceCents, 30000);

      // A pickup puts no cash in the drawer; the prepayment does.
      await orders.pickUp(
        ticket: (await orders.today(now)).single,
        cashier: cashier,
        now: now,
      );
      final shifts = ShiftRepository(db);
      final closed = await shifts.confirmCount(
        shift: (await shifts.current())!,
        staff: cashier,
        count: const {20000: 1},
        now: now,
      );
      expect(closed.expectedCents, 20000);
      expect(closed.varianceCents, 0);
      final z = await shifts.zReport('test-shift');
      expect(z.prepaidCollectedCents, 20000);
      expect(z.saleCount, 1);

      await expectLater(
        orders.prepay(
          customerId: 'c1',
          customerName: 'x',
          amountCents: 100,
          staffId: cashier.id,
          now: now,
        ),
        throwsA(isA<NoOpenShiftException>()),
      );
    },
  );

  test(
    'a refund of a pickup goes back to the balance, not the drawer',
    () async {
      await ticket('t1');
      final receipt = await orders.pickUp(
        ticket: (await orders.today(now)).single,
        cashier: cashier,
        now: now,
      );
      final refunds = RefundRepository(db, null);
      final sale = await refunds.find(receipt.folio, online: false);
      expect(sale.cash, isFalse);
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
      final shifts = ShiftRepository(db);
      final closed = await shifts.confirmCount(
        shift: (await shifts.current())!,
        staff: cashier,
        count: const {50: 0},
        now: now,
      );
      expect(closed.expectedCents, 0);
    },
  );

  test(
    'M7.4: the baker sees today\'s totals; old and later tickets are left out',
    () async {
      await ticket('t1');
      await ticket('t2');
      await ticket('t3', day: daysBefore(today, -1));
      final totals = await orders.todayTotals(now);
      expect(totals[concha.variantId]!.quantity, 6);
      final listed = await orders.today(now);
      expect(listed.map((t) => t.row.id), ['t1', 't2']);
    },
  );
}
