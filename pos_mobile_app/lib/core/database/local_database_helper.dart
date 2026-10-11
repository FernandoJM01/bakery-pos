import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseHelper {
  static final LocalDatabaseHelper instance = LocalDatabaseHelper._init();
  static Database? _database;

  LocalDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos_bakery_edge.db');
    return _database!;
  }

  // Allow setting in-memory database for testing
  void setDatabaseForTesting(Database db) {
    _database = db;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE device_config (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cached_users (
        id TEXT PRIMARY KEY,
        branch_id TEXT NOT NULL,
        username TEXT NOT NULL,
        pin_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        synced_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cached_products (
        id TEXT PRIMARY KEY,
        sku TEXT NOT NULL,
        barcode TEXT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        unit TEXT NOT NULL DEFAULT 'PIECE',
        price_cents INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        synced_at INTEGER NOT NULL
      )
    ''');

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

    await db.execute('''
      CREATE TABLE local_sales_orders (
        client_order_id TEXT PRIMARY KEY,
        branch_id TEXT NOT NULL,
        terminal_id TEXT NOT NULL,
        cashier_id TEXT NOT NULL,
        total_cents INTEGER NOT NULL,
        payment_method TEXT NOT NULL DEFAULT 'CASH',
        cash_tendered_cents INTEGER,
        change_due_cents INTEGER,
        client_created_at INTEGER NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'PENDING'
      )
    ''');

    await db.execute('CREATE INDEX idx_sync_queue_status ON sync_queue_ledger(sync_status, created_at)');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
