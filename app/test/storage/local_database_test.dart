import 'dart:io';

import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => Directory.systemTemp.path,
        );
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('LocalDatabase', () {
    test('schemaVersion is 3', () {
      expect(db.schemaVersion, 3);
    });

    test(
      'tillDatabaseProvider provides AppDatabase instance and close on dispose',
      () async {
        final container = ProviderContainer(
          overrides: [
            tillDatabaseProvider.overrideWithValue(
              AppDatabase(NativeDatabase.memory()),
            ),
          ],
        );
        final database = container.read(tillDatabaseProvider);
        expect(database, isA<AppDatabase>());
        container.dispose();
      },
    );

    test('deleteDatabaseFile handles non-existent file cleanly', () async {
      await expectLater(AppDatabase.deleteDatabaseFile(), completes);
    });

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

    test('database file cannot be opened without encryption key', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final dbFile = File('${tempDir.path}/encrypted_test.sqlite');
      const encryptionKey =
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

      final encryptedDb = AppDatabase(
        NativeDatabase(
          dbFile,
          setup: (rawDb) => applyEncryptionKey(rawDb, encryptionKey),
        ),
      );
      await encryptedDb.setSessionValue('secret_key', 'secret_value');
      await encryptedDb.close();

      final unauthenticatedDb = AppDatabase(NativeDatabase(dbFile));

      expect(
        () async => await unauthenticatedDb.getSessionValue('secret_key'),
        throwsA(anything),
      );

      await unauthenticatedDb.close();
      tempDir.deleteSync(recursive: true);
    });

    test('applyEncryptionKey rejects keys that are not 32 bytes of hex', () {
      final db = AppDatabase(
        NativeDatabase.memory(
          setup: (rawDb) => applyEncryptionKey(rawDb, 'short-passphrase'),
        ),
      );
      expect(() => db.getSessionValue('x'), throwsA(isA<ArgumentError>()));
    });
  });
}
