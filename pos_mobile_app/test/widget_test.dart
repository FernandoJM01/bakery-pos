import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:http/http.dart' as http;
import 'package:pos_mobile_app/core/database/local_database_helper.dart';
import 'package:pos_mobile_app/features/sync/data/background_sync_worker.dart';
import 'package:pos_mobile_app/features/auth/presentation/pin_login_screen.dart';
import 'package:pos_mobile_app/main.dart';

class NoopHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value('{"products":[],"balances":[],"users":[]}'.codeUnits),
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

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
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
    LocalDatabaseHelper.instance.setDatabaseForTesting(db);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('Renders PosBakeryApp and PinLoginScreen', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncWorkerProvider.overrideWithValue(
              BackgroundSyncWorker(
                dbHelper: LocalDatabaseHelper.instance,
                httpClient: NoopHttpClient(),
              ),
            ),
          ],
          child: const PosBakeryApp(),
        ),
      );
      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 200));
    });

    await tester.pump();

    expect(find.byType(PinLoginScreen), findsOneWidget);
    expect(find.text('ARTISAN BAKERY'), findsOneWidget);
    expect(find.text('Personal en Turno'), findsOneWidget);
  });
}
