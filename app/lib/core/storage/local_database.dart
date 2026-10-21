import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'bakery_pos_local.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
