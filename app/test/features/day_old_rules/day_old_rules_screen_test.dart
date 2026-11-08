import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/features/backoffice/auth/data/backoffice_auth_service.dart';
import 'package:bakery_pos/features/day_old_rules/presentation/day_old_rules_screen.dart';
import 'package:bakery_pos/features/stock_admin/presentation/stock_admin_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

const _bread = '0192e2b0-0100-7000-8000-0000000000c1';
const _cakes = '0192e2b0-0100-7000-8000-0000000000c2';

void main() {
  late FakeApiInterceptor fake;
  late Dio dio;

  void product(String id, String category, String name) {
    fake.catalog.products.add({
      'id': id,
      'categoryId': category,
      'name': name,
      'isActive': true,
      'dayOldDiscountAfterDays': null,
      'dayOldDiscountBp': null,
      'dayOldWasteAfterDays': null,
    });
    fake.catalog.variants.add({
      'id': '$id-v',
      'productId': id,
      'name': 'Pieza',
      'priceCents': 1200,
      'isActive': true,
      'costCents': null,
    });
  }

  setUp(() {
    fake = FakeApiInterceptor();
    fake.catalog.categories.addAll([
      {'id': _bread, 'name': 'Pan dulce'},
      {'id': _cakes, 'name': 'Pasteles'},
    ]);
    product('0192e2b0-0200-7000-8000-0000000000a1', _bread, 'Concha');
    product('0192e2b0-0200-7000-8000-0000000000a2', _bread, 'Cuerno');
    product('0192e2b0-0200-7000-8000-0000000000a3', _cakes, 'Tres leches');
    dio = Dio()..interceptors.add(fake);
  });

  Future<void> pump(
    WidgetTester t,
    Widget home, {
    List<Override> more = const [],
  }) async {
    t.view.physicalSize = const Size(1280, 1000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          restClientProvider.overrideWithValue(RestClient(dio)),
          ...more,
        ],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets(
    'a rule goes on a whole category at once and shows on each product',
    (t) async {
      await pump(t, const DayOldRulesScreen());
      expect(find.text('Sin regla'), findsNWidgets(3));
      await t.tap(find.byKey(const Key('dayold-category-Pan dulce')));
      await t.pumpAndSettle();
      expect(find.text('2 seleccionados'), findsOneWidget);
      await t.tap(find.byKey(const Key('dayold-apply')));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const Key('dayold-after')), '1');
      await t.enterText(find.byKey(const Key('dayold-percent')), '30');
      await t.enterText(find.byKey(const Key('dayold-waste')), '3');
      await t.pump();
      expect(find.text('Al día 1: 30% menos · día 3: merma'), findsOneWidget);
      await t.tap(find.byKey(const Key('dayold-save')));
      await t.pumpAndSettle();

      final rules = {
        for (final p in fake.catalog.products) p['name']: p['dayOldDiscountBp'],
      };
      expect(rules, {'Concha': 3000, 'Cuerno': 3000, 'Tres leches': null});
      expect(find.text('Al día 1: 30% menos · día 3: merma'), findsNWidgets(2));
      expect(find.text('Sin regla'), findsOneWidget);
    },
  );

  testWidgets('waste before the discount is refused before sending', (t) async {
    await pump(t, const DayOldRulesScreen());
    await t.tap(find.text('Concha'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('dayold-apply')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('dayold-after')), '3');
    await t.enterText(find.byKey(const Key('dayold-waste')), '2');
    await t.tap(find.byKey(const Key('dayold-save')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('dayold-error')), findsOneWidget);
    expect(fake.catalog.products.first['dayOldDiscountBp'], isNull);
  });

  testWidgets('with catalog.cost, Costos sets and clears a cost', (t) async {
    final auth = BackofficeAuthService(restClient: RestClient(dio), dio: dio);
    await t.runAsync(() => auth.login('owner@panaderia.com', 'Admin123456!'));
    await pump(
      t,
      const StockAdminScreen(),
      more: [backofficeAuthServiceProvider.overrideWithValue(auth)],
    );
    await t.tap(find.byKey(const Key('tab-costs')));
    await t.pumpAndSettle();
    final concha = fake.catalog.variants.first;
    await t.tap(find.byKey(Key('cost-${concha['id']}')));
    await t.pumpAndSettle();
    expect(find.text(r'Precio $12.00'), findsOneWidget);
    await t.enterText(find.byKey(const Key('cost-field')), '4.50');
    await t.tap(find.byKey(const Key('cost-save')));
    await t.pumpAndSettle();
    expect(concha['costCents'], 450);
    expect(find.text(r'$4.50'), findsOneWidget);

    await t.tap(find.byKey(Key('cost-${concha['id']}')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('cost-field')), '');
    await t.tap(find.byKey(const Key('cost-save')));
    await t.pumpAndSettle();
    expect(concha['costCents'], isNull);
  });
}
