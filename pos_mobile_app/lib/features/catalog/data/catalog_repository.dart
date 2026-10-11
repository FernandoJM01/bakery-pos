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

  @override
  Future<List<Product>> getProducts({String? category}) async {
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
    return res.map((m) => Product.fromMap(m)).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final db = await dbHelper.database;
    final res = await db.rawQuery('SELECT DISTINCT category FROM cached_products WHERE is_active = 1 ORDER BY category');
    final cats = res.map((m) => m['category'] as String).toList();
    return ['ALL', ...cats];
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
