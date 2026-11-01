import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/features/sync_admin/presentation/sync_admin_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

late FakeApiInterceptor fake;

String _id(int n) => '0192e2b0-0c00-7000-8000-${n.toString().padLeft(12, '0')}';

/// A till's batch of 10 offline events; record 7 carries a PIN, which the
/// fake server rejects as SYNC_INVALID_PAYLOAD, like the real one.
Map<String, Object?> _batch() => {
  'records': [
    for (var i = 1; i <= 10; i++)
      {
        'id': _id(i),
        'type': 'audit.offline_event',
        'occurredAt': '2026-11-01T15:${i.toString().padLeft(2, '0')}:00.000Z',
        'actorStaffId': null,
        'payload': {
          'action': 'auth.login_success',
          'staffId': '0192e2b0-0030-7000-8000-000000000030',
          if (i == 7) 'pin': '1234',
        },
      },
  ],
};

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final dio = Dio()..interceptors.add(fake);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dioProvider.overrideWithValue(dio),
        restClientProvider.overrideWithValue(RestClient(dio)),
      ],
      child: MaterialApp(
        locale: const Locale('es', 'MX'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SyncAdminScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => fake = FakeApiInterceptor());

  test('formatPayload indents JSON', () {
    expect(formatPayload({'a': 1}), '{\n  "a": 1\n}');
  });

  testWidgets(
    'C10: one bad record of 10 is quarantined; the owner sees it and resolves it',
    (tester) async {
      final reply = fake.catalog.handle(
        'POST',
        '/v1/sync/push',
        const {},
        _batch(),
      )!;
      final results = (reply.body! as Map)['results'] as List;
      expect(results.where((r) => r['status'] == 'APPLIED'), hasLength(9));
      expect(results.where((r) => r['status'] == 'QUARANTINED'), hasLength(1));

      await _pump(tester);
      final bad = _id(7);

      // Devices with their last sync.
      expect(find.text('Caja 1'), findsWidgets);
      expect(find.textContaining('Última sincronización:'), findsWidgets);

      // The quarantined record, with device, error and payload without PIN.
      expect(find.byKey(Key('quarantine-$bad')), findsOneWidget);
      expect(find.byKey(Key('quarantine-${_id(1)}')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(Key('quarantine-$bad')),
          matching: find.textContaining('Caja 1 · ocurrió'),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(find.byKey(Key('quarantine-error-$bad'))).data,
        startsWith('SYNC_INVALID_PAYLOAD: '),
      );
      final payload = tester
          .widget<SelectableText>(find.byKey(Key('quarantine-payload-$bad')))
          .data!;
      expect(payload, contains('\n  "action": "auth.login_success"'));
      expect(payload, isNot(contains('pin')));

      // A note is required.
      await tester.tap(find.byKey(Key('quarantine-resolve-$bad')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quarantine-note-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Escribe una nota'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('quarantine-note')),
        'Inicio de sesión revisado con Ana',
      );
      await tester.tap(find.byKey(const Key('quarantine-note-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Registro marcado como resuelto'), findsOneWidget);
      expect(find.byKey(Key('quarantine-$bad')), findsNothing);
      expect(find.byKey(const Key('quarantine-empty')), findsOneWidget);
      expect(
        fake.catalog.quarantine.single['resolutionNote'],
        'Inicio de sesión revisado con Ana',
      );

      // Resolved records keep their note and are not re-applied.
      await tester.tap(find.text('Resueltos'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(Key('quarantine-resolution-$bad'))).data,
        endsWith(': Inicio de sesión revisado con Ana'),
      );
      expect(find.byKey(Key('quarantine-resolve-$bad')), findsNothing);
      expect(fake.catalog.inbox[bad], isA<Map<String, dynamic>>());
    },
  );

  testWidgets('a record someone already resolved shows a message', (
    tester,
  ) async {
    fake.catalog.handle('POST', '/v1/sync/push', const {}, _batch());
    await _pump(tester);
    final bad = _id(7);
    fake.catalog.quarantine.single['resolvedAt'] = '2026-11-01T16:00:00.000Z';

    await tester.tap(find.byKey(Key('quarantine-resolve-$bad')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('quarantine-note')), 'Listo');
    await tester.tap(find.byKey(const Key('quarantine-note-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Este registro ya estaba resuelto'), findsOneWidget);
  });
}
