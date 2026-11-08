import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/features/backoffice/auth/data/backoffice_auth_service.dart';
import 'package:bakery_pos/features/oven_admin/presentation/oven_settings_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeApiInterceptor fake;
  late Dio dio;

  setUp(() {
    fake = FakeApiInterceptor();
    dio = Dio()..interceptors.add(fake);
  });

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(1280, 1000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final auth = BackofficeAuthService(restClient: RestClient(dio), dio: dio);
    await t.runAsync(() => auth.login('owner@panaderia.com', 'Admin123456!'));
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          restClientProvider.overrideWithValue(RestClient(dio)),
          backofficeAuthServiceProvider.overrideWithValue(auth),
        ],
        child: const MaterialApp(
          locale: Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OvenSettingsScreen(),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('M8.5: the owner adds a dish type and sees what 1 kg costs', (
    t,
  ) async {
    await pump(t);
    expect(find.byKey(const Key('oven-fees-empty')), findsOneWidget);
    await t.tap(find.byKey(const Key('oven-fee-add')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('oven-fee-name')), 'Pavo');
    await t.enterText(find.byKey(const Key('oven-fee-base')), '80');
    await t.enterText(find.byKey(const Key('oven-fee-perkg')), '40');
    await t.pump();
    expect(
      t.widget<Text>(find.byKey(const Key('oven-fee-example'))).data,
      r'1 kg cuesta $120.00 · 3 kg cuestan $200.00',
    );
    await t.tap(find.byKey(const Key('oven-fee-save')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('oven-fee-error')), findsOneWidget);
    await t.tap(find.byKey(const Key('oven-fee-iva')));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('IVA 16%').last);
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('oven-fee-save')));
    await t.pumpAndSettle();
    final rule = fake.catalog.ovenRules.single;
    expect(rule['name'], 'Pavo');
    expect(rule['baseCents'], 8000);
    expect(rule['perKgCents'], 4000);
    expect(
      find.text(r'$80.00 + $40.00 por kilo · 1 kg = $120.00'),
      findsOneWidget,
    );
  });

  testWidgets('M8.5: a branch is turned on for the service', (t) async {
    await pump(t);
    final branch = fake.catalog.branchIds.first;
    await t.tap(find.byKey(Key('oven-branch-$branch')));
    await t.pumpAndSettle();
    expect(fake.catalog.ovenEnabled, isTrue);
    expect(
      t.widget<SwitchListTile>(find.byKey(Key('oven-branch-$branch'))).value,
      isTrue,
    );
  });
}
