import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/features/stock_admin/presentation/stock_admin_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _branch = '0192e2b0-0100-7000-8000-000000000001';
const _other = '0192e2b0-0100-7000-8000-000000000002';
const _variant = '0192e2b0-0400-7000-8000-000000000001';
const _staff = '0192e2b0-0300-7000-8000-000000000001';
const _transfer = '0192e2b0-7700-7000-8000-000000000001';

void main() {
  late FakeApiInterceptor fake;

  setUp(() {
    fake = FakeApiInterceptor();
    fake.catalog.stockLevels.add({
      'branchId': _branch,
      'variantId': _variant,
      'productName': 'Concha',
      'variantName': 'Pieza',
      'onHand': -3,
      'freshUnits': 0,
      'dayOldUnits': 0,
      'wasteDueUnits': 0,
    });
    fake.catalog.stockEvents.add({
      'id': '0192e2b0-7800-7000-8000-000000000001',
      'kind': 'SALE',
      'quantity': -3,
      'lotId': null,
      'referenceType': 'sale',
      'referenceId': null,
      'staffId': _staff,
      'occurredAt': '2026-11-01T14:00:00.000Z',
    });
    fake.catalog.stockCheck = {
      'checkedAt': '2026-11-01T09:00:00.000Z',
      'rowsChecked': 10,
      'mismatches': 2,
    };
    fake.catalog.waste.addAll([
      for (final (i, cost) in [400, null].indexed)
        {
          'id': '0192e2b0-7900-7000-8000-00000000000$i',
          'branchId': _branch,
          'variantId': _variant,
          'productName': 'Concha',
          'variantName': 'Pieza',
          'quantity': 2,
          'reason': 'BURNT',
          'staffId': _staff,
          'occurredAt': '2026-11-01T14:00:00.000Z',
          'costCents': cost,
        },
    ]);
    fake.catalog.transfers.add({
      'id': _transfer,
      'fromBranchId': _branch,
      'toBranchId': _other,
      'status': 'SENT',
      'sentByStaffId': _staff,
      'sentAt': '2026-11-01T14:00:00.000Z',
      'flagged': false,
      'lines': [
        {
          'variantId': _variant,
          'productName': 'Concha',
          'variantName': 'Pieza',
          'producedOn': '2026-11-01',
          'quantitySent': 10,
          'quantityReceived': null,
        },
      ],
    });
  });

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(1400, 1000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          restClientProvider.overrideWithValue(
            RestClient(Dio()..interceptors.add(fake)),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StockAdminScreen(),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('shows stock, a failed nightly check and a product ledger', (
    t,
  ) async {
    await pump(t);
    expect(find.byKey(const Key('stock-check')), findsOneWidget);
    expect(find.textContaining('2 diferencias'), findsOneWidget);
    expect(find.text('-3'), findsOneWidget);
    await t.tap(find.text('-3'));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('ledger')), findsOneWidget);
    expect(find.text('Venta'), findsOneWidget);
  });

  testWidgets('F5: waste shows its cost, and a dash with none', (t) async {
    await pump(t);
    await t.tap(find.byKey(const Key('tab-waste')));
    await t.pumpAndSettle();
    expect(find.text(r'Costo de la merma: $8.00'), findsOneWidget);
    expect(find.text(r'$8.00'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('F6: 9 received of 10 flags the transfer', (t) async {
    await pump(t);
    await t.tap(find.byKey(const Key('tab-transfers')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('receive-$_transfer')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('receive-line-0')), '9');
    await t.tap(find.byKey(const Key('receive-save')));
    await t.pumpAndSettle();
    expect(find.byIcon(Icons.flag), findsOneWidget);
  });
}
