import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import '../../../core/database/local_database_helper.dart';
import '../../inventory/domain/ledger_event.dart';

class SyncResult {
  final bool isSuccess;
  final int syncedCount;
  final String? message;

  const SyncResult({
    required this.isSuccess,
    required this.syncedCount,
    this.message,
  });
}

class BackgroundSyncWorker {
  final LocalDatabaseHelper dbHelper;
  final String backendUrl;
  final http.Client httpClient;
  bool _isSyncing = false;

  BackgroundSyncWorker({
    LocalDatabaseHelper? dbHelper,
    this.backendUrl = 'http://127.0.0.1:3001',
    http.Client? httpClient,
  })  : dbHelper = dbHelper ?? LocalDatabaseHelper.instance,
        httpClient = httpClient ?? http.Client();

  bool get isSyncing => _isSyncing;

  /// Pull pending ledger events and push them in a single batch to NestJS /sync/push
  Future<SyncResult> syncPendingEvents() async {
    if (_isSyncing) {
      return const SyncResult(isSuccess: false, syncedCount: 0, message: 'Sync already in progress');
    }

    _isSyncing = true;
    try {
      final db = await dbHelper.database;
      final pendingRows = await db.query(
        'sync_queue_ledger',
        where: 'sync_status = ?',
        whereArgs: ['PENDING'],
        orderBy: 'created_at ASC',
        limit: 100,
      );

      if (pendingRows.isEmpty) {
        _isSyncing = false;
        return const SyncResult(isSuccess: true, syncedCount: 0, message: 'Queue is clean');
      }

      final events = pendingRows.map((m) => LedgerEvent.fromMap(m)).toList();
      final branchId = events.first.branchId;
      final terminalId = events.first.terminalId;

      final payload = {
        'branch_id': branchId,
        'terminal_id': terminalId,
        'events': events.map((e) => e.toApiJson()).toList(),
      };

      final response = await httpClient.post(
        Uri.parse('$backendUrl/sync/push'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Clear / mark synced on HTTP 200 OK
        final clientEventIds = events.map((e) => e.clientEventId).toList();
        final batch = db.batch();
        for (final id in clientEventIds) {
          batch.update(
            'sync_queue_ledger',
            {'sync_status': 'SYNCED'},
            where: 'client_event_id = ?',
            whereArgs: [id],
          );
        }
        await batch.commit(noResult: true);

        _isSyncing = false;
        return SyncResult(
          isSuccess: true,
          syncedCount: events.length,
          message: 'Synced ${events.length} events successfully',
        );
      } else {
        _isSyncing = false;
        return SyncResult(
          isSuccess: false,
          syncedCount: 0,
          message: 'Server error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _isSyncing = false;
      return SyncResult(
        isSuccess: false,
        syncedCount: 0,
        message: 'Network offline or unreachable: $e',
      );
    }
  }

  /// Pull catalog and stock balances snapshot from backend
  Future<bool> pullSnapshot(String branchId) async {
    try {
      final res = await httpClient.get(
        Uri.parse('$backendUrl/sync/pull/$branchId'),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final db = await dbHelper.database;
        final now = DateTime.now().millisecondsSinceEpoch;

        final batch = db.batch();
        // Update products
        final products = data['products'] as List;
        for (final p in products) {
          batch.insert(
            'cached_products',
            {
              'id': p['id'],
              'sku': p['sku'],
              'barcode': p['barcode'],
              'name': p['name'],
              'category': p['category'],
              'unit': p['unit'] ?? 'PIECE',
              'price_cents': p['price_cents'],
              'is_active': p['is_active'] ? 1 : 0,
              'synced_at': now,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Update balances
        final balances = data['balances'] as List;
        for (final b in balances) {
          batch.insert(
            'local_inventory_balances',
            {
              'product_id': b['product_id'],
              'current_stock': b['current_stock'],
              'last_updated_at': now,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Update cached users
        final users = data['users'] as List;
        for (final u in users) {
          batch.insert(
            'cached_users',
            {
              'id': u['id'],
              'branch_id': u['branch_id'] ?? branchId,
              'username': u['username'],
              'pin_hash': u['pin_hash'],
              'full_name': u['full_name'],
              'role': u['role'],
              'is_active': u['is_active'] ? 1 : 0,
              'synced_at': now,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        await batch.commit(noResult: true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[BackgroundSyncWorker] pullSnapshot error: $e');
      return false;
    }
  }
}
