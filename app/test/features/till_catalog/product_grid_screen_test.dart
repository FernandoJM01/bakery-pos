import 'dart:typed_data';

import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/theme/appearance_settings.dart';
import 'package:bakery_pos/features/till_catalog/data/photo_cache.dart';
import 'package:bakery_pos/features/till_catalog/data/till_catalog_repository.dart';
import 'package:bakery_pos/features/till_catalog/presentation/product_grid_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoPhotos implements PhotoCache {
  final asked = <String>[];

  @override
  Future<Uint8List?> get(String photoId) async {
    asked.add(photoId);
    return null;
  }
}

void main() {
  testWidgets(
    'the grid shows active products with effective prices, filters by category and search',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fake = FakeApiInterceptor();
      Map<String, dynamic> call(String m, String path, [Object? body]) =>
          (fake.catalog.handle(m, '/v1/$path', const {}, body)!.body ??
                  <String, dynamic>{})
              as Map<String, dynamic>;
      final iva = fake.catalog.taxRates.firstWhere(
        (t) => t['rateBp'] == 1600,
      )['id'];
      final dulce = call('POST', 'categories', {
        'name': 'Pan dulce',
        'color': '#C46A2B',
      })['id'];
      final salado = call('POST', 'categories', {
        'name': 'Pan salado',
        'color': '#E0A84F',
      })['id'];
      Map<String, dynamic> product(
        Object cat,
        String name,
        List<int> prices, {
        String? photoId,
      }) => call('POST', 'products', {
        'categoryId': cat,
        'name': name,
        'unit': 'PIECE',
        'ivaRateId': iva,
        'photoId': photoId,
        'variants': [
          for (final (i, p) in prices.indexed)
            {'name': 'V$i', 'priceCents': p, 'sku': 'SKU-$name-$i'},
        ],
      });
      product(dulce, 'Concha de vainilla', [
        1200,
        1500,
      ], photoId: '0192e2b0-7eff-7000-8000-000000000001');
      final bolillo = product(salado, 'Bolillo', [300]);
      final v = (bolillo['variants'] as List).first['id'];
      call('PUT', 'variants/$v/branch-prices/${fake.branchId1}', {
        'priceCents': 350,
      });

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = TillCatalogRepository(
        db,
        RestClient(Dio()..interceptors.add(fake)).sync,
      );
      await tester.runAsync(repo.pull);
      final photos = _NoPhotos();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tillCatalogRepositoryProvider.overrideWithValue(repo),
            photoCacheProvider.overrideWithValue(photos),
          ],
          child: MaterialApp(
            locale: const Locale('es', 'MX'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: ProductGridScreen()),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Concha de vainilla'), findsOneWidget);
      expect(find.text(r'Desde $12.00'), findsOneWidget);
      // SUC1's branch price, not the base price.
      expect(find.text(r'$3.50'), findsOneWidget);
      // No photo cached: the category color with initials, never a broken image.
      expect(find.text('CV'), findsOneWidget);
      expect(find.text('BO'), findsOneWidget);
      expect(photos.asked, ['0192e2b0-7eff-7000-8000-000000000001']);

      await tester.tap(find.text('Pan salado'));
      await tester.pumpAndSettle();
      expect(find.text('Concha de vainilla'), findsNothing);
      expect(find.text('Bolillo'), findsOneWidget);

      await tester.tap(find.text('Todo'));
      await tester.enterText(
        find.byKey(const Key('grid-search')),
        'sku-concha',
      );
      await tester.pumpAndSettle();
      expect(find.text('Concha de vainilla'), findsOneWidget);
      expect(find.text('Bolillo'), findsNothing);
    },
  );

  testWidgets('name-only button style hides the photo slot', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = FakeApiInterceptor();
    final iva = fake.catalog.taxRates.firstWhere(
      (t) => t['rateBp'] == 1600,
    )['id'];
    final cat =
        (fake.catalog.handle('POST', '/v1/categories', const {}, {
              'name': 'Pan',
            })!.body
            as Map)['id'];
    fake.catalog.handle('POST', '/v1/products', const {}, {
      'categoryId': cat,
      'name': 'Concha',
      'unit': 'PIECE',
      'ivaRateId': iva,
      'variants': [
        {'name': 'Normal', 'priceCents': 1200},
      ],
    });
    final repo = TillCatalogRepository(
      db,
      RestClient(Dio()..interceptors.add(fake)).sync,
    );
    await tester.runAsync(repo.pull);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tillCatalogRepositoryProvider.overrideWithValue(repo),
          photoCacheProvider.overrideWithValue(_NoPhotos()),
          appearanceSettingsProvider.overrideWith(
            () => AppearanceSettingsNotifier(
              const AppearanceSettings(
                buttonStyle: ProductButtonStyle.nameOnly,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: ProductGridScreen()),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Concha'), findsOneWidget);
    expect(find.text('CO'), findsNothing);
  });

  test('initials', () {
    expect(productInitials('Concha de vainilla'), 'CV');
    expect(productInitials('Bolillo'), 'BO');
    expect(productInitials('Té'), 'TÉ');
    expect(productInitials('Pan de muerto'), 'PM');
  });
}
