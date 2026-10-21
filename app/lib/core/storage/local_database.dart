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

@DriftDatabase(tables: [StaffEntries, RolePermissions, SessionStateEntries])
class AppDatabase extends _$AppDatabase {
  /// Pass [openEncryptedTillDatabase] in the app; tests pass an in-memory
  /// executor. There is deliberately no unencrypted default.
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

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

  Future<void> clearAll() async {
    await delete(staffEntries).go();
    await delete(rolePermissions).go();
    await delete(sessionStateEntries).go();
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
