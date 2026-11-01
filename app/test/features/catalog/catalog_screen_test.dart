import 'dart:typed_data';

import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/features/catalog/data/catalog_admin_service.dart';
import 'package:bakery_pos/features/catalog/presentation/catalog_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 1x1 PNG, enough for Image.memory in the preview.
final _png = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

late FakeApiInterceptor fake;

Map<String, dynamic> _call(String method, String path, [Object? body]) =>
    fake.catalog.handle(method, '/v1/$path', const {}, body)!.body!
        as Map<String, dynamic>;

String _rate(int bp, String kind) =>
    fake.catalog.taxRates.firstWhere(
          (t) => t['rateBp'] == bp && t['kind'] == kind,
        )['id']
        as String;

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final dio = Dio()..interceptors.add(fake);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dioProvider.overrideWithValue(dio),
        restClientProvider.overrideWithValue(RestClient(dio)),
        photoPickerProvider.overrideWithValue(
          () async => (bytes: _png, name: 'concha.png'),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('es', 'MX'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CatalogScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Scrolls only inside a dialog: ensureVisible on a tab page would also move
/// the TabBarView to another page.
Future<void> _reveal(WidgetTester tester, Finder f) async {
  final inDialog = find.ancestor(of: f, matching: find.byType(AlertDialog));
  if (inDialog.evaluate().isNotEmpty) {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
  }
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await _reveal(tester, f);
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String key, String text) async {
  final f = find.byKey(Key(key));
  await _reveal(tester, f);
  await tester.enterText(f, text);
  await tester.pump();
}

Future<void> _choose(WidgetTester tester, String key, String option) async {
  await _tap(tester, find.byKey(Key(key)));
  await _tap(tester, find.text(option).last);
}

Future<void> _fillBasics(WidgetTester tester, {String name = 'Concha'}) async {
  await _type(tester, 'product-name-field', name);
  await _choose(tester, 'product-category-field', 'Pan dulce');
  await _choose(tester, 'product-iva-field', 'IVA 16%');
}

void main() {
  setUp(() {
    fake = FakeApiInterceptor();
    _call('POST', 'categories', {'name': 'Pan dulce', 'color': '#C46A2B'});
  });

  testWidgets(
    'C1: the owner creates a product with 3 variants, a photo and a branch price',
    (tester) async {
      await _pump(tester);
      await _tap(tester, find.byKey(const Key('create-product-button')));
      await _fillBasics(tester);
      await _tap(tester, find.byKey(const Key('photo-choose-button')));
      expect(find.byType(Image), findsOneWidget);

      for (final (i, name, price) in [
        (0, 'Chica', '9'),
        (1, 'Mediana', '12.50'),
        (2, 'Grande', '15'),
      ]) {
        if (i > 0) {
          await _tap(tester, find.byKey(const Key('add-variant-button')));
        }
        await _type(tester, 'variant-name-$i', name);
        await _type(tester, 'variant-price-$i', price);
      }
      await _type(tester, 'variant-sku-1', 'CON-M');
      await _type(tester, 'variant-branch-SUC1-1', '13');
      await _tap(tester, find.byKey(const Key('product-save-button')));

      expect(find.text('Producto guardado'), findsOneWidget);
      final product = fake.catalog.products.single;
      expect(product['name'], 'Concha');
      expect(product['photoId'], fake.catalog.photoIds.single);
      final variants = fake.catalog.variants
          .where((v) => v['productId'] == product['id'])
          .toList();
      expect(variants.map((v) => v['priceCents']), [900, 1250, 1500]);
      expect(variants[1]['sku'], 'CON-M');
      final bp = fake.catalog.branchPrices.values.single;
      expect(bp['variantId'], variants[1]['id']);
      expect(bp['branchId'], fake.branchId1);
      expect(bp['priceCents'], 1300);
      expect(find.text('Concha'), findsOneWidget);
    },
  );

  testWidgets('C5: the form shows the tax split for the chosen rates', (
    tester,
  ) async {
    await _pump(tester);
    await _tap(tester, find.byKey(const Key('create-product-button')));
    await _fillBasics(tester);
    await _type(tester, 'variant-price-0', '10');
    expect(find.text(r'Base $8.62 · IEPS $0.00 · IVA $1.38'), findsOneWidget);
    await _choose(tester, 'product-ieps-field', 'IEPS 8%');
    expect(find.text(r'Base $7.98 · IEPS $0.64 · IVA $1.38'), findsOneWidget);
  });

  testWidgets('C2: a duplicate SKU shows a Spanish message', (tester) async {
    final cat = fake.catalog.categories.single['id'];
    _call('POST', 'products', {
      'categoryId': cat,
      'name': 'Oreja',
      'unit': 'PIECE',
      'ivaRateId': _rate(1600, 'IVA'),
      'variants': [
        {'name': 'Normal', 'priceCents': 1000, 'sku': 'DUP-1'},
      ],
    });
    await _pump(tester);
    await _tap(tester, find.byKey(const Key('create-product-button')));
    await _fillBasics(tester);
    await _type(tester, 'variant-name-0', 'Normal');
    await _type(tester, 'variant-price-0', '11');
    await _type(tester, 'variant-sku-0', 'DUP-1');
    await _tap(tester, find.byKey(const Key('product-save-button')));
    expect(find.text('Ese SKU ya lo usa otra variante'), findsOneWidget);
    expect(fake.catalog.products, hasLength(1));
  });

  testWidgets(
    'C7: day-old days need a percentage, and waste days must come later',
    (tester) async {
      await _pump(tester);
      await _tap(tester, find.byKey(const Key('create-product-button')));
      await _fillBasics(tester);
      await _type(tester, 'variant-name-0', 'Normal');
      await _type(tester, 'variant-price-0', '8');
      await _type(tester, 'dayold-days', '1');
      await _tap(tester, find.byKey(const Key('product-save-button')));
      expect(
        find.text(
          'Escribe los días y el porcentaje de descuento juntos, o deja ambos vacíos',
        ),
        findsOneWidget,
      );

      await _type(tester, 'dayold-percent', '30');
      await _type(tester, 'dayold-waste', '1');
      await _tap(tester, find.byKey(const Key('product-save-button')));
      expect(
        find.text('Los días de merma deben ser más que los días de descuento'),
        findsOneWidget,
      );

      await _type(tester, 'dayold-waste', '3');
      await _tap(tester, find.byKey(const Key('product-save-button')));
      final p = fake.catalog.products.single;
      expect(
        [
          p['dayOldDiscountAfterDays'],
          p['dayOldDiscountBp'],
          p['dayOldWasteAfterDays'],
        ],
        [1, 3000, 3],
      );
    },
  );

  testWidgets(
    'clearing IEPS on an existing product sends null and removes it',
    (tester) async {
      final created = _call('POST', 'products', {
        'categoryId': fake.catalog.categories.single['id'],
        'name': 'Galleta',
        'unit': 'PACKAGE',
        'ivaRateId': _rate(1600, 'IVA'),
        'iepsRateId': _rate(800, 'IEPS'),
        'variants': [
          {'name': 'Normal', 'priceCents': 2500},
        ],
      });
      await _pump(tester);
      await _tap(tester, find.text('Galleta'));
      await _choose(tester, 'product-ieps-field', 'Sin IEPS');
      await _tap(tester, find.byKey(const Key('product-save-button')));
      final p = fake.catalog.products.single;
      expect(p['id'], created['id']);
      expect(p['iepsRateId'], isNull);
    },
  );

  testWidgets(
    'categories and tax rates: create, and an in-use rate cannot be deactivated',
    (tester) async {
      _call('POST', 'products', {
        'categoryId': fake.catalog.categories.single['id'],
        'name': 'Bolillo',
        'unit': 'PIECE',
        'ivaRateId': _rate(0, 'IVA'),
        'variants': [
          {'name': 'Normal', 'priceCents': 300},
        ],
      });
      await _pump(tester);
      await _tap(tester, find.byKey(const Key('tab-categories')));
      await _tap(tester, find.byKey(const Key('create-category-button')));
      await _type(tester, 'category-name-field', 'Pasteles');
      await _tap(tester, find.byKey(const Key('category-save-button')));
      expect(find.text('Pasteles'), findsOneWidget);
      expect(
        fake.catalog.categories.map((c) => c['name']),
        contains('Pasteles'),
      );

      await _tap(tester, find.byKey(const Key('tab-taxes')));
      await _tap(tester, find.byKey(Key('tax-active-${_rate(0, 'IVA')}')));
      expect(
        find.text(
          'Este impuesto lo usan productos; cámbialos antes de desactivarlo',
        ),
        findsOneWidget,
      );

      await _tap(tester, find.byKey(const Key('create-tax-button')));
      await _type(tester, 'tax-name-field', 'IVA 8% frontera');
      await _type(tester, 'tax-percent-field', '8');
      await _tap(tester, find.byKey(const Key('tax-save-button')));
      expect(fake.catalog.taxRates.last['rateBp'], 800);
      expect(find.text('IVA 8% frontera'), findsOneWidget);
    },
  );

  test('percent and basis point helpers', () {
    expect(parsePercentBp('16'), 1600);
    expect(parsePercentBp('8.25'), 825);
    expect(parsePercentBp('101'), isNull);
    expect(parsePercentBp('1.234'), isNull);
    expect(formatBasisPoints(1600), '16');
    expect(formatBasisPoints(825), '8.25');
    expect(formatBasisPoints(850), '8.5');
    expect(parseHexColor('#C46A2B'), const Color(0xFFC46A2B));
    expect(parseHexColor(null), isNull);
  });
}
