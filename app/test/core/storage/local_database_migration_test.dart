import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('Database Migration', () {
    test('upgrades v1 schema to the current version and creates staffLockoutEntries and offlineApprovalEntries tables', () async {
      final sqliteDb = sqlite3.openInMemory();

      // Create v1 tables and set user_version = 1
      sqliteDb.execute('''
        CREATE TABLE staff_entries (
          id TEXT NOT NULL PRIMARY KEY,
          display_name TEXT NOT NULL,
          role TEXT NOT NULL,
          offline_pin_verifier TEXT NOT NULL,
          pin_updated_at INTEGER NOT NULL
        );
        CREATE TABLE role_permissions (
          role TEXT NOT NULL,
          permission_key TEXT NOT NULL,
          PRIMARY KEY (role, permission_key)
        );
        CREATE TABLE session_state_entries (
          key TEXT NOT NULL PRIMARY KEY,
          value TEXT NOT NULL
        );
        PRAGMA user_version = 1;
      ''');

      final userVerBefore = sqliteDb
          .select('PRAGMA user_version;')
          .first
          .values
          .first;
      expect(userVerBefore, 1);

      // Open AppDatabase with the existing connection
      final appDb = AppDatabase(NativeDatabase.opened(sqliteDb));

      // Attempting to query/record lockout triggers migration
      final lockout = await appDb.recordFailedPinAttempt(
        'staff-1',
        DateTime.utc(2026, 1, 1),
      );
      expect(lockout, isNull);

      final entry = await appDb.getLockout('staff-1');
      expect(entry, isNotNull);
      expect(entry!.failedAttempts, 1);

      // Verify offline_approval_entries was created
      await appDb.recordOfflineApproval(
        id: 'approval-1',
        approverStaffId: 'staff-1',
        requesterStaffId: 'staff-2',
        action: 'cash.open_drawer_no_sale',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final approvals = await appDb.getOfflineApprovals();
      expect(approvals.length, 1);
      expect(approvals.first.id, 'approval-1');
      expect(approvals.first.requesterStaffId, 'staff-2');
      expect(approvals.first.syncedAt, isNull);

      final userVerAfter = sqliteDb
          .select('PRAGMA user_version;')
          .first
          .values
          .first;
      expect(userVerAfter, 11);

      await appDb.close();
    });

    test('upgrades v2 schema to the current version and creates offlineApprovalEntries', () async {
      final sqliteDb = sqlite3.openInMemory();

      sqliteDb.execute('''
        CREATE TABLE staff_entries (
          id TEXT NOT NULL PRIMARY KEY,
          display_name TEXT NOT NULL,
          role TEXT NOT NULL,
          offline_pin_verifier TEXT NOT NULL,
          pin_updated_at INTEGER NOT NULL
        );
        CREATE TABLE role_permissions (
          role TEXT NOT NULL,
          permission_key TEXT NOT NULL,
          PRIMARY KEY (role, permission_key)
        );
        CREATE TABLE session_state_entries (
          key TEXT NOT NULL PRIMARY KEY,
          value TEXT NOT NULL
        );
        CREATE TABLE staff_lockout_entries (
          staff_id TEXT NOT NULL PRIMARY KEY,
          failed_attempts INTEGER NOT NULL DEFAULT 0,
          locked_until INTEGER
        );
        PRAGMA user_version = 2;
      ''');

      final appDb = AppDatabase(NativeDatabase.opened(sqliteDb));
      await appDb.recordOfflineApproval(
        id: 'approval-2',
        approverStaffId: 'staff-2',
        requesterStaffId: 'staff-1',
        action: 'cash.open_drawer_no_sale',
        reference: 'drawer-ref',
        createdAt: DateTime.utc(2026, 1, 2),
        syncedAt: DateTime.utc(2026, 1, 3),
      );
      final approvals = await appDb.getOfflineApprovals();
      expect(approvals.length, 1);
      expect(approvals.first.reference, 'drawer-ref');
      expect(approvals.first.requesterStaffId, 'staff-1');
      expect(approvals.first.syncedAt?.toUtc(), DateTime.utc(2026, 1, 3));

      final userVer = sqliteDb
          .select('PRAGMA user_version;')
          .first
          .values
          .first;
      expect(userVer, 11);

      await appDb.close();
    });

    test('upgrades v3 to the current version: adds the catalog, outbox and sale tables and keeps M1 data', () async {
      final sqliteDb = sqlite3.openInMemory();
      sqliteDb.execute('''
        CREATE TABLE staff_entries (
          id TEXT NOT NULL PRIMARY KEY,
          display_name TEXT NOT NULL,
          role TEXT NOT NULL,
          offline_pin_verifier TEXT NOT NULL,
          pin_updated_at INTEGER NOT NULL
        );
        CREATE TABLE role_permissions (
          role TEXT NOT NULL,
          permission_key TEXT NOT NULL,
          PRIMARY KEY (role, permission_key)
        );
        CREATE TABLE session_state_entries (
          key TEXT NOT NULL PRIMARY KEY,
          value TEXT NOT NULL
        );
        CREATE TABLE staff_lockout_entries (
          staff_id TEXT NOT NULL PRIMARY KEY,
          failed_attempts INTEGER NOT NULL DEFAULT 0,
          locked_until INTEGER
        );
        CREATE TABLE offline_approval_entries (
          id TEXT NOT NULL PRIMARY KEY,
          approver_staff_id TEXT NOT NULL,
          requester_staff_id TEXT NOT NULL,
          action TEXT NOT NULL,
          reference TEXT,
          created_at INTEGER NOT NULL,
          synced_at INTEGER
        );
        INSERT INTO session_state_entries VALUES ('settings.appearance', '{}');
        PRAGMA user_version = 3;
      ''');

      final appDb = AppDatabase(NativeDatabase.opened(sqliteDb));
      expect(await appDb.getSessionValue('settings.appearance'), '{}');
      await appDb
          .into(appDb.catalogBranchPrices)
          .insert(
            CatalogBranchPricesCompanion.insert(
              variantId: 'v1',
              priceCents: 1300,
            ),
          );
      expect(await appDb.select(appDb.catalogBranchPrices).get(), hasLength(1));
      for (final table in [
        'catalog_tax_rates',
        'catalog_categories',
        'catalog_products',
        'catalog_variants',
        'sync_state_entries',
        'outbox_entries',
        'local_sales',
        'local_sale_lines',
        'local_sale_discounts',
        'local_held_tickets',
        'local_refunds',
        'local_shifts',
        'local_cash_movements',
        'local_cash_counts',
      ]) {
        expect(
          sqliteDb.select(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
            [table],
          ),
          hasLength(1),
          reason: table,
        );
      }
      expect(sqliteDb.select('PRAGMA user_version;').first.values.first, 11);
      await appDb.close();
    });

    const salesV7 = '''
      CREATE TABLE catalog_variants (
        id TEXT NOT NULL PRIMARY KEY,
        product_id TEXT NOT NULL,
        name TEXT NOT NULL,
        sku TEXT,
        barcode TEXT,
        price_cents INTEGER NOT NULL,
        sort_order INTEGER NOT NULL,
        is_active INTEGER NOT NULL
      );
      CREATE TABLE local_sales (
        id TEXT NOT NULL PRIMARY KEY,
        folio TEXT NOT NULL UNIQUE,
        folio_number INTEGER NOT NULL UNIQUE,
        cashier_staff_id TEXT NOT NULL,
        cashier_name TEXT NOT NULL,
        occurred_at INTEGER NOT NULL,
        gross_cents INTEGER NOT NULL,
        discount_cents INTEGER NOT NULL,
        total_cents INTEGER NOT NULL,
        tendered_cents INTEGER NOT NULL,
        change_cents INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'COMPLETED',
        refunded_cents INTEGER NOT NULL DEFAULT 0,
        voided_lines_json TEXT NOT NULL DEFAULT '[]'
      );
      INSERT INTO local_sales (id, folio, folio_number, cashier_staff_id,
        cashier_name, occurred_at, gross_cents, discount_cents, total_cents,
        tendered_cents, change_cents)
      VALUES ('s1', 'SUC1-01-000001', 1, 'c1', 'Ana', 0, 100, 0, 100, 100, 0);
    ''';

    test('upgrades v7 to the current version and keeps the sales and refunds already stored', () async {
      final sqliteDb = sqlite3.openInMemory();
      sqliteDb.execute('''
        $salesV7
        CREATE TABLE local_refunds (
          id TEXT NOT NULL PRIMARY KEY,
          sale_id TEXT NOT NULL,
          folio TEXT NOT NULL,
          kind TEXT NOT NULL,
          reason TEXT NOT NULL,
          note TEXT,
          staff_id TEXT NOT NULL,
          approver_staff_id TEXT,
          occurred_at INTEGER NOT NULL,
          total_cents INTEGER NOT NULL,
          lines_json TEXT NOT NULL
        );
        INSERT INTO local_refunds (id, sale_id, folio, kind, reason, staff_id,
          occurred_at, total_cents, lines_json)
        VALUES ('r1', 's1', 'SUC1-01-000001', 'REFUND', 'OTHER', 'c1', 0, 100, '[]');
        PRAGMA user_version = 7;
      ''');
      final appDb = AppDatabase(NativeDatabase.opened(sqliteDb));
      final sale = (await appDb.select(appDb.localSales).get()).single;
      expect(sale.folio, 'SUC1-01-000001');
      expect(sale.shiftId, isNull);
      final refund = (await appDb.select(appDb.localRefunds).get()).single;
      expect(refund.shiftId, isNull);
      expect(refund.ratesJson, '[]');
      expect(await appDb.select(appDb.localShifts).get(), isEmpty);
      await appDb.close();
    });

    test('upgrades v6 to the current version: refunds are new, sales gain the shift', () async {
      final sqliteDb = sqlite3.openInMemory();
      sqliteDb.execute('$salesV7 PRAGMA user_version = 6;');
      final appDb = AppDatabase(NativeDatabase.opened(sqliteDb));
      expect(
        (await appDb.select(appDb.localSales).get()).single.shiftId,
        isNull,
      );
      expect(await appDb.select(appDb.localRefunds).get(), isEmpty);
      await appDb.close();
    });
  });
}
