import 'dart:convert';
import 'dart:io';

import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/features/sale/data/held_ticket_repository.dart';
import 'package:bakery_pos/features/sale/data/refund_repository.dart';
import 'package:bakery_pos/features/sale/data/sale_repository.dart';
import 'package:bakery_pos/features/sale/domain/sale_totals.dart';
import 'package:bakery_pos/features/sale/domain/ticket.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sale_test_data.dart';

const promo = TicketDiscount(
  kind: DiscountKind.percent,
  value: 1000,
  reason: DiscountReason.promotion,
);

void main() {
  final now = DateTime(2026, 11, 2, 12);

  group('held tickets', () {
    test('D6: a held ticket survives closing the database and resumes with its lines and discounts', () async {
      final dir = await Directory.systemTemp.createTemp('held');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/till.sqlite');

      var db = AppDatabase(NativeDatabase(file));
      const ticket = Ticket(
        lines: [
          TicketLine(item: concha, quantity: 2, discount: promo),
          TicketLine(item: pastel, quantity: 1),
        ],
        orderDiscount: TicketDiscount(
          kind: DiscountKind.amount,
          value: 300,
          reason: DiscountReason.other,
          note: 'Pan del día anterior',
        ),
      );
      final id = await HeldTicketRepository(
        db,
      ).hold(ticket, name: 'Señora del rebozo', staffId: cashier.id, now: now);
      await db.close();

      // Another cashier on the same till, after a restart.
      db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);
      final repo = HeldTicketRepository(db);
      final held = await repo.list();
      expect(held.single.id, id);
      expect(held.single.name, 'Señora del rebozo');
      expect(held.single.lineCount, 2);
      expect(held.single.totalCents, ticket.totals.totalCents);

      final back = (await repo.resume(id))!;
      expect(back.lines.map((l) => (l.item.variantId, l.quantity)), [
        (concha.variantId, 2),
        (pastel.variantId, 1),
      ]);
      expect(back.lines.first.discount!.value, 1000);
      expect(back.orderDiscount!.note, 'Pan del día anterior');
      expect(back.totals.totalCents, ticket.totals.totalCents);
      expect(await repo.list(), isEmpty);
      // Held and resumed tickets take no folio and send nothing.
      expect(await db.select(db.outboxEntries).get(), isEmpty);
    });

    test('discarding a held ticket records it', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = HeldTicketRepository(db);
      final id = await repo.hold(
        const Ticket(lines: [TicketLine(item: galletas, quantity: 3)]),
        staffId: cashier.id,
        now: now,
      );
      await repo.discard(id, staffId: manager.id, now: now);
      expect(await repo.list(), isEmpty);
      final event = await db.select(db.outboxEntries).getSingle();
      expect(jsonDecode(event.payload), {
        'action': 'sale.ticket_discarded',
        'staffId': manager.id,
        'ticket': {'lineCount': 1, 'amountCents': 2400},
      });
    });
  });

  group('refunds and voids', () {
    late AppDatabase db;
    late FakeApiInterceptor fake;
    late RefundRepository refunds;
    late SaleRepository sales;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await seedTill(db);
      fake = FakeApiInterceptor();
      refunds = RefundRepository(db, RestClient(Dio()..interceptors.add(fake)));
      sales = SaleRepository(db);
    });
    tearDown(() => db.close());

    Future<SaleReceipt> sell(List<TicketLine> lines, {DateTime? at}) =>
        sales.completeSale(
          ticket: Ticket(lines: lines),
          cashier: cashier,
          tenderedCents: 100000,
          now: at ?? now,
        );

    Future<Map<String, dynamic>> lastOutbox() async {
      final rows = await db.select(db.outboxEntries).get();
      return jsonDecode(
        rows.lastWhere((r) => r.type == 'sale.refunded').payload,
      ) as Map<String, dynamic>;
    }

    test(
      'D7: partial refund of 1 of 3 offline, then the rest, ends REFUNDED',
      () async {
        final receipt = await sell(const [
          TicketLine(item: pastel, quantity: 3),
          TicketLine(item: concha, quantity: 1),
        ]);
        var sale = await refunds.find(receipt.folio, online: false);
        expect(sale.madeHere, isTrue);

        final one = await refunds.record(
          sale: sale,
          units: {1: 1},
          restock: {1},
          kind: RefundKind.refund,
          reason: RefundReason.quality,
          staffId: cashier.id,
          approverStaffId: manager.id,
          now: now,
        );
        expect(one.totalCents, 2200);
        final payload = await lastOutbox();
        expect(payload['saleId'], receipt.saleId);
        expect(payload['approverStaffId'], manager.id);
        expect(payload['lines'], [
          {
            'lineNo': 1,
            'quantity': 1,
            'amountCents': 2200,
            'baseCents': 1756,
            'iepsCents': 141,
            'ivaCents': 303,
            'restock': true,
          },
        ]);
        var stored = await (db.select(
          db.localSales,
        )..where((s) => s.id.equals(receipt.saleId))).getSingle();
        expect(stored.status, 'PARTIALLY_REFUNDED');

        // More than is left is refused on the till.
        sale = await refunds.find(receipt.folio, online: false);
        await expectLater(
          refunds.record(
            sale: sale,
            units: {1: 3},
            restock: const {},
            kind: RefundKind.refund,
            reason: RefundReason.quality,
            staffId: manager.id,
            now: now,
          ),
          throwsA(isA<TooManyUnits>()),
        );

        final rest = await refunds.record(
          sale: sale,
          units: {1: 2, 2: 1},
          restock: const {},
          kind: RefundKind.refund,
          reason: RefundReason.customerReturn,
          staffId: manager.id,
          now: now,
        );
        expect(rest.totalCents, 4400 + 1500);
        stored = await (db.select(
          db.localSales,
        )..where((s) => s.id.equals(receipt.saleId))).getSingle();
        expect(stored.status, 'REFUNDED');
        expect(stored.refundedCents, stored.totalCents);
        sale = await refunds.find(receipt.folio, online: false);
        expect(sale.fullyReturned, isTrue);
      },
    );

    test(
      "D7: online, another till's sale is found through the server",
      () async {
        fake.catalog.sales.add({
          'id': '0192e2b0-0000-7000-8000-00000000s001',
          'folio': 'SUC1-01-000007',
          'folioNumber': 7,
          'cashierStaffId': cashier.id,
          'occurredAt': now.toUtc().toIso8601String(),
          'grossCents': 6600,
          'discountCents': 0,
          'totalCents': 6600,
          'payments': [
            {
              'method': 'CASH',
              'amountCents': 6600,
              'tenderedCents': 6600,
              'changeCents': 0,
            },
          ],
          'lines': [
            {
              'lineNo': 1,
              'variantId': pastel.variantId,
              'productName': 'Pastel',
              'variantName': 'Rebanada',
              'quantity': 3,
              'unitPriceCents': 2200,
              'grossCents': 6600,
              'lineDiscountCents': 0,
              'orderDiscountCents': 0,
              'netCents': 6600,
              'ivaRateId': iva16,
              'ivaBp': 1600,
              'iepsRateId': ieps8,
              'iepsBp': 800,
              'baseCents': 5268,
              'iepsCents': 422,
              'ivaCents': 910,
            },
          ],
        });
        await expectLater(
          refunds.find('SUC1-01-000007', online: false),
          throwsA(isA<SaleNotFound>()),
        );
        final sale = await refunds.find('suc1-01-000007', online: true);
        expect(sale.madeHere, isFalse);
        final r = await refunds.record(
          sale: sale,
          units: {1: 1},
          restock: const {},
          kind: RefundKind.refund,
          reason: RefundReason.wrongItem,
          staffId: cashier.id,
          approverStaffId: manager.id,
          now: now,
        );
        expect(r.totalCents, 2200);
        expect((await lastOutbox())['saleId'], sale.id);
        expect(await db.select(db.localRefunds).get(), hasLength(1));
      },
    );

    test('D8: a cancel takes every unit, only on this till and today, and marks VOIDED', () async {
      final today = await sell(const [
        TicketLine(item: pastel, quantity: 2),
        TicketLine(item: galletas, quantity: 1),
      ]);
      final yesterday = await sell(const [
        TicketLine(item: concha, quantity: 1),
      ], at: now.subtract(const Duration(days: 1)));

      final old = await refunds.find(yesterday.folio, online: false);
      await expectLater(
        refunds.record(
          sale: old,
          units: {1: 1},
          restock: const {},
          kind: RefundKind.voidSale,
          reason: RefundReason.cashierError,
          staffId: manager.id,
          now: now,
        ),
        throwsA(
          isA<VoidNotAllowed>().having(
            (e) => e.reason,
            'reason',
            VoidRule.otherDay,
          ),
        ),
      );

      final sale = await refunds.find(today.folio, online: false);
      await expectLater(
        refunds.record(
          sale: sale,
          units: {1: 1, 2: 1},
          restock: const {},
          kind: RefundKind.voidSale,
          reason: RefundReason.cashierError,
          staffId: manager.id,
          now: now,
        ),
        throwsA(isA<VoidNotAllowed>()),
      );

      final other = RefundableSale(
        id: 'x',
        folio: 'SUC1-01-000001',
        occurredAt: now,
        status: 'COMPLETED',
        lines: sale.lines,
        madeHere: false,
      );
      await expectLater(
        refunds.record(
          sale: other,
          units: {1: 2, 2: 1},
          restock: const {},
          kind: RefundKind.voidSale,
          reason: RefundReason.cashierError,
          staffId: manager.id,
          now: now,
        ),
        throwsA(
          isA<VoidNotAllowed>().having(
            (e) => e.reason,
            'reason',
            VoidRule.otherTill,
          ),
        ),
      );

      final done = await refunds.record(
        sale: sale,
        units: {1: 2, 2: 1},
        restock: const {},
        kind: RefundKind.voidSale,
        reason: RefundReason.cashierError,
        staffId: cashier.id,
        approverStaffId: manager.id,
        now: now,
      );
      expect(done.totalCents, today.totals.totalCents);
      final stored = await (db.select(
        db.localSales,
      )..where((s) => s.id.equals(today.saleId))).getSingle();
      expect(stored.status, 'VOIDED');
      expect((await lastOutbox())['kind'], 'VOID');
    });
  });
}
