import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:http/http.dart' as http;
import 'package:pos_mobile_app/core/database/local_database_helper.dart';
import 'package:pos_mobile_app/features/inventory/data/inventory_repository.dart';
import 'package:pos_mobile_app/features/inventory/domain/ledger_event.dart';
import 'package:pos_mobile_app/features/sync/data/background_sync_worker.dart';

class FailingHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw http.ClientException('Network connection failed. Device is OFFLINE.');
  }
}

class SuccessMockHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = '{"accepted_count": 1, "duplicate_count": 0, "processed_event_ids": ["test-evt-1"]}';
    return http.StreamedResponse(
      Stream.value(body.codeUnits),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late InventoryRepositoryImpl inventoryRepo;
  late LocalDatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = LocalDatabaseHelper.instance;
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE local_inventory_balances (
        product_id TEXT PRIMARY KEY,
        current_stock INTEGER NOT NULL DEFAULT 0,
        last_updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE sync_queue_ledger (
        client_event_id TEXT PRIMARY KEY,
        branch_id TEXT NOT NULL,
        terminal_id TEXT NOT NULL,
        event_type TEXT NOT NULL,
        user_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity_change INTEGER NOT NULL,
        batch_number TEXT,
        reference_id TEXT,
        metadata TEXT,
        client_timestamp INTEGER NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'PENDING',
        retry_count INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
    dbHelper.setDatabaseForTesting(db);
    inventoryRepo = InventoryRepositoryImpl(dbHelper: dbHelper);
  });

  tearDown(() async {
    await db.close();
  });

  test('Local inventory repo writes event to SQLite and updates stock atomically without internet', () async {
    final event = LedgerEvent(
      clientEventId: 'test-evt-1',
      branchId: 'branch-1',
      terminalId: 'term-1',
      eventType: LedgerEventType.bakeBatchProduced,
      userId: 'user-1',
      productId: 'prod-sour',
      quantityChange: 24,
      clientTimestamp: DateTime.now(),
    );

    await inventoryRepo.recordEventAndUpdateStock(event);

    final stock = await inventoryRepo.getStock('prod-sour');
    expect(stock, 24);

    final pending = await db.query('sync_queue_ledger', where: 'sync_status = ?', whereArgs: ['PENDING']);
    expect(pending.length, 1);
    expect(pending.first['client_event_id'], 'test-evt-1');
  });

  test('BackgroundSyncWorker retains queue as PENDING when network is offline', () async {
    final event = LedgerEvent(
      clientEventId: 'test-evt-1',
      branchId: 'branch-1',
      terminalId: 'term-1',
      eventType: LedgerEventType.bakeBatchProduced,
      userId: 'user-1',
      productId: 'prod-sour',
      quantityChange: 24,
      clientTimestamp: DateTime.now(),
    );
    await inventoryRepo.recordEventAndUpdateStock(event);

    final worker = BackgroundSyncWorker(
      dbHelper: dbHelper,
      httpClient: FailingHttpClient(),
    );

    final result = await worker.syncPendingEvents();
    expect(result.isSuccess, false);

    // Queue must stay PENDING for next retry
    final pending = await db.query('sync_queue_ledger', where: 'sync_status = ?', whereArgs: ['PENDING']);
    expect(pending.length, 1);
  });

  test('BackgroundSyncWorker flushes queue to SYNCED on HTTP 200 response', () async {
    final event = LedgerEvent(
      clientEventId: 'test-evt-1',
      branchId: 'branch-1',
      terminalId: 'term-1',
      eventType: LedgerEventType.bakeBatchProduced,
      userId: 'user-1',
      productId: 'prod-sour',
      quantityChange: 24,
      clientTimestamp: DateTime.now(),
    );
    await inventoryRepo.recordEventAndUpdateStock(event);

    final worker = BackgroundSyncWorker(
      dbHelper: dbHelper,
      httpClient: SuccessMockHttpClient(),
    );

    final result = await worker.syncPendingEvents();
    expect(result.isSuccess, true);
    expect(result.syncedCount, 1);

    // Queue must now be SYNCED
    final synced = await db.query('sync_queue_ledger', where: 'sync_status = ?', whereArgs: ['SYNCED']);
    expect(synced.length, 1);
  });
}
