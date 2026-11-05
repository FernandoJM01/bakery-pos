import 'dart:convert';

import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/features/sale/data/sale_repository.dart';
import 'package:bakery_pos/features/sale/domain/ticket.dart';
import 'package:bakery_pos/features/stock/data/stock_repository.dart';
import 'package:bakery_pos/features/stock/domain/stock_math.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sale/sale_test_data.dart';

void main() {
  late AppDatabase db;
  late StockRepository stock;
  final now = DateTime(2026, 11, 2, 9);
  final today = localDayOf(now);
  final yesterday = daysBefore(today, 1);

  Future<void> setRule({int? after, int? bp, int? waste}) async {
    await (db.update(db.catalogProducts)).write(
      CatalogProductsCompanion(
        dayOldDiscountAfterDays: Value(after),
        dayOldDiscountBp: Value(bp),
        dayOldWasteAfterDays: Value(waste),
      ),
    );
  }

  Future<void> lot(String id, String day, int left, [SaleItem item = concha]) =>
      db
          .into(db.localLots)
          .insert(
            LocalLotsCompanion.insert(
              id: id,
              variantId: item.variantId,
              producedOn: day,
              quantityLeft: left,
            ),
          );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedTill(db);
    stock = StockRepository(db, null);
  });
  tearDown(() => db.close());

  test('F1: an entry works offline and shows in the stock at once', () async {
    await stock.produce(
      variantId: concha.variantId,
      quantity: 24,
      staffId: cashier.id,
      now: now,
    );
    final rows = await db.select(db.outboxEntries).get();
    final p = jsonDecode(rows.single.payload) as Map<String, dynamic>;
    expect(rows.single.type, 'stock.produced');
    expect(p['producedOn'], today);
    expect((await stock.view(now))[concha.variantId]!.fresh, 24);
  });

  test(
    'M6.1: age splits fresh, day-old and waste with no connection',
    () async {
      await setRule(after: 1, bp: 3000, waste: 3);
      await lot('a', today, 4);
      await lot('b', yesterday, 3);
      await lot('c', daysBefore(today, 3), 2);
      final s = (await stock.view(now))[concha.variantId]!;
      expect(s.fresh, 4);
      expect(s.dayOld, 5);
      expect(s.wasteDue, 2);
      final tomorrow = await stock.view(now.add(const Duration(days: 1)));
      expect(tomorrow[concha.variantId]!.fresh, 0);
    },
  );

  test('M6.3: the waste list holds lots past their last day', () async {
    await setRule(after: 1, bp: 3000, waste: 2);
    await lot('a', today, 4);
    await lot('c', daysBefore(today, 2), 2);
    final due = await stock.wasteList(now);
    expect(due.map((d) => d.lot.id), ['c']);
    await stock.waste(
      variantId: concha.variantId,
      quantity: 2,
      reason: 'EXPIRED',
      lotId: 'c',
      staffId: manager.id,
      now: now,
    );
    expect(await stock.wasteList(now), isEmpty);
  });

  test(
    'an unsynced sale lowers the view, oldest first and past zero',
    () async {
      await setRule(after: 1, bp: 3000);
      await lot('a', today, 2);
      await lot('b', yesterday, 1);
      await SaleRepository(db).completeSale(
        ticket: const Ticket(lines: [TicketLine(item: concha, quantity: 2)]),
        cashier: cashier,
        tenderedCents: 100000,
        now: now,
      );
      final s = (await stock.view(now))[concha.variantId]!;
      expect(s.dayOld, 0);
      expect(s.fresh, 1);

      await SaleRepository(db).completeSale(
        ticket: const Ticket(lines: [TicketLine(item: concha, quantity: 4)]),
        cashier: cashier,
        tenderedCents: 100000,
        now: now,
      );
      final after = (await stock.view(now))[concha.variantId]!;
      expect(after.onHand, -3);
    },
  );

  test('F11: the sale line carries day-old and the full price', () async {
    await SaleRepository(db).completeSale(
      ticket: const Ticket(
        lines: [
          TicketLine(
            item: SaleItem(
              variantId: 'v',
              productName: 'Concha',
              variantName: 'Pieza',
              unitPriceCents: 1050,
              ivaRateId: iva0,
              ivaBp: 0,
              dayOld: true,
              fullPriceCents: 1500,
            ),
            quantity: 1,
          ),
        ],
      ),
      cashier: cashier,
      tenderedCents: 100000,
      now: now,
    );
    final row = (await db.select(db.outboxEntries).get()).single;
    final line =
        ((jsonDecode(row.payload) as Map)['lines'] as List).single as Map;
    expect(line['dayOld'], isTrue);
    expect(line['fullPriceCents'], 1500);
    expect(line['unitPriceCents'], 1050);
  });
}
