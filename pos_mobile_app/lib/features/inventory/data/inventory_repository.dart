import 'package:sqflite/sqflite.dart';
import '../../../core/database/local_database_helper.dart';
import '../domain/ledger_event.dart';

abstract class InventoryRepository {
  Future<int> getStock(String productId);
  Future<Map<String, int>> getAllBalances();
  Future<void> recordEventAndUpdateStock(LedgerEvent event);
  Future<void> setBalances(Map<String, int> balances);
}

class InventoryRepositoryImpl implements InventoryRepository {
  final LocalDatabaseHelper dbHelper;

  InventoryRepositoryImpl({LocalDatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? LocalDatabaseHelper.instance;

  @override
  Future<int> getStock(String productId) async {
    final db = await dbHelper.database;
    final res = await db.query(
      'local_inventory_balances',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    if (res.isEmpty) return 0;
    return (res.first['current_stock'] as int?) ?? 0;
  }

  @override
  Future<Map<String, int>> getAllBalances() async {
    final db = await dbHelper.database;
    final res = await db.query('local_inventory_balances');
    final map = <String, int>{};
    for (final row in res) {
      map[row['product_id'] as String] = (row['current_stock'] as int?) ?? 0;
    }
    return map;
  }

  @override
  Future<void> recordEventAndUpdateStock(LedgerEvent event) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      // 1. Insert into sync queue
      await txn.insert(
        'sync_queue_ledger',
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Atomically update local_inventory_balances
      final existing = await txn.query(
        'local_inventory_balances',
        where: 'product_id = ?',
        whereArgs: [event.productId],
      );

      final now = DateTime.now().millisecondsSinceEpoch;
      if (existing.isEmpty) {
        await txn.insert('local_inventory_balances', {
          'product_id': event.productId,
          'current_stock': event.quantityChange,
          'last_updated_at': now,
        });
      } else {
        final current = (existing.first['current_stock'] as int?) ?? 0;
        final updated = current + event.quantityChange;
        await txn.update(
          'local_inventory_balances',
          {
            'current_stock': updated,
            'last_updated_at': now,
          },
          where: 'product_id = ?',
          whereArgs: [event.productId],
        );
      }
    });
  }

  @override
  Future<void> setBalances(Map<String, int> balances) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;
    balances.forEach((productId, stock) {
      batch.insert(
        'local_inventory_balances',
        {
          'product_id': productId,
          'current_stock': stock,
          'last_updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true);
  }
}
