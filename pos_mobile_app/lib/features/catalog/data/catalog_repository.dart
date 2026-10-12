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

  static const List<Product> defaultProducts = [
    Product(id: 'c0000000-0000-0000-0000-000000000001', sku: 'BREAD-SOUR', name: 'Sourdough Country Loaf', category: 'Breads', priceCents: 650, imageAsset: 'assets/products/sourdough_loaf.jpg'),
    Product(id: 'c0000000-0000-0000-0000-000000000002', sku: 'BREAD-BAGU', name: 'Artisan Baguette', category: 'Breads', priceCents: 400, imageAsset: 'assets/products/artisan_baguette.jpg'),
    Product(id: 'c0000000-0000-0000-0000-000000000003', sku: 'PAST-CROI', name: 'Butter Croissant', category: 'Viennoiserie', priceCents: 325, imageAsset: 'assets/products/butter_croissant.jpg'),
    Product(id: 'c0000000-0000-0000-0000-000000000004', sku: 'PAST-CHOC', name: 'Pain au Chocolat', category: 'Viennoiserie', priceCents: 375, imageAsset: 'assets/products/pain_au_chocolat.jpg'),
    Product(id: 'c0000000-0000-0000-0000-000000000006', sku: 'CAKE-TART', name: 'Berry Patisserie Tart', category: 'Cakes', priceCents: 450, imageAsset: 'assets/products/berry_tart.jpg'),
    Product(id: 'c0000000-0000-0000-0000-000000000007', sku: 'BEV-COFF', name: 'Flat White Coffee', category: 'Beverages', priceCents: 500, imageAsset: 'assets/products/flat_white_coffee.jpg'),
  ];

  @override
  Future<List<Product>> getProducts({String? category}) async {
    try {
      final db = await dbHelper.database.timeout(const Duration(milliseconds: 1000));
      final List<Map<String, dynamic>> res;
      if (category == null || category.toUpperCase() == 'ALL') {
        res = await db.query('cached_products', where: 'is_active = 1', orderBy: 'category, name ASC').timeout(const Duration(milliseconds: 1000));
      } else {
        res = await db.query(
          'cached_products',
          where: 'is_active = 1 AND LOWER(category) = ?',
          whereArgs: [category.toLowerCase()],
          orderBy: 'name ASC',
        ).timeout(const Duration(milliseconds: 1000));
      }
      if (res.isNotEmpty) {
        return res.map((m) => Product.fromMap(m)).toList();
      }
    } catch (_) {}

    if (category == null || category.toUpperCase() == 'ALL') {
      return defaultProducts;
    }
    return defaultProducts.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final db = await dbHelper.database.timeout(const Duration(milliseconds: 1000));
      final res = await db.rawQuery('SELECT DISTINCT category FROM cached_products WHERE is_active = 1 ORDER BY category').timeout(const Duration(milliseconds: 1000));
      final cats = res.map((m) => m['category'] as String).toList();
      if (cats.isNotEmpty) {
        return ['All', ...cats];
      }
    } catch (_) {}

    return ['All', 'Breads', 'Viennoiserie', 'Cakes', 'Beverages'];
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
