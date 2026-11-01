import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/router/app_router.dart';
import 'package:bakery_pos/features/sales_admin/presentation/sales_admin_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

late FakeApiInterceptor fake;

const _sale1 = '0192e2b0-5a1e-7000-8000-000000000001';
const _sale2 = '0192e2b0-5a1e-7000-8000-000000000002';
const _sale3 = '0192e2b0-5a1e-7000-8000-000000000003';
const _refund = '0192e2b0-5a1e-7000-8000-0000000000f1';

Map<String, Object?> _line(
  int lineNo,
  String product,
  int qty,
  int price, {
  int lineDiscount = 0,
  int refunded = 0,
}) => {
  'lineNo': lineNo,
  'variantId': '0192e2b0-0400-7000-8000-00000000000$lineNo',
  'productName': product,
  'variantName': 'Pieza',
  'quantity': qty,
  'unitPriceCents': price,
  'grossCents': qty * price,
  'lineDiscountCents': lineDiscount,
  'orderDiscountCents': 0,
  'netCents': qty * price - lineDiscount,
  'ivaRateId': '0192e2b0-0500-7000-8000-000000000001',
  'ivaBp': 0,
  'iepsRateId': null,
  'iepsBp': 0,
  'baseCents': qty * price - lineDiscount,
  'iepsCents': 0,
  'ivaCents': 0,
  'refundedQuantity': refunded,
};

/// Two SUC1 sales on 1 Nov (one with a discount, approval and a refund)
/// and one SUC2 sale on 20 Oct.
void _seed(FakeApiInterceptor api) {
  api.catalog.sales.addAll([
    {
      'id': _sale1,
      'folio': 'SUC1-01-000001',
      'folioNumber': 1,
      'branchId': api.branchId1,
      'deviceId': api.deviceId,
      'cashierStaffId': '0192e2b0-0030-7000-8000-000000000030',
      'cashierName': 'Ana (Cajera)',
      'occurredAt': '2026-11-01T15:00:00.000Z',
      'status': 'PARTIALLY_REFUNDED',
      'grossCents': 9000,
      'discountCents': 1500,
      'totalCents': 7500,
      'refundedCents': 1500,
      'lines': [
        _line(1, 'Concha', 4, 1500, lineDiscount: 1500, refunded: 1),
        _line(2, 'Bolillo', 6, 500),
      ],
      'discounts': [
        {
          'lineNo': 1,
          'kind': 'PERCENT',
          'value': 2500,
          'cents': 1500,
          'reason': 'DAMAGED',
          'note': null,
          'approverStaffId': '0192e2b0-0020-7000-8000-000000000020',
        },
      ],
      'taxes': [
        {'kind': 'IVA', 'rateBp': 0, 'baseCents': 7500, 'taxCents': 0},
      ],
      'payments': [
        {
          'method': 'CASH',
          'amountCents': 7500,
          'tenderedCents': 10000,
          'changeCents': 2500,
        },
      ],
      'voidedLines': [
        {
          'variantId': '0192e2b0-0400-7000-8000-000000000009',
          'quantity': 2,
          'unitPriceCents': 1800,
          'voidedAt': '2026-11-01T14:58:00.000Z',
          'staffId': '0192e2b0-0030-7000-8000-000000000030',
        },
      ],
      'refunds': [
        {
          'id': _refund,
          'kind': 'REFUND',
          'reason': 'QUALITY',
          'note': null,
          'deviceId': api.deviceId,
          'staffId': '0192e2b0-0030-7000-8000-000000000030',
          'approverStaffId': '0192e2b0-0020-7000-8000-000000000020',
          'occurredAt': '2026-11-01T17:00:00.000Z',
          'totalCents': 1500,
          'lines': [
            {
              'lineNo': 1,
              'quantity': 1,
              'amountCents': 1500,
              'baseCents': 1500,
              'iepsCents': 0,
              'ivaCents': 0,
              'restock': false,
            },
          ],
        },
      ],
    },
    {
      'id': _sale2,
      'folio': 'SUC1-01-000002',
      'folioNumber': 2,
      'branchId': api.branchId1,
      'deviceId': api.deviceId,
      'cashierStaffId': '0192e2b0-0030-7000-8000-000000000030',
      'cashierName': 'Ana (Cajera)',
      'occurredAt': '2026-11-01T16:00:00.000Z',
      'grossCents': 1000,
      'discountCents': 0,
      'totalCents': 1000,
      'lines': [_line(1, 'Bolillo', 2, 500)],
      'payments': [
        {
          'method': 'CASH',
          'amountCents': 1000,
          'tenderedCents': 1000,
          'changeCents': 0,
        },
      ],
    },
    {
      'id': _sale3,
      'folio': 'SUC2-01-000001',
      'folioNumber': 1,
      'branchId': api.branchId2,
      'deviceId': 'fake-suc2-till',
      'cashierStaffId': '0192e2b0-0030-7000-8000-000000000031',
      'cashierName': 'Luis (Cajero)',
      'occurredAt': '2026-10-20T16:00:00.000Z',
      'grossCents': 3000,
      'discountCents': 0,
      'totalCents': 3000,
      'lines': [_line(1, 'Rosca', 1, 3000)],
      'payments': [
        {
          'method': 'CASH',
          'amountCents': 3000,
          'tenderedCents': 5000,
          'changeCents': 2000,
        },
      ],
    },
  ]);
}

/// Like the server, a manager of SUC1 asking for SUC2 gets 403.
class _ManagerOfBranch1 extends Interceptor {
  _ManagerOfBranch1(this.branch2);
  final String branch2;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path.endsWith('/v1/sales') &&
        options.queryParameters['branchId'] == branch2) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 403,
            data: {'code': 'PERMISSION_DENIED', 'message': 'Not your branch'},
          ),
        ),
      );
      return;
    }
    handler.next(options);
  }
}

Future<void> _pump(WidgetTester tester, {bool manager = false}) async {
  tester.view.physicalSize = const Size(1280, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final dio = Dio();
  if (manager) dio.interceptors.add(_ManagerOfBranch1(fake.branchId2));
  dio.interceptors.add(fake);
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
        home: const SalesAdminScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pickBranch(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(const Key('sales-branch-filter')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(name).last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    fake = FakeApiInterceptor();
    _seed(fake);
  });

  test('Ventas is in the back office for reports.branch only', () {
    expect(
      getPermittedBackofficeRoutes(['reports.branch', 'audit.view']),
      contains(AppRoutes.backofficeSales),
    );
    expect(
      getPermittedBackofficeRoutes(['sale.create', 'cash.open_shift']),
      isNot(contains(AppRoutes.backofficeSales)),
    );
  });

  testWidgets('D11: the owner lists sales newest first with the shown totals', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byKey(const ValueKey('sale-$_sale2')), findsOneWidget);
    expect(find.byKey(const ValueKey('sale-$_sale1')), findsOneWidget);
    expect(find.byKey(const ValueKey('sale-$_sale3')), findsOneWidget);
    final folios = tester
        .widgetList<Text>(find.textContaining(RegExp(r'^SUC\d-01-')))
        .map((t) => t.data)
        .toList();
    expect(folios, ['SUC1-01-000002', 'SUC1-01-000001', 'SUC2-01-000001']);
    expect(
      find.text('3 ventas mostradas · cobrado \$115.00 · devuelto \$15.00'),
      findsOneWidget,
    );
    expect(find.text('Devolución parcial'), findsOneWidget);
  });

  testWidgets('D11: filters by branch and by folio', (tester) async {
    await _pump(tester);

    await _pickBranch(tester, 'Sucursal Norte');
    expect(find.byKey(const ValueKey('sale-$_sale3')), findsOneWidget);
    expect(find.byKey(const ValueKey('sale-$_sale1')), findsNothing);

    await _pickBranch(tester, 'Todas las sucursales');
    await tester.enterText(
      find.byKey(const Key('sales-folio-filter')),
      'suc1-01-000001',
    );
    await tester.tap(find.byKey(const Key('sales-folio-search')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sale-$_sale1')), findsOneWidget);
    expect(find.byKey(const ValueKey('sale-$_sale2')), findsNothing);
    expect(find.byKey(const ValueKey('sale-$_sale3')), findsNothing);
  });

  testWidgets(
    'D11: opening a sale shows lines, discounts, tax by rate, payment, '
    'voided lines and refunds',
    (tester) async {
      await _pump(tester);
      await tester.tap(find.text('SUC1-01-000001'));
      await tester.pumpAndSettle();

      final detail = find.byKey(const Key('sale-detail-$_sale1'));
      expect(detail, findsOneWidget);
      Finder inDetail(String text) =>
          find.descendant(of: detail, matching: find.text(text));

      expect(inDetail('Venta SUC1-01-000001'), findsOneWidget);
      expect(inDetail('Concha · Pieza'), findsOneWidget);
      expect(inDetail('4 × \$15.00'), findsOneWidget);
      expect(inDetail('Devueltas: 1'), findsOneWidget);
      expect(inDetail('Bolillo · Pieza'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('sale-detail-total'))).data,
        '\$75.00',
      );
      expect(
        inDetail('Al renglón 1: 25% = \$15.00 · Producto dañado'),
        findsOneWidget,
      );
      expect(find.textContaining('Autorizó:'), findsOneWidget);
      expect(inDetail('IVA 0%: base \$75.00, impuesto \$0.00'), findsOneWidget);
      expect(
        inDetail('Efectivo \$75.00 · recibido \$100.00 · cambio \$25.00'),
        findsOneWidget,
      );
      expect(find.textContaining('2 × \$18.00'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('sale-refund-$_refund')),
          matching: find.textContaining('Devolución ·'),
        ),
        findsOneWidget,
      );
      expect(inDetail('Renglón 1: 1 pza · \$15.00'), findsOneWidget);

      await tester.tap(find.byKey(const Key('sale-detail-close')));
      await tester.pumpAndSettle();
      expect(detail, findsNothing);
    },
  );

  testWidgets('D11: a manager asking for another branch is told no', (
    tester,
  ) async {
    await _pump(tester, manager: true);
    await _pickBranch(tester, 'Sucursal Norte');

    expect(
      find.text('No tienes acceso a las ventas de esa sucursal'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('sale-$_sale3')), findsNothing);
  });
}
