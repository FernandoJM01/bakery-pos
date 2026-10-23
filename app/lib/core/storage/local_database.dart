import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import 'secure_storage.dart';

part 'local_database.g.dart';

class StaffEntries extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get role => text()();
  TextColumn get offlinePinVerifier => text()();
  DateTimeColumn get pinUpdatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class RolePermissions extends Table {
  TextColumn get role => text()();
  TextColumn get permissionKey => text()();

  @override
  Set<Column> get primaryKey => {role, permissionKey};
}

class SessionStateEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class StaffLockoutEntries extends Table {
  TextColumn get staffId => text()();
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lockedUntil => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {staffId};
}

class OfflineApprovalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get approverStaffId => text()();
  // Who asked for the approval; brief 5.4 audits both actor and approver.
  TextColumn get requesterStaffId => text()();
  TextColumn get action => text()();
  TextColumn get reference => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    StaffEntries,
    RolePermissions,
    SessionStateEntries,
    StaffLockoutEntries,
    OfflineApprovalEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Pass [openEncryptedTillDatabase] in the app; tests pass an in-memory
  /// executor. There is deliberately no unencrypted default.
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(staffLockoutEntries);
      }
      if (from < 3) {
        await m.createTable(offlineApprovalEntries);
      }
    },
  );

  Future<void> replaceStaffBundle({
    required List<StaffEntriesCompanion> staff,
    required List<RolePermissionsCompanion> permissions,
  }) async {
    await transaction(() async {
      await delete(staffEntries).go();
      await delete(rolePermissions).go();
      await batch((b) {
        b.insertAll(staffEntries, staff);
        b.insertAll(rolePermissions, permissions);
      });
    });
  }

  Future<List<StaffEntry>> getAllStaff() => select(staffEntries).get();

  Future<StaffEntry?> getStaffById(String id) {
    return (select(
      staffEntries,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<List<String>> getPermissionsForRole(String role) async {
    final rows = await (select(
      rolePermissions,
    )..where((tbl) => tbl.role.equals(role))).get();
    return rows.map((r) => r.permissionKey).toList();
  }

  Future<List<StaffEntry>> getStaffWithPermission(String permission) async {
    final rolesWithPermission =
        await (select(rolePermissions)
              ..where((tbl) => tbl.permissionKey.equals(permission)))
            .map((row) => row.role)
            .get();
    if (rolesWithPermission.isEmpty) return [];
    return (select(
      staffEntries,
    )..where((tbl) => tbl.role.isIn(rolesWithPermission))).get();
  }

  Future<void> recordOfflineApproval({
    required String id,
    required String approverStaffId,
    required String requesterStaffId,
    required String action,
    String? reference,
    required DateTime createdAt,
  }) async {
    await into(offlineApprovalEntries).insert(
      OfflineApprovalEntriesCompanion(
        id: Value(id),
        approverStaffId: Value(approverStaffId),
        requesterStaffId: Value(requesterStaffId),
        action: Value(action),
        reference: Value(reference),
        createdAt: Value(createdAt),
      ),
    );
  }

  Future<List<OfflineApprovalEntry>> getOfflineApprovals() {
    return select(offlineApprovalEntries).get();
  }

  Future<void> setSessionValue(String key, String value) async {
    await into(sessionStateEntries).insertOnConflictUpdate(
      SessionStateEntriesCompanion(key: Value(key), value: Value(value)),
    );
  }

  Future<String?> getSessionValue(String key) async {
    final row = await (select(
      sessionStateEntries,
    )..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<StaffLockoutEntry?> getLockout(String staffId) {
    return (select(
      staffLockoutEntries,
    )..where((tbl) => tbl.staffId.equals(staffId))).getSingleOrNull();
  }

  Future<DateTime?> getActiveLockout(String staffId, DateTime now) async {
    final entry = await getLockout(staffId);
    if (entry == null || entry.lockedUntil == null) return null;
    if (entry.lockedUntil!.isAfter(now)) {
      return entry.lockedUntil;
    }
    // Lockout has expired; clear it
    await resetLockout(staffId);
    return null;
  }

  Future<DateTime?> recordFailedPinAttempt(String staffId, DateTime now) async {
    final existing = await getLockout(staffId);
    if (existing?.lockedUntil != null && existing!.lockedUntil!.isAfter(now)) {
      return existing.lockedUntil;
    }
    final attempts = (existing?.failedAttempts ?? 0) + 1;
    final lockedUntil = attempts >= 5
        ? now.add(const Duration(minutes: 5))
        : null;
    await into(staffLockoutEntries).insertOnConflictUpdate(
      StaffLockoutEntriesCompanion(
        staffId: Value(staffId),
        failedAttempts: Value(attempts),
        lockedUntil: Value(lockedUntil),
      ),
    );
    return lockedUntil;
  }

  Future<void> setLockoutUntil(String staffId, DateTime lockedUntil) async {
    final existing = await getLockout(staffId);
    await into(staffLockoutEntries).insertOnConflictUpdate(
      StaffLockoutEntriesCompanion(
        staffId: Value(staffId),
        failedAttempts: Value(existing?.failedAttempts ?? 0),
        lockedUntil: Value(lockedUntil),
      ),
    );
  }

  Future<void> resetLockout(String staffId) async {
    await (delete(
      staffLockoutEntries,
    )..where((tbl) => tbl.staffId.equals(staffId))).go();
  }

  Future<void> clearAll() async {
    await delete(staffEntries).go();
    await delete(rolePermissions).go();
    await delete(sessionStateEntries).go();
    await delete(staffLockoutEntries).go();
    await delete(offlineApprovalEntries).go();
  }

  static Future<void> deleteDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final base = p.join(dbFolder.path, _fileName);
    for (final path in [base, '$base-wal', '$base-shm', '$base-journal']) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}

const _fileName = 'bakery_pos_local.sqlite';

/// Keys the connection and refuses to continue unless SQLCipher is the
/// loaded engine: plain SQLite ignores `PRAGMA key`, which would silently
/// store the offline PIN verifiers unencrypted.
void applyEncryptionKey(Database rawDb, String hexKey) {
  if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(hexKey)) {
    throw ArgumentError('Database key must be 32 bytes as lowercase hex');
  }
  final cipher = rawDb.select('PRAGMA cipher_version;');
  if (cipher.isEmpty || '${cipher.first.values.first}'.isEmpty) {
    throw StateError(
      'SQLCipher is not available; refusing to open the database',
    );
  }
  rawDb.execute("PRAGMA key = \"x'$hexKey'\";");
}

LazyDatabase openEncryptedTillDatabase(Future<String> Function() getKey) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, _fileName));
    final key = await getKey();
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) => applyEncryptionKey(rawDb, key),
    );
  });
}

/// Till-only database provider, encrypted via SQLCipher using a key kept in
/// secure storage. Never import this file from the back office (web).
final tillDatabaseProvider = Provider<AppDatabase>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final db = AppDatabase(
    openEncryptedTillDatabase(secureStorage.getOrCreateDatabaseKey),
  );
  ref.onDispose(db.close);
  return db;
});
