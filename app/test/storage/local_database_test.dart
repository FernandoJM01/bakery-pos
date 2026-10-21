import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('LocalDatabase', () {
    test('schemaVersion is 1', () {
      expect(db.schemaVersion, 1);
    });

    test(
      'databaseProvider provides AppDatabase instance and closes on dispose',
      () async {
        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(
              AppDatabase(NativeDatabase.memory()),
            ),
          ],
        );
        final database = container.read(databaseProvider);
        expect(database, isA<AppDatabase>());
        container.dispose();
      },
    );

    test('saves and retrieves staff bundle and permissions', () async {
      await db.replaceStaffBundle(
        staff: [
          StaffEntriesCompanion.insert(
            id: 'staff-1',
            displayName: 'Ana',
            role: 'CASHIER',
            offlinePinVerifier: 'verifier-hash-1',
            pinUpdatedAt: DateTime.now(),
          ),
          StaffEntriesCompanion.insert(
            id: 'staff-2',
            displayName: 'Carlos',
            role: 'BRANCH_MANAGER',
            offlinePinVerifier: 'verifier-hash-2',
            pinUpdatedAt: DateTime.now(),
          ),
        ],
        permissions: [
          RolePermissionsCompanion.insert(
            role: 'CASHIER',
            permissionKey: 'sale.create',
          ),
          RolePermissionsCompanion.insert(
            role: 'BRANCH_MANAGER',
            permissionKey: 'sale.refund',
          ),
        ],
      );

      final staffList = await db.getAllStaff();
      expect(staffList.length, 2);

      final ana = await db.getStaffById('staff-1');
      expect(ana?.displayName, 'Ana');
      expect(ana?.role, 'CASHIER');

      final unknown = await db.getStaffById('non-existent');
      expect(unknown, isNull);

      final cashierPermissions = await db.getPermissionsForRole('CASHIER');
      expect(cashierPermissions, ['sale.create']);
    });

    test('saves and retrieves session state entries', () async {
      await db.setSessionValue('device_status', 'ACTIVE');
      final value = await db.getSessionValue('device_status');
      expect(value, 'ACTIVE');

      await db.setSessionValue('device_status', 'REVOKED');
      final updated = await db.getSessionValue('device_status');
      expect(updated, 'REVOKED');

      await db.clearAll();
      final emptyValue = await db.getSessionValue('device_status');
      expect(emptyValue, isNull);
    });
  });
}
