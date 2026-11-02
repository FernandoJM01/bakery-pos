import 'dart:convert';

import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/domain/till_auth_state.dart';
import 'package:bakery_pos/features/sale/domain/ticket.dart';
import 'package:bakery_pos/features/stock/data/stock_repository.dart';
import 'package:bakery_pos/features/stock/presentation/production_screen.dart';
import 'package:bakery_pos/features/stock/domain/stock_math.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sale/sale_test_data.dart';

class _Session extends TillSessionNotifier {
  _Session(this.value);
  final TillSession value;
  @override
  TillSession? build() => value;
}

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 11, 2, 9);

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 5; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 15)),
      );
      await t.pump(const Duration(milliseconds: 300));
    }
  }

  Future<void> pump(WidgetTester t, List<String> permissions) async {
    t.view.physicalSize = const Size(1280, 900);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.runAsync(() => seedTill(db));
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          tillDatabaseProvider.overrideWithValue(db),
          tillSessionProvider.overrideWith(
            () => _Session(
              TillSession(
                staff: cashier,
                permissions: permissions,
                isOffline: true,
              ),
            ),
          ),
          saleClockProvider.overrideWithValue(() => now),
          stockRepositoryProvider.overrideWith(
            (ref) => StockRepository(db, null),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ProductionScreen()),
        ),
      ),
    );
    await settle(t);
  }

  testWidgets('F1: a baker records output in 2 taps, in trays when set', (
    t,
  ) async {
    await pump(t, const ['stock.production_entry']);
    await t.runAsync(
      () =>
          (db.update(db.catalogVariants)
                ..where((v) => v.id.equals(concha.variantId)))
              .write(const CatalogVariantsCompanion(unitsPerTray: Value(18))),
    );
    await t.pumpWidget(const SizedBox());
    await pump2(t, db, now);

    var taps = 0;
    Future<void> tap(String key) async {
      taps++;
      await t.runAsync(() => t.tap(find.byKey(Key(key))));
      await settle(t);
    }

    await tap('produce-${concha.variantId}');
    expect(find.text('2 charolas'), findsOneWidget);
    await tap('amount-2');
    expect(taps, 2);

    final row = await t.runAsync(() => db.select(db.outboxEntries).getSingle());
    final p = jsonDecode(row!.payload) as Map<String, dynamic>;
    expect(row.type, 'stock.produced');
    expect(p['quantity'], 36);
    expect(p['producedOn'], localDayOf(now));
    expect(find.text('En existencia: 36'), findsOneWidget);
  });

  testWidgets('M6.3: a manager confirms the waste list and it empties', (
    t,
  ) async {
    await pump(t, const [
      'stock.production_entry',
      'stock.waste',
      'stock.count_adjust',
    ]);
    await t.runAsync(() async {
      await db
          .update(db.catalogProducts)
          .write(
            const CatalogProductsCompanion(dayOldWasteAfterDays: Value(2)),
          );
      await db
          .into(db.localLots)
          .insert(
            LocalLotsCompanion.insert(
              id: 'old',
              variantId: concha.variantId,
              producedOn: daysBefore(localDayOf(DateTime.now()), 3),
              quantityLeft: 5,
            ),
          );
    });
    await t.pumpWidget(const SizedBox());
    await pump2(
      t,
      db,
      now,
      permissions: const [
        'stock.production_entry',
        'stock.waste',
        'stock.count_adjust',
      ],
    );
    await t.tap(find.byKey(const Key('tab-inventory')));
    await settle(t);
    expect(find.byKey(const Key('due-old')), findsOneWidget);
    await t.runAsync(() => t.tap(find.byKey(const Key('due-confirm-old'))));
    await settle(t);
    final row = await t.runAsync(() => db.select(db.outboxEntries).getSingle());
    final p = jsonDecode(row!.payload) as Map<String, dynamic>;
    expect(p['reason'], 'EXPIRED');
    expect(p['lotId'], 'old');
    expect(p['quantity'], 5);
    expect(find.byKey(const Key('due-old')), findsNothing);
  });
}

/// Mounts the screen on a database that is already seeded.
Future<void> pump2(
  WidgetTester t,
  AppDatabase db,
  DateTime now, {
  List<String> permissions = const ['stock.production_entry'],
}) async {
  await t.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        tillDatabaseProvider.overrideWithValue(db),
        tillSessionProvider.overrideWith(
          () => _Session(
            TillSession(
              staff: cashier,
              permissions: permissions,
              isOffline: true,
            ),
          ),
        ),
        saleClockProvider.overrideWithValue(() => now),
        stockRepositoryProvider.overrideWith(
          (ref) => StockRepository(db, null),
        ),
      ],
      child: const MaterialApp(
        locale: Locale('es', 'MX'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ProductionScreen()),
      ),
    ),
  );
  for (var i = 0; i < 5; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await t.pump(const Duration(milliseconds: 300));
  }
}
