import 'dart:convert';

import 'package:bakery_pos/core/api/generated/models/sale_completed_payload.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/features/sale/data/sale_repository.dart';
import 'package:bakery_pos/features/sale/domain/sale_totals.dart';
import 'package:bakery_pos/features/sale/domain/ticket.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sale_test_data.dart';

Ticket ticketOf(List<(SaleItem, int)> items, {TicketDiscount? order}) => Ticket(
  lines: [for (final (it, q) in items) TicketLine(item: it, quantity: q)],
  orderDiscount: order,
);

void main() {
  late AppDatabase db;
  late SaleRepository repo;
  final now = DateTime.utc(2026, 11, 2, 15);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = SaleRepository(db);
    await seedTill(db);
  });
  tearDown(() => db.close());

  test('D2: one sale writes the sale, lines, payment, folio and one outbox record together', () async {
    const promo = TicketDiscount(
      kind: DiscountKind.percent,
      value: 1000,
      reason: DiscountReason.promotion,
    );
    final ticket = Ticket(
      lines: const [
        TicketLine(item: concha, quantity: 2, discount: promo),
        TicketLine(item: galletas, quantity: 3),
        TicketLine(item: pastel, quantity: 1),
      ],
      orderDiscount: const TicketDiscount(
        kind: DiscountKind.amount,
        value: 500,
        reason: DiscountReason.frequentCustomer,
      ),
      voided: [
        VoidedLine(
          variantId: concha.variantId,
          quantity: 1,
          unitPriceCents: 1500,
          voidedAt: now,
          staffId: cashier.id,
        ),
      ],
    );
    final receipt = await repo.completeSale(
      ticket: ticket,
      cashier: cashier,
      tenderedCents: 10000,
      now: now,
    );

    expect(receipt.folio, 'SUC1-02-000001');
    expect(receipt.totals.totalCents, 6800);
    expect(receipt.changeCents, 3200);

    final sale = await db.select(db.localSales).getSingle();
    expect(sale.id, receipt.saleId);
    expect(sale.totalCents, 6800);
    expect(sale.discountCents, 800);
    expect(sale.tenderedCents, 10000);
    expect(await db.select(db.localSaleLines).get(), hasLength(3));
    final discounts = await db.select(db.localSaleDiscounts).get();
    expect(discounts.map((d) => (d.lineNo, d.kind, d.cents)).toSet(), {
      (1, 'PERCENT', 300),
      (null, 'AMOUNT', 500),
    });
    expect(await repo.lastFolioNumber(), 1);

    final outbox = await db.select(db.outboxEntries).get();
    expect(outbox, hasLength(1));
    expect(outbox.single.id, receipt.saleId);
    expect(outbox.single.type, 'sale.completed');
    final payload = jsonDecode(outbox.single.payload) as Map<String, dynamic>;
    // The generated contract model reads it back without loss.
    final parsed = SaleCompletedPayload.fromJson(payload);
    expect(parsed.folio, 'SUC1-02-000001');
    expect(parsed.totalCents, 6800);
    expect(parsed.lines.map((l) => l.orderDiscountCents), [185, 164, 151]);
    expect(parsed.payments.single.changeCents, 3200);
    expect(parsed.voidedLines, hasLength(1));
    expect(payload.keys.toSet(), {
      'folio',
      'folioNumber',
      'cashierStaffId',
      'shiftId',
      'lines',
      'orderDiscount',
      'voidedLines',
      'grossCents',
      'discountCents',
      'totalCents',
      'payments',
    });
  });

  test(
    'D2: a failure in any part leaves none of it, and the folio is not used',
    () async {
      // An earlier record stays; a failing line insert undoes the whole sale.
      await db
          .into(db.outboxEntries)
          .insert(
            OutboxEntriesCompanion.insert(
              id: 'other',
              type: 'audit.offline_event',
              occurredAt: now,
              payload: '{}',
            ),
          );
      await db.customStatement(
        "CREATE TRIGGER fail_lines BEFORE INSERT ON local_sale_lines "
        "BEGIN SELECT RAISE(ABORT, 'disk full'); END",
      );
      await expectLater(
        repo.completeSale(
          ticket: ticketOf([(concha, 1)]),
          cashier: cashier,
          tenderedCents: 1500,
          now: now,
        ),
        throwsA(anything),
      );
      expect(await db.select(db.localSales).get(), isEmpty);
      expect(await db.select(db.localSaleLines).get(), isEmpty);
      expect(await repo.lastFolioNumber(), 0);
      expect(await db.select(db.outboxEntries).get(), hasLength(1));

      await db.customStatement('DROP TRIGGER fail_lines');
      final ok = await repo.completeSale(
        ticket: ticketOf([(concha, 1)]),
        cashier: cashier,
        tenderedCents: 1500,
        now: now,
      );
      expect(ok.folio, 'SUC1-02-000001');
    },
  );

  test('D9: 1,000 sales take folios 000001 to 001000 with no gaps; discarded tickets take none', () async {
    for (var i = 0; i < 1000; i++) {
      if (i % 100 == 50) {
        await repo.discardTicket(ticketOf([(galletas, 2)]), cashier.id, now);
      }
      await repo.completeSale(
        ticket: ticketOf([(concha, 1 + i % 3)]),
        cashier: cashier,
        tenderedCents: 5000,
        now: now.add(Duration(seconds: i)),
      );
    }
    final numbers =
        await (db.selectOnly(db.localSales)
              ..addColumns([db.localSales.folioNumber])
              ..orderBy([OrderingTerm(expression: db.localSales.folioNumber)]))
            .map((r) => r.read(db.localSales.folioNumber)!)
            .get();
    expect(numbers, [for (var n = 1; n <= 1000; n++) n]);
    final last = await (db.select(
      db.localSales,
    )..where((s) => s.folioNumber.equals(1000))).getSingle();
    expect(last.folio, 'SUC1-02-001000');

    final outbox = await db.select(db.outboxEntries).get();
    expect(outbox.where((o) => o.type == 'sale.completed'), hasLength(1000));
    final discards = outbox.where((o) => o.type == 'audit.offline_event');
    expect(discards, hasLength(10));
    expect(jsonDecode(discards.first.payload), {
      'action': 'sale.ticket_discarded',
      'staffId': cashier.id,
      'ticket': {'lineCount': 1, 'amountCents': 1600},
    });
  });

  test(
    'refuses to sell without a folio prefix or with too little cash',
    () async {
      await db.customStatement(
        "DELETE FROM session_state_entries WHERE key = '$folioPrefixKey'",
      );
      await expectLater(
        repo.completeSale(
          ticket: ticketOf([(concha, 1)]),
          cashier: cashier,
          tenderedCents: 1500,
          now: now,
        ),
        throwsA(isA<NoFolioPrefixException>()),
      );
      await db.setSessionValue(folioPrefixKey, 'SUC1-02');
      await expectLater(
        repo.completeSale(
          ticket: ticketOf([(concha, 1)]),
          cashier: cashier,
          tenderedCents: 1499,
          now: now,
        ),
        throwsA(isA<InsufficientCashException>()),
      );
      expect(await db.select(db.localSales).get(), isEmpty);
    },
  );
}
