import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/features/reports/presentation/reports_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> row(String key, String label, int net, {int refund = 0}) =>
    {
      'key': key,
      'label': label,
      'saleCount': 3,
      'quantity': null,
      'grossCents': net,
      'discountCents': 0,
      'netCents': net,
      'cashCents': net,
      'prepaidCents': 0,
      'refundCents': refund,
      'baseCents': null,
      'taxCents': null,
    };

void main() {
  late FakeApiInterceptor fake;

  setUp(() {
    fake = FakeApiInterceptor();
    fake.catalog.dashboard = {
      'date': '2026-11-09',
      'compareDate': '2026-11-02',
      'netCents': 385000,
      'saleCount': 30,
      'averageTicketCents': 12833,
      'refundCents': 35000,
      'compareNetCents': 350000,
      'compareSaleCount': 30,
      'wasteCostCents': 2400,
      'wasteUnits': 8,
      'flaggedShifts': 1,
      'prepaidCollectedCents': 50000,
      'customersOwing': 0,
      'hours': [
        {'hour': 7, 'netCents': 120000, 'saleCount': 10},
        {'hour': 13, 'netCents': 265000, 'saleCount': 20},
      ],
      'topProducts': [
        {
          'variantId': '0192e2b0-0400-7000-8000-000000000001',
          'label': 'Pastel · Pieza',
          'quantity': 4,
          'netCents': 140000,
        },
      ],
      'days': [
        {'date': '2026-11-08', 'netCents': 300000, 'saleCount': 25},
        {'date': '2026-11-09', 'netCents': 385000, 'saleCount': 30},
      ],
      'branches': <Object>[],
    };
    fake.catalog.salesReport['day'] = [
      row('2026-11-09', '2026-11-09', 420000, refund: 35000),
    ];
    fake.catalog.salesReport['cashier'] = [
      row('a', 'Ana', 300000),
      row('b', 'Beto', 120000),
    ];
  });

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(1400, 1100);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final dio = Dio()..interceptors.add(fake);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          restClientProvider.overrideWithValue(RestClient(dio)),
        ],
        child: const MaterialApp(
          locale: Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReportsScreen(),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('the dashboard shows the day, the change and what needs a look', (
    t,
  ) async {
    await pump(t);
    expect(t.widget<Text>(find.byKey(const Key('kpi-net'))).data, r'$3,850.00');
    expect(
      find.text('+10% contra el mismo día de la semana pasada'),
      findsOneWidget,
    );
    expect(t.widget<Text>(find.byKey(const Key('kpi-flagged'))).data, '1');
    expect(find.byKey(const Key('chart-hours')), findsOneWidget);
    expect(find.text('Pastel · Pieza'), findsOneWidget);
  });

  testWidgets('sales group by cashier and show a total row', (t) async {
    await pump(t);
    await t.tap(find.byKey(const Key('tab-sales')));
    await t.pumpAndSettle();
    final table = find.byKey(const Key('sales-table'));
    // Sold minus refunds: 4,200.00 − 350.00.
    expect(
      find.descendant(of: table, matching: find.text(r'$3,850.00')),
      findsWidgets,
    );
    await t.tap(find.byKey(const Key('sales-group')));
    await t.pumpAndSettle();
    await t.tap(find.text('Cajero').last);
    await t.pumpAndSettle();
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Beto'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text(r'$4,200.00'), findsWidgets);
  });
}
