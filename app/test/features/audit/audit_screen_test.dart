import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/features/audit/presentation/audit_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../admin_test_harness.dart';

void main() {
  testWidgets('shows entries in Spanish with names and pages with the cursor', (
    tester,
  ) async {
    await pumpAdminScreen(tester, const AuditScreen());

    expect(find.text('PIN cambiado'), findsOneWidget);
    expect(find.text('Autorización de gerente concedida'), findsOneWidget);
    expect(
      find.text('Ana · autorizó Fernando · Sucursal Centro'),
      findsOneWidget,
    );
    expect(find.text('Dispositivo registrado'), findsNothing);

    await tapKey(tester, 'audit-load-more');
    expect(find.text('Dispositivo registrado'), findsOneWidget);
    expect(find.byKey(const Key('audit-load-more')), findsNothing);
  });

  testWidgets('filters by action', (tester) async {
    await pumpAdminScreen(tester, const AuditScreen());

    await tapKey(tester, 'audit-action-filter');
    await tester.tap(find.text('Dispositivo registrado').last);
    await tester.pumpAndSettle();
    expect(find.text('Dispositivo registrado'), findsWidgets);
    expect(find.text('PIN cambiado'), findsNothing);
  });

  testWidgets('filters by person, as actor or approver', (tester) async {
    await pumpAdminScreen(tester, const AuditScreen());

    await tapKey(tester, 'audit-staff-filter');
    await tester.tap(find.text('Ana').last);
    await tester.pumpAndSettle();
    expect(find.text('Autorización de gerente concedida'), findsOneWidget);
    expect(find.text('PIN cambiado'), findsNothing);
  });

  testWidgets('shows the details of an entry', (tester) async {
    await pumpAdminScreen(tester, const AuditScreen());
    await tester.tap(find.text('Autorización de gerente concedida'));
    await tester.pumpAndSettle();
    expect(find.textContaining('sale.refund'), findsOneWidget);
  });

  testWidgets('a slow earlier page never mixes into a newer filter', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // The first, unfiltered page takes 2 s; filtered pages answer at once.
    final dio = Dio()
      ..interceptors.addAll([
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final unfilteredAudit =
                options.path.endsWith('/v1/audit-log') &&
                options.queryParameters['action'] == null;
            if (unfilteredAudit) {
              await Future<void>.delayed(const Duration(seconds: 2));
            }
            handler.next(options);
          },
        ),
        FakeApiInterceptor(),
      ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          restClientProvider.overrideWithValue(RestClient(dio)),
        ],
        child: const MaterialApp(
          locale: Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuditScreen(),
        ),
      ),
    );
    await tester.pump();

    // While the first page is still loading, filter by an action.
    await tester.tap(find.byKey(const Key('audit-action-filter')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Dispositivo registrado').last);
    await tester.pump(const Duration(milliseconds: 500));

    // Let the slow unfiltered response arrive after the filtered one.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Dispositivo registrado'), findsWidgets);
    expect(find.text('PIN cambiado'), findsNothing);
  });
}
