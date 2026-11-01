import 'dart:async';
import 'dart:convert';

import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/features/sync/data/sync_worker.dart';
import 'package:bakery_pos/features/sync/presentation/sync_indicator.dart';
import 'package:bakery_pos/features/till_catalog/data/till_catalog_repository.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('C13: sync indicator follows the outbox', (tester) async {
    final fake = FakeApiInterceptor()..offline = true;
    final db = AppDatabase(NativeDatabase.memory());
    final api = RestClient(Dio()..interceptors.add(fake)).sync;
    final counts = StreamController<({int pending, int quarantined})>();
    addTearDown(counts.close);
    final worker = SyncWorker(
      db: db,
      api: api,
      catalog: TillCatalogRepository(db, api),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tillDatabaseProvider.overrideWithValue(db),
          syncWorkerProvider.overrideWithValue(worker),
          // Drift streams listened to in the fake-async zone deadlock with
          // writes made in the real one, so counts are read here and fed in.
          outboxCountsProvider.overrideWith((ref) => counts.stream),
        ],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(appBar: AppBar(actions: const [SyncIndicator()])),
        ),
      ),
    );
    Future<void> settle() async {
      await tester.runAsync(() async {
        counts.add(await db.watchOutboxCounts().first);
      });
      await tester.pump();
    }

    await settle();
    expect(find.text('Sin conexión'), findsOneWidget);
    expect(find.byKey(const Key('sync-waiting-label')), findsNothing);

    Future<void> queue(String id, Map<String, Object?> payload) =>
        tester.runAsync(
          () => db
              .into(db.outboxEntries)
              .insert(
                OutboxEntriesCompanion.insert(
                  id: id,
                  type: 'audit.offline_event',
                  occurredAt: DateTime.utc(2026, 11, 1),
                  payload: jsonEncode(payload),
                ),
              ),
        );
    await queue('a', {'action': 'auth.login_success', 'staffId': 's1'});
    await queue('b', {
      'action': 'auth.login_success',
      'staffId': 's1',
      'pin': 'x',
    });
    await settle();
    expect(find.text('2 en espera'), findsOneWidget);
    expect(find.byKey(const Key('sync-quarantine-badge')), findsNothing);

    // Reconnect: one record applies, the other is quarantined.
    fake.offline = false;
    await tester.runAsync(worker.runCycle);
    await settle();
    expect(find.text('En línea'), findsOneWidget);
    expect(find.byKey(const Key('sync-waiting-label')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('sync-quarantine-badge')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('sync-indicator')));
    await tester.pumpAndSettle();
    expect(find.text('Nada en espera'), findsOneWidget);
    expect(find.text('1 registro en cuarentena'), findsOneWidget);

    fake.offline = true;
    // Tapping inside runAsync runs the cycle with real database and network
    // futures, which the fake-async zone would never complete.
    final failed = find.text(
      'No se pudo conectar con el servidor; se reintentará solo',
    );
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('sync-now-button')));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    expect(failed, findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    worker.dispose();
    await tester.runAsync(db.close);
  });
}
