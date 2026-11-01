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
      expect(userVerAfter, 6);

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
      expect(userVer, 6);

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
      expect(sqliteDb.select('PRAGMA user_version;').first.values.first, 6);
      await appDb.close();
    });
  });
}
