import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/models/catalog_changes.dart';
import 'package:bakery_pos/core/api/generated/models/product.dart';
import 'package:bakery_pos/core/api/generated/models/sync_push_response.dart';
import 'package:bakery_pos/core/api/generated/models/tax_rate.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeApiInterceptor fake;
  late Dio dio;

  setUp(() {
    fake = FakeApiInterceptor();
    dio = Dio(BaseOptions(baseUrl: 'http://fake'))..interceptors.add(fake);
  });

  Future<Map<String, dynamic>> get(
    String path, [
    Map<String, dynamic>? q,
  ]) async =>
      (await dio.get<Map<String, dynamic>>(path, queryParameters: q)).data!;

  Future<String> ivaId() async {
    final rates = (await dio.get<List<dynamic>>('/v1/tax-rates')).data!
        .map((r) => TaxRate.fromJson(r as Map<String, dynamic>));
    return rates.firstWhere((r) => r.rateBp == 1600).id;
  }

  Future<Product> createProduct(String categoryId, {String? sku}) async {
    final res = await dio.post<Map<String, dynamic>>(
      '/v1/products',
      data: {
        'categoryId': categoryId,
        'name': 'Concha',
        'unit': 'PIECE',
        'ivaRateId': await ivaId(),
        'variants': [
          {'name': 'Chica', 'priceCents': 900, 'sku': ?sku},
          {'name': 'Grande', 'priceCents': 1500},
        ],
      },
    );
    return Product.fromJson(res.data!);
  }

  Future<String> category() async =>
      (await dio.post<Map<String, dynamic>>(
            '/v1/categories',
            data: {'name': 'Pan dulce', 'color': '#C46A2B'},
          )).data!['id']
          as String;

  test('catalog writes come back as contract models', () async {
    final p = await createProduct(await category(), sku: 'CH-1');
    expect(p.variants.map((v) => v.name), ['Chica', 'Grande']);

    final page = await get('/v1/products', {'q': 'ch-1'});
    expect((page['items'] as List).length, 1);
  });

  test('a duplicate SKU is a 409 naming the field', () async {
    final cat = await category();
    await createProduct(cat, sku: 'CH-1');
    await expectLater(
      createProduct(cat, sku: 'CH-1'),
      throwsA(
        isA<DioException>().having(
          (e) => (e.response!.data as Map)['details'],
          'details',
          {'field': 'sku'},
        ),
      ),
    );
  });

  test(
    'the sync feed pages in change order and sends removed branch prices',
    () async {
      final p = await createProduct(await category());
      final first = CatalogChanges.fromJson(
        await get('/v1/sync/catalog', {'since': 0, 'limit': 3}),
      );
      expect(first.hasMore, isTrue);
      expect(first.taxRates.length, 3);

      final rest = CatalogChanges.fromJson(
        await get('/v1/sync/catalog', {'since': first.nextSince}),
      );
      expect(rest.hasMore, isFalse);
      expect(rest.products.single.id, p.id);
      expect(rest.variants.length, 2);

      final v = p.variants.first.id;
      await dio.put<void>(
        '/v1/variants/$v/branch-prices/${fake.branchId1}',
        data: {'priceCents': 950},
      );
      await dio.put<void>(
        '/v1/variants/$v/branch-prices/${fake.branchId2}',
        data: {'priceCents': 990},
      );
      final prices = CatalogChanges.fromJson(
        await get('/v1/sync/catalog', {'since': rest.nextSince}),
      );
      expect(prices.branchPrices.single.priceCents, 950);

      await dio.delete<void>('/v1/variants/$v/branch-prices/${fake.branchId1}');
      final removed = CatalogChanges.fromJson(
        await get('/v1/sync/catalog', {'since': prices.nextSince}),
      );
      expect(removed.branchPrices.single.removed, isTrue);
      expect(removed.branchPrices.single.priceCents, isNull);
    },
  );

  test('push applies once, then reports duplicates and quarantine', () async {
    Map<String, dynamic> rec(String id, [Map<String, dynamic>? extra]) => {
      'id': id,
      'type': 'audit.offline_event',
      'occurredAt': '2026-11-01T12:00:00.000Z',
      'payload': {
        'action': 'auth.login_success',
        'staffId': fake.cashierId,
        ...?extra,
      },
    };
    Future<SyncPushResponse> push(List<Object> records) async =>
        SyncPushResponse.fromJson(
          (await dio.post<Map<String, dynamic>>(
            '/v1/sync/push',
            data: {'records': records},
          )).data!,
        );

    final first = await push([
      rec('r1'),
      rec('r2', {'pin': '1234'}),
    ]);
    expect(first.results.map((r) => r.status.name), ['applied', 'quarantined']);
    final again = await push([rec('r1'), rec('r2')]);
    expect(again.results.map((r) => r.status.name), [
      'duplicate',
      'quarantined',
    ]);

    final open = await get('/v1/sync/quarantine');
    expect((open['items'] as List).single['payload'], isNot(contains('pin')));
    await dio.post<void>(
      '/v1/sync/quarantine/r2/resolve',
      data: {'note': 'ok'},
    );
    expect((await get('/v1/sync/quarantine'))['items'], isEmpty);
  });
}
