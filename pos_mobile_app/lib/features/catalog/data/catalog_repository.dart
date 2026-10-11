import 'package:sqflite/sqflite.dart';
import '../../../core/database/local_database_helper.dart';
import '../domain/product.dart';

abstract class CatalogRepository {
  Future<List<Product>> getProducts({String? category});
  Future<List<String>> getCategories();
  Future<void> cacheProducts(List<Product> products);
}

class CatalogRepositoryImpl implements CatalogRepository {
  final LocalDatabaseHelper dbHelper;

  CatalogRepositoryImpl({LocalDatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? LocalDatabaseHelper.instance;

  static const List<Product> _defaultProducts = [
    Product(id: 'c0000000-0000-0000-0000-000000000001', sku: 'BREAD-SOUR', name: 'Sourdough Loaf', category: 'Breads', priceCents: 650),
    Product(id: 'c0000000-0000-0000-0000-000000000002', sku: 'BREAD-BAGU', name: 'Artisan Baguette', category: 'Breads', priceCents: 400),
    Product(id: 'c0000000-0000-0000-0000-000000000003', sku: 'PAST-CROI', name: 'Butter Croissant', category: 'Pastries', priceCents: 325),
    Product(id: 'c0000000-0000-0000-0000-000000000004', sku: 'PAST-CHOC', name: 'Pain au Chocolat', category: 'Pastries', priceCents: 375),
    Product(id: 'c0000000-0000-0000-0000-000000000005', sku: 'PAST-CINN', name: 'Cinnamon Roll', category: 'Pastries', priceCents: 400),
    Product(id: 'c0000000-0000-0000-0000-000000000006', sku: 'CAKE-ECLR', name: 'Chocolate Eclair', category: 'Cakes', priceCents: 450),
    Product(id: 'c0000000-0000-0000-0000-000000000007', sku: 'BEV-COFF', name: 'Flat White Coffee', category: 'Beverages', priceCents: 500),
  ];

  @override
  Future<List<Product>> getProducts({String? category}) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> res;
      if (category == null || category == 'ALL') {
        res = await db.query('cached_products', where: 'is_active = 1', orderBy: 'category, name ASC');
      } else {
        res = await db.query(
          'cached_products',
          where: 'is_active = 1 AND category = ?',
          whereArgs: [category],
          orderBy: 'name ASC',
        );
      }
      if (res.isNotEmpty) {
        return res.map((m) => Product.fromMap(m)).toList();
      }
    } catch (_) {}

    if (category == null || category == 'ALL') {
      return _defaultProducts;
    }
    return _defaultProducts.where((p) => p.category == category).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final db = await dbHelper.database;
      final res = await db.rawQuery('SELECT DISTINCT category FROM cached_products WHERE is_active = 1 ORDER BY category');
      final cats = res.map((m) => m['category'] as String).toList();
      if (cats.isNotEmpty) {
        return ['ALL', ...cats];
      }
    } catch (_) {}

    return ['ALL', 'Breads', 'Pastries', 'Cakes', 'Beverages'];
  }

  @override
  Future<void> cacheProducts(List<Product> products) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (final p in products) {
      batch.insert('cached_products', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
