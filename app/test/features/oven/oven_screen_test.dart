import 'dart:convert';

import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/domain/till_auth_state.dart';
import 'package:bakery_pos/features/oven/data/oven_repository.dart';
import 'package:bakery_pos/features/oven/presentation/oven_screen.dart';
import 'package:bakery_pos/features/sale/domain/ticket.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sale/sale_test_data.dart';
import 'oven_repository_test.dart' show seedOven, turkeyRule;

class _Session extends TillSessionNotifier {
  _Session(this.value);
  final TillSession value;
  @override
  TillSession? build() => value;
}

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 12, 24, 10);

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 6; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 15)),
      );
      await t.pump(const Duration(milliseconds: 300));
    }
  }

  Future<List<(String, Map<String, dynamic>)>> outbox(WidgetTester t) async => [
    for (final r in (await t.runAsync(
      () => db.select(db.outboxEntries).get(),
    ))!)
      (r.type, jsonDecode(r.payload) as Map<String, dynamic>),
  ];

  Future<void> pump(
    WidgetTester t, {
    List<String> permissions = const ['oven.intake_pickup', 'oven.board'],
    bool enabled = true,
  }) async {
    t.view.physicalSize = const Size(1280, 1000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.runAsync(() async {
      await seedTill(db);
      await seedOven(db);
      if (!enabled) await db.setSessionValue(ovenEnabledKey, 'false');
    });
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          tillDatabaseProvider.overrideWithValue(db),
          ovenRepositoryProvider.overrideWith(
            (ref) => OvenRepository(db, null),
          ),
          tillSessionProvider.overrideWith(
            () => _Session(
              TillSession(
                staff: cashier,
                permissions: permissions,
                isOffline: true,
              ),
            ),
          ),
          enrolledBranchNameProvider.overrideWith((_) async => 'Centro'),
          saleClockProvider.overrideWithValue(() => now),
        ],
        child: const MaterialApp(
          locale: Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: OvenScreen()),
        ),
      ),
    );
    await settle(t);
  }

  Future<void> finish(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
  }

  Future<void> intake(WidgetTester t, {bool payNow = false}) async {
    await t.tap(find.byKey(const Key('oven-new')));
    await settle(t);
    await t.enterText(find.byKey(const Key('oven-tag')), '12');
    await t.enterText(find.byKey(const Key('oven-name')), 'Familia López');
    await t.enterText(find.byKey(const Key('oven-phone')), '55 1234 5678');
    await t.enterText(
      find.byKey(const Key('oven-description')),
      'Pavo en charola',
    );
    await t.enterText(find.byKey(const Key('oven-kg')), '3.2');
    await t.pump();
    expect(
      t.widget<Text>(find.byKey(const Key('oven-fee'))).data,
      r'$80.00 + $40.00/kg = $208.00',
    );
    if (payNow) {
      await t.tap(find.byKey(const Key('oven-pay-now')));
      await t.pump();
    }
    await t.runAsync(() => t.tap(find.byKey(const Key('oven-save'))));
    await settle(t);
  }

  testWidgets('a branch without the service says so', (t) async {
    await pump(t, enabled: false);
    expect(find.byKey(const Key('oven-off')), findsOneWidget);
    await finish(t);
  });

  testWidgets('M8.1: drop-off unpaid, then the board and pickup with payment', (
    t,
  ) async {
    await pump(t);
    await intake(t);
    var [(type, p)] = await outbox(t);
    expect(type, 'oven.received');
    expect(p['ruleId'], turkeyRule);
    expect(p['weightGrams'], 3200);
    expect(p['feeCents'], 20800);
    expect(p['feeSaleId'], isNull);
    expect(find.textContaining('Recibido: ficha 12'), findsOneWidget);

    await t.tap(find.byKey(const Key('tab-board')));
    await settle(t);
    final card = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('in-oven-'),
    );
    await t.runAsync(() => t.tap(card));
    await settle(t);
    final ready = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('ready-btn-'),
    );
    await t.runAsync(() => t.tap(ready));
    await settle(t);
    expect(find.text('No hay platillos en espera'), findsOneWidget);

    await t.tap(find.byKey(const Key('tab-counter')));
    await settle(t);
    expect(find.text(r'Cobrar $208.00 y entregar'), findsOneWidget);
    await t.tap(find.text(r'Cobrar $208.00 y entregar'));
    await settle(t);
    await t.tap(find.byKey(const Key('payment-exact')));
    await t.pump();
    await t.runAsync(() => t.tap(find.byKey(const Key('payment-finish'))));
    await settle(t);
    final types = [for (final (ty, _) in await outbox(t)) ty];
    expect(types, [
      'oven.received',
      'oven.status',
      'oven.status',
      'sale.completed',
      'oven.picked_up',
    ]);
    [..., (type, p)] = await outbox(t);
    expect(p['feeSaleId'], isNotNull);
    expect(find.textContaining('Entregado: ficha 12'), findsOneWidget);
    await finish(t);
  });

  testWidgets('paying at drop-off hands over later without charging', (
    t,
  ) async {
    await pump(t);
    await intake(t, payNow: true);
    await t.tap(find.byKey(const Key('payment-exact')));
    await t.pump();
    await t.runAsync(() => t.tap(find.byKey(const Key('payment-finish'))));
    await settle(t);
    final rows = await outbox(t);
    expect(
      [for (final (ty, _) in rows) ty],
      ['sale.completed', 'oven.received'],
    );
    expect(rows.last.$2['feeSaleId'], isNotNull);
    await finish(t);
  });

  testWidgets('a baker sees only the board', (t) async {
    await pump(t, permissions: const ['oven.board']);
    expect(find.byKey(const Key('oven-new')), findsNothing);
    expect(find.text('No hay platillos en espera'), findsOneWidget);
    await finish(t);
  });

  testWidgets('a bad phone is refused before anything is written', (t) async {
    await pump(t);
    await t.tap(find.byKey(const Key('oven-new')));
    await settle(t);
    await t.enterText(find.byKey(const Key('oven-tag')), '3');
    await t.enterText(find.byKey(const Key('oven-name')), 'Rosa');
    await t.enterText(find.byKey(const Key('oven-phone')), '123');
    await t.enterText(find.byKey(const Key('oven-description')), 'Pierna');
    await t.enterText(find.byKey(const Key('oven-kg')), '2');
    await t.runAsync(() => t.tap(find.byKey(const Key('oven-save'))));
    await settle(t);
    expect(find.byKey(const Key('oven-error')), findsOneWidget);
    expect(await outbox(t), isEmpty);
    await finish(t);
  });
}
