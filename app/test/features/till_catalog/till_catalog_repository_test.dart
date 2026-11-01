import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/features/till_catalog/data/till_catalog_repository.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds catalog rows in the fake server, the way the back office would.
class _Owner {
  _Owner(this.fake);

  final FakeApiInterceptor fake;

  Map<String, dynamic> call(String method, String path, [Object? body]) =>
      (fake.catalog.handle(method, '/v1/$path', const {}, body)!.body ??
              <String, dynamic>{})
          as Map<String, dynamic>;

  String rate(int bp) =>
      fake.catalog.taxRates.firstWhere((t) => t['rateBp'] == bp)['id']
          as String;

  String category(String name) =>
      call('POST', 'categories', {'name': name, 'color': '#C46A2B'})['id']
          as String;

  Map<String, dynamic> product(
    String categoryId,
    String name,
    List<int> prices,
  ) => call('POST', 'products', {
    'categoryId': categoryId,
    'name': name,
    'unit': 'PIECE',
    'ivaRateId': rate(1600),
    'variants': [
      for (final (i, p) in prices.indexed) {'name': 'V$i', 'priceCents': p},
    ],
  });
}

void main() {
  late FakeApiInterceptor fake;
  late _Owner owner;
  late AppDatabase db;
  late TillCatalogRepository repo;

  setUp(() {
    fake = FakeApiInterceptor();
    owner = _Owner(fake);
    db = AppDatabase(NativeDatabase.memory());
    final dio = Dio()..interceptors.add(fake);
    repo = TillCatalogRepository(db, RestClient(dio).sync);
  });

  tearDown(() => db.close());

  test('C3: a first pull gets the new product, the next gets nothing, an edit only the edited rows', () async {
    final cat = owner.category('Pan dulce');
    final p = owner.product(cat, 'Concha', [1200]);

    expect(await repo.pull(), greaterThan(0));
    final first = await repo.load();
    expect(first.products.single.name, 'Concha');
    expect(first.products.single.lowestPriceCents, 1200);
    final seq = await repo.lastSeq();
    expect(seq, greaterThan(0));

    expect(await repo.pull(), 0);
    expect(await repo.lastSeq(), seq);

    owner.call('PATCH', 'products/${p['id']}', {'name': 'Concha de vainilla'});
    expect(await repo.pull(), 1);
    expect((await repo.load()).products.single.name, 'Concha de vainilla');
  });

  test('C3: pages are applied until hasMore is false', () async {
    final cat = owner.category('Pan dulce');
    for (var i = 0; i < 6; i++) {
      owner.product(cat, 'Pan $i', [100 + i]);
    }
    // 3 tax rates, 1 category, 6 products, 6 variants = 16 rows.
    expect(await repo.pull(pageSize: 5), 16);
    expect((await repo.load()).products, hasLength(6));
  });

  test('C4: this branch\'s price applies, the other branch\'s never arrives, removal restores the base', () async {
    final cat = owner.category('Pan salado');
    final p = owner.product(cat, 'Bolillo', [300]);
    final v = (p['variants'] as List).first['id'] as String;
    owner.call('PUT', 'variants/$v/branch-prices/${fake.branchId1}', {
      'priceCents': 350,
    });
    owner.call('PUT', 'variants/$v/branch-prices/${fake.branchId2}', {
      'priceCents': 400,
    });

    await repo.pull();
    expect((await repo.load()).products.single.lowestPriceCents, 350);
    expect(await db.select(db.catalogBranchPrices).get(), hasLength(1));

    owner.call('DELETE', 'variants/$v/branch-prices/${fake.branchId1}');
    await repo.pull();
    expect((await repo.load()).products.single.lowestPriceCents, 300);
    expect(await db.select(db.catalogBranchPrices).get(), isEmpty);
  });

  test('inactive products, variants and categories are hidden', () async {
    final cat = owner.category('Pan dulce');
    final hiddenCat = owner.category('Temporada');
    final a = owner.product(cat, 'Concha', [1200, 1500]);
    final b = owner.product(cat, 'Oreja', [1000]);
    owner.product(hiddenCat, 'Rosca', [30000]);
    owner.call('PATCH', 'products/${b['id']}', {'isActive': false});
    owner.call('PATCH', 'categories/$hiddenCat', {'isActive': false});
    final firstVariant = (a['variants'] as List).first['id'];
    owner.call('PATCH', 'variants/$firstVariant', {'isActive': false});

    await repo.pull();
    final c = await repo.load();
    expect(c.categories.map((x) => x.name), ['Pan dulce']);
    expect(c.products.map((x) => x.name), ['Concha']);
    expect(c.products.single.variants.map((v) => v.priceCents), [1500]);
  });

  test('an offline pull fails without touching the stored catalog', () async {
    owner.product(owner.category('Pan dulce'), 'Concha', [1200]);
    await repo.pull();
    final seq = await repo.lastSeq();
    final offline = TillCatalogRepository(
      db,
      RestClient(Dio(BaseOptions(baseUrl: 'http://127.0.0.1:9'))).sync,
    );
    await expectLater(offline.pull(), throwsA(isA<DioException>()));
    expect(await repo.lastSeq(), seq);
    expect((await repo.load()).products, hasLength(1));
  });

  test('search matches name, variant, SKU and barcode, ignoring accents', () {
    const products = [
      GridProduct(
        id: '1',
        categoryId: 'c',
        name: 'Piña rellena',
        photoId: null,
        variants: [
          GridVariant(
            id: 'a',
            name: 'Chica',
            sku: 'PIN-1',
            barcode: '7501234',
            priceCents: 1,
          ),
        ],
      ),
      GridProduct(
        id: '2',
        categoryId: 'c',
        name: 'Concha',
        photoId: null,
        variants: [
          GridVariant(
            id: 'b',
            name: 'Grande',
            sku: null,
            barcode: null,
            priceCents: 1,
          ),
        ],
      ),
    ];
    List<String> ids(String q) =>
        searchProducts(products, q).map((p) => p.id).toList();
    expect(ids('pina'), ['1']);
    expect(ids('CONCHA'), ['2']);
    expect(ids('grande'), ['2']);
    expect(ids('pin-1'), ['1']);
    expect(ids('7501234'), ['1']);
    expect(ids(''), ['1', '2']);
    expect(ids('rosca'), isEmpty);
  });
}
