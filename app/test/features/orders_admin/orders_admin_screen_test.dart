import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/features/orders_admin/presentation/orders_admin_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeApiInterceptor fake;

  setUp(() {
    fake = FakeApiInterceptor();
    fake.catalog.categories.add({'id': 'cat', 'name': 'Pan', 'sortOrder': 0});
    fake.catalog.products.add({
      'id': 'p1',
      'categoryId': 'cat',
      'name': 'Bolillo',
      'isActive': true,
    });
    fake.catalog.variants.add({
      'id': 'v1',
      'productId': 'p1',
      'name': 'Pieza',
      'priceCents': 250,
      'isActive': true,
      'costCents': null,
    });
  });

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(1280, 1000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final dio = Dio()..interceptors.add(fake);
    await t.pumpWidget(
      ProviderScope(
        overrides: [restClientProvider.overrideWithValue(RestClient(dio))],
        child: const MaterialApp(
          locale: Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OrdersAdminScreen(),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('a manager adds a customer and 30 bolillos Monday to Friday', (
    t,
  ) async {
    await pump(t);
    await t.tap(find.byKey(const Key('customer-new')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('customer-name')), 'Fonda Mary');
    await t.enterText(find.byKey(const Key('customer-phone')), '5512345678');
    await t.tap(find.byKey(const Key('customer-save')));
    await t.pumpAndSettle();
    expect(find.text('Fonda Mary'), findsOneWidget);

    await t.tap(find.text('Fonda Mary'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('order-new')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('order-qty-v1')), '30');
    await t.tap(find.byKey(const Key('order-save')));
    await t.pumpAndSettle();

    final order = fake.catalog.customerOrders.single;
    expect(order['weekdays'], 31);
    expect(order['pickupTime'], '07:30');
    expect(order['missedRule'], 'CHARGE');
    expect((order['lines'] as List).single['quantity'], 30);
    expect(find.text('L M M J V a las 07:30 · Activo'), findsOneWidget);
    expect(find.text('30 × Bolillo'), findsOneWidget);

    await t.tap(find.byKey(Key('order-end-${order['id']}')));
    await t.pumpAndSettle();
    expect(order['status'], 'ENDED');
    expect(find.text('L M M J V a las 07:30 · Terminado'), findsOneWidget);
  });
}
