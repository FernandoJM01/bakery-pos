import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('Database Migration v1 to v2', () {
    test(
      'upgrades v1 schema to v2 and creates staffLockoutEntries table',
      () async {
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

        // Attempting to query/record lockout triggers migration to v2
        final lockout = await appDb.recordFailedPinAttempt(
          'staff-1',
          DateTime.utc(2026, 1, 1),
        );
        expect(lockout, isNull);

        final entry = await appDb.getLockout('staff-1');
        expect(entry, isNotNull);
        expect(entry!.failedAttempts, 1);

        final userVerAfter = sqliteDb
            .select('PRAGMA user_version;')
            .first
            .values
            .first;
        expect(userVerAfter, 2);

        await appDb.close();
      },
    );
  });
}
