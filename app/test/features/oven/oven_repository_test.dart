import 'dart:convert';

import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/features/oven/data/oven_repository.dart';
import 'package:bakery_pos/features/oven/domain/oven_fee.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sale/sale_test_data.dart';

const turkeyRule = '0192e2b0-0300-7000-8000-0000000000f1';
const turkeyVariant = '0192e2b0-0300-7000-8000-0000000000e1';

Future<LocalOvenRule> seedOven(AppDatabase db) async {
  await db.setSessionValue(ovenEnabledKey, 'true');
  await db
      .into(db.localOvenRules)
      .insert(
        LocalOvenRulesCompanion.insert(
          id: turkeyRule,
          name: 'Pavo',
          baseCents: 8000,
          perKgCents: 4000,
          variantId: turkeyVariant,
          productName: 'Servicio de horno',
          ivaRateId: iva16,
          ivaBp: 1600,
          iepsRateId: const Value(null),
          iepsBp: 0,
        ),
      );
  return (await db.select(db.localOvenRules).get()).single;
}

void main() {
  late AppDatabase db;
  late OvenRepository oven;
  late LocalOvenRule rule;
  final now = DateTime(2026, 12, 24, 10, 0);

  Future<List<(String, Map<String, dynamic>)>> outbox() async => [
    for (final r in await db.select(db.outboxEntries).get())
      (r.type, jsonDecode(r.payload) as Map<String, dynamic>),
  ];

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedTill(db);
    rule = await seedOven(db);
    oven = OvenRepository(db, null);
  });
  tearDown(() => db.close());

  test('the fee is a base plus the price per kilo, rounded half up', () {
    expect(ovenFee(8000, 4000, 1000), 12000);
    expect(ovenFee(8000, 4000, 3200), 20800);
    expect(ovenFee(0, 3333, 1500), 5000);
    expect(ovenFee(0, 3333, 1499), 4996);
  });

  test('a phone keeps digits, + and spaces; a short one is invalid', () {
    expect(cleanOvenPhone(''), isNull);
    expect(cleanOvenPhone('55-1234-5678'), '5512345678');
    expect(cleanOvenPhone('(55) 1234 5678'), '55 1234 5678');
    expect(cleanOvenPhone('123'), '');
  });

  test(
    'M8.1: paying at drop-off is a sale of the rule and the dish carries it',
    () async {
      final fee = ovenFee(rule.baseCents, rule.perKgCents, 3200);
      final receipt = await oven.payFee(
        rule: rule,
        feeCents: fee,
        cashier: cashier,
        tenderedCents: 25000,
        now: now,
      );
      expect(receipt.totals.totalCents, 20800);
      expect(receipt.changeCents, 4200);
      final id = await oven.receive(
        tag: ' 12 ',
        customerName: 'Familia López',
        phone: '55-1234-5678',
        description: 'Pavo en charola de aluminio',
        rule: rule,
        weightGrams: 3200,
        requestedAt: DateTime(2026, 12, 24, 18),
        staffId: cashier.id,
        feeSaleId: receipt.saleId,
        now: now,
      );
      final [(saleType, sale), (type, p)] = await outbox();
      expect(saleType, 'sale.completed');
      final line = (sale['lines'] as List).single as Map<String, dynamic>;
      expect(line['variantId'], turkeyVariant);
      expect(line['unitPriceCents'], 20800);
      expect(type, 'oven.received');
      expect(p['tag'], '12');
      expect(p['phone'], '5512345678');
      expect(p['feeCents'], 20800);
      expect(p['feeSaleId'], receipt.saleId);
      final [d] = await oven.dishes();
      expect(d.id, id);
      expect(d.paid, isTrue);
      expect(d.status, 'RECEIVED');
    },
  );

  test('M8.2: steps only move forward, and pickup pays when unpaid', () async {
    final id = await oven.receive(
      tag: '7',
      customerName: 'Doña Rosa',
      description: 'Pierna',
      rule: rule,
      weightGrams: 1000,
      requestedAt: DateTime(2026, 12, 24, 14),
      staffId: cashier.id,
      now: now,
    );
    await oven.mark(id, 'IN_OVEN', manager.id, now);
    await oven.mark(id, 'READY', manager.id, now.add(const Duration(hours: 2)));
    await oven.mark(
      id,
      'IN_OVEN',
      manager.id,
      now.add(const Duration(hours: 3)),
    );
    var [d] = await oven.dishes();
    expect(d.status, 'READY');
    expect(d.readyAt, isNotNull);
    expect(d.paid, isFalse);
    expect(d.feeCents, 12000);
    final receipt = await oven.payFee(
      rule: rule,
      feeCents: d.feeCents,
      cashier: cashier,
      tenderedCents: 12000,
      now: now,
    );
    await oven.pickUp(id, cashier.id, now, feeSaleId: receipt.saleId);
    [d] = await oven.dishes();
    expect(d.status, 'PICKED_UP');
    expect(d.paid, isTrue);
    final types = [for (final (t, _) in await outbox()) t];
    expect(types, [
      'oven.received',
      'oven.status',
      'oven.status',
      'oven.status',
      'sale.completed',
      'oven.picked_up',
    ]);
  });
}
