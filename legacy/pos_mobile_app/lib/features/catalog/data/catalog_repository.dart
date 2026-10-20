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
    // Panes de Dulce
    Product(
      id: 'c0000000-0000-0000-0000-000000000005',
      sku: 'PAST-CONC',
      name: 'Concha Tradicional',
      category: 'Panes de Dulce',
      priceCents: 250,
      imageAsset: 'assets/products/concha_dulce.jpg',
      variants: [
        ProductVariant(id: 'var-concha-van', name: 'Vainilla Tradicional', priceDeltaCents: 0, skuSuffix: '-VAN'),
        ProductVariant(id: 'var-concha-choc', name: 'Chocolate Belga', priceDeltaCents: 0, skuSuffix: '-CHOC'),
        ProductVariant(id: 'var-concha-fres', name: 'Fresa Silvestre', priceDeltaCents: 0, skuSuffix: '-FRES'),
        ProductVariant(id: 'var-concha-nuez', name: 'Nuez y Canela', priceDeltaCents: 25, skuSuffix: '-NUEZ'),
      ],
    ),
    Product(
      id: 'c0000000-0000-0000-0000-000000000003',
      sku: 'PAST-CROI',
      name: 'Croissant de Mantequilla',
      category: 'Panes de Dulce',
      priceCents: 325,
      imageAsset: 'assets/products/butter_croissant.jpg',
    ),
    Product(
      id: 'c0000000-0000-0000-0000-000000000004',
      sku: 'PAST-CHOC',
      name: 'Pain au Chocolat / Chocolatín',
      category: 'Panes de Dulce',
      priceCents: 375,
      imageAsset: 'assets/products/pain_au_chocolat.jpg',
    ),
    Product(
      id: 'c0000000-0000-0000-0000-000000000008',
      sku: 'PAST-OREJ',
      name: 'Oreja Caramelizada de Hojaldre',
      category: 'Panes de Dulce',
      priceCents: 275,
      imageAsset: 'assets/products/butter_croissant.jpg',
    ),

    // Panes Salados
    Product(
      id: 'c0000000-0000-0000-0000-000000000001',
      sku: 'BREAD-SOUR',
      name: 'Hogaza de Masa Madre (Sourdough)',
      category: 'Panes Salados',
      priceCents: 650,
      imageAsset: 'assets/products/sourdough_loaf.jpg',
    ),
    Product(
      id: 'c0000000-0000-0000-0000-000000000002',
      sku: 'BREAD-BAGU',
      name: 'Baguette Tradicional Rústica',
      category: 'Panes Salados',
      priceCents: 400,
      imageAsset: 'assets/products/artisan_baguette.jpg',
    ),
    Product(
      id: 'c0000000-0000-0000-0000-000000000009',
      sku: 'BREAD-BOLI',
      name: 'Bolillo Rústico de Horno de Piedra',
      category: 'Panes Salados',
      priceCents: 150,
      imageAsset: 'assets/products/artisan_baguette.jpg',
    ),
    Product(
      id: 'c0000000-0000-0000-0000-000000000010',
      sku: 'BREAD-FOCA',
      name: 'Focaccia con Romero y Sal Marina',
      category: 'Panes Salados',
      priceCents: 450,
      imageAsset: 'assets/products/sourdough_loaf.jpg',
    ),

    // Repostería Fina
    Product(
      id: 'c0000000-0000-0000-0000-000000000006',
      sku: 'CAKE-TART',
      name: 'Tarta Fina de Frutos Rojos',
      category: 'Repostería Fina',
      priceCents: 450,
      imageAsset: 'assets/products/berry_tart.jpg',
    ),

    // Cafetería
    Product(
      id: 'c0000000-0000-0000-0000-000000000007',
      sku: 'BEV-COFF',
      name: 'Café Flat White / Especialidad',
      category: 'Cafetería',
      priceCents: 500,
      imageAsset: 'assets/products/flat_white_coffee.jpg',
      variants: [
        ProductVariant(id: 'var-milk-reg', name: 'Leche Entera', priceDeltaCents: 0),
        ProductVariant(id: 'var-milk-oat', name: 'Leche de Avena', priceDeltaCents: 50),
        ProductVariant(id: 'var-milk-alm', name: 'Leche de Almendra', priceDeltaCents: 50),
        ProductVariant(id: 'var-milk-des', name: 'Leche Deslactosada', priceDeltaCents: 0),
      ],
    ),
    Product(
      id: 'c0000000-0000-0000-0000-000000000011',
      sku: 'BEV-OLLA',
      name: 'Café de Olla Tradicional de Barro',
      category: 'Cafetería',
      priceCents: 350,
      imageAsset: 'assets/products/flat_white_coffee.jpg',
      variants: [
        ProductVariant(id: 'var-olla-reg', name: 'Piloncillo y Canela', priceDeltaCents: 0),
        ProductVariant(id: 'var-olla-cit', name: 'Toque de Naranja', priceDeltaCents: 25),
      ],
    ),
  ];

  static String _normalizeCategory(String? cat) {
    if (cat == null) return 'TODOS';
    final upper = cat.trim().toUpperCase();
    if (upper == 'ALL' || upper == 'TODOS') return 'TODOS';
    if (upper == 'BREADS' || upper == 'PANES SALADOS') return 'PANES SALADOS';
    if (upper == 'VIENNOISERIE' || upper == 'PANES DE DULCE' || upper == 'PAN DULCE') return 'PANES DE DULCE';
    if (upper == 'CAKES' || upper == 'REPOSTERÍA FINA' || upper == 'REPOSTERIA FINA' || upper == 'REPOSTERÍA') return 'REPOSTERÍA FINA';
    if (upper == 'BEVERAGES' || upper == 'CAFETERÍA' || upper == 'CAFETERIA' || upper == 'BEBIDAS') return 'CAFETERÍA';
    return upper;
  }

  @override
  Future<List<Product>> getProducts({String? category}) async {
    final norm = _normalizeCategory(category);
    try {
      final db = await dbHelper.database.timeout(const Duration(milliseconds: 1000));
      final List<Map<String, dynamic>> res;
      if (norm == 'TODOS') {
        res = await db.query('cached_products', where: 'is_active = 1', orderBy: 'category, name ASC').timeout(const Duration(milliseconds: 1000));
      } else {
        res = await db.query(
          'cached_products',
          where: 'is_active = 1 AND UPPER(category) = ?',
          whereArgs: [norm],
          orderBy: 'name ASC',
        ).timeout(const Duration(milliseconds: 1000));
      }
      if (res.isNotEmpty) {
        return res.map((m) => Product.fromMap(m)).toList();
      }
    } catch (_) {}

    if (norm == 'TODOS') {
      return defaultProducts;
    }
    return defaultProducts.where((p) => _normalizeCategory(p.category) == norm).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final db = await dbHelper.database.timeout(const Duration(milliseconds: 1000));
      final res = await db.rawQuery('SELECT DISTINCT category FROM cached_products WHERE is_active = 1 ORDER BY category').timeout(const Duration(milliseconds: 1000));
      final cats = res.map((m) => m['category'] as String).toList();
      if (cats.isNotEmpty) {
        return ['Todos', ...cats];
      }
    } catch (_) {}

    return ['Todos', 'Panes de Dulce', 'Panes Salados', 'Repostería Fina', 'Cafetería'];
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
