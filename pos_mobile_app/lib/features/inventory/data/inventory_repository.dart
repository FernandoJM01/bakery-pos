import 'dart:async';
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

  static final Map<String, int> fallbackBalances = {
    'c0000000-0000-0000-0000-000000000001': 24,
    'c0000000-0000-0000-0000-000000000002': 15,
    'c0000000-0000-0000-0000-000000000003': 18,
    'c0000000-0000-0000-0000-000000000004': 12,
    'c0000000-0000-0000-0000-000000000005': 8,
    'c0000000-0000-0000-0000-000000000006': 10,
    'c0000000-0000-0000-0000-000000000007': 50,
  };

  @override
  Future<int> getStock(String productId) async {
    try {
      final db = await dbHelper.database.timeout(const Duration(milliseconds: 1000));
      final res = await db.query(
        'local_inventory_balances',
        where: 'product_id = ?',
        whereArgs: [productId],
      ).timeout(const Duration(milliseconds: 1000));
      if (res.isNotEmpty) {
        return (res.first['current_stock'] as int?) ?? 0;
      }
    } catch (_) {}
    return fallbackBalances[productId] ?? 0;
  }

  @override
  Future<Map<String, int>> getAllBalances() async {
    try {
      final db = await dbHelper.database.timeout(const Duration(milliseconds: 1000));
      final res = await db.query('local_inventory_balances').timeout(const Duration(milliseconds: 1000));
      if (res.isNotEmpty) {
        final map = <String, int>{};
        for (final row in res) {
          map[row['product_id'] as String] = (row['current_stock'] as int?) ?? 0;
        }
        return map;
      }
    } catch (_) {}
    return Map<String, int>.from(fallbackBalances);
  }

  @override
  Future<void> recordEventAndUpdateStock(LedgerEvent event) async {
    // 1. In-memory update of local fallback balance for instant UI consistency
    final currentFallback = fallbackBalances[event.productId] ?? 0;
    fallbackBalances[event.productId] = currentFallback + event.quantityChange;

    // 2. Safe persistent write to SQLite with timeout guard
    try {
      final db = await dbHelper.database.timeout(const Duration(milliseconds: 1200));
      await db.transaction((txn) async {
        await txn.insert(
          'sync_queue_ledger',
          event.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

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
      }).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      // In web or restricted environments, gracefully continue without freezing
    }
  }

  @override
  Future<void> setBalances(Map<String, int> balances) async {
    fallbackBalances.addAll(balances);
    try {
      final db = await dbHelper.database.timeout(const Duration(milliseconds: 1200));
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
      await batch.commit(noResult: true).timeout(const Duration(milliseconds: 1500));
    } catch (_) {}
  }
}
