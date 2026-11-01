import 'dart:io';

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:uuid/uuid.dart';

import 'catalog_tables.dart';
import 'sale_tables.dart';
import 'secure_storage.dart';

export 'catalog_tables.dart';
export 'sale_tables.dart';

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
  DateTimeColumn get syncedAt => dateTime().nullable()();

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
    CatalogTaxRates,
    CatalogCategories,
    CatalogProducts,
    CatalogVariants,
    CatalogBranchPrices,
    SyncStateEntries,
    OutboxEntries,
    LocalSales,
    LocalSaleLines,
    LocalSaleDiscounts,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Pass [openEncryptedTillDatabase] in the app; tests pass an in-memory
  /// executor. There is deliberately no unencrypted default.
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 6;

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
      if (from < 4) {
        for (final table in <TableInfo>[
          catalogTaxRates,
          catalogCategories,
          catalogProducts,
          catalogVariants,
          catalogBranchPrices,
          syncStateEntries,
        ]) {
          await m.createTable(table);
        }
      }
      if (from < 5) {
        await m.createTable(outboxEntries);
      }
      if (from < 6) {
        await m.createTable(localSales);
        await m.createTable(localSaleLines);
        await m.createTable(localSaleDiscounts);
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

  /// Stores an offline approval and queues it for the server, together.
  Future<void> recordOfflineApproval({
    required String id,
    required String approverStaffId,
    required String requesterStaffId,
    required String action,
    String? reference,
    required DateTime createdAt,
    DateTime? syncedAt,
  }) => transaction(() async {
    await into(offlineApprovalEntries).insert(
      OfflineApprovalEntriesCompanion(
        id: Value(id),
        approverStaffId: Value(approverStaffId),
        requesterStaffId: Value(requesterStaffId),
        action: Value(action),
        reference: Value(reference),
        createdAt: Value(createdAt),
        syncedAt: Value(syncedAt),
      ),
    );
    await _queueOfflineEvent(
      id: id,
      action: 'auth.approval_granted',
      staffId: requesterStaffId,
      at: createdAt,
      extra: {
        'approverStaffId': approverStaffId,
        'approvalAction': action,
        'reference': reference,
      },
    );
  });

  /// A ticket with lines left without paying (M3 brief 4.1): queued as
  /// `sale.ticket_discarded` with its line count and amount. It takes no
  /// folio number.
  Future<void> recordTicketDiscarded({
    required String staffId,
    required int lineCount,
    required int amountCents,
    required DateTime at,
  }) => _queueOfflineEvent(
    action: 'sale.ticket_discarded',
    staffId: staffId,
    at: at,
    extra: {
      'ticket': {'lineCount': lineCount, 'amountCents': amountCents},
    },
  );

  /// Queues an `audit.offline_event` (M2 brief 4.3). The payload follows
  /// the contract's `OfflineAuditPayload` and never carries a PIN.
  Future<void> _queueOfflineEvent({
    String? id,
    required String action,
    required String staffId,
    required DateTime at,
    Map<String, Object?> extra = const {},
  }) async {
    await into(outboxEntries).insert(
      OutboxEntriesCompanion.insert(
        id: id ?? const Uuid().v7(),
        type: 'audit.offline_event',
        occurredAt: at,
        actorStaffId: Value(staffId),
        payload: jsonEncode({
          'action': action,
          'staffId': staffId,
          for (final e in extra.entries)
            if (e.value != null) e.key: e.value,
        }),
      ),
    );
  }

  /// An offline login that passed the PIN check: clears the counter and
  /// queues `auth.login_success`.
  Future<void> recordOfflineLoginSuccess(String staffId, DateTime now) =>
      transaction(() async {
        await resetLockout(staffId);
        await _queueOfflineEvent(
          action: 'auth.login_success',
          staffId: staffId,
          at: now,
        );
      });

  /// A wrong PIN checked offline (a login, or an approver's PIN): counts it
  /// and queues `auth.login_failure` for a login, plus `auth.locked` when it
  /// locks the account. Returns the lock time, as [recordFailedPinAttempt].
  Future<DateTime?> recordOfflinePinFailure(
    String staffId,
    DateTime now, {
    bool isLogin = true,
  }) => transaction(() async {
    final already = await getActiveLockout(staffId, now);
    final lockedUntil = await recordFailedPinAttempt(staffId, now);
    if (isLogin) {
      await _queueOfflineEvent(
        action: 'auth.login_failure',
        staffId: staffId,
        at: now,
      );
    }
    if (lockedUntil != null && already == null) {
      await _queueOfflineEvent(
        action: 'auth.locked',
        staffId: staffId,
        at: now,
      );
    }
    return lockedUntil;
  });

  /// Pending records, oldest first.
  Future<List<OutboxEntry>> pendingOutbox({int limit = 100}) =>
      (select(outboxEntries)
            ..where((o) => o.status.equals('PENDING'))
            ..orderBy([
              (o) => OrderingTerm(expression: o.occurredAt),
              (o) => OrderingTerm(expression: o.id),
            ])
            ..limit(limit))
          .get();

  /// Counts by status, for the sync indicator.
  Stream<({int pending, int quarantined})> watchOutboxCounts() {
    final count = outboxEntries.id.count();
    final query = selectOnly(outboxEntries)
      ..addColumns([outboxEntries.status, count])
      ..groupBy([outboxEntries.status]);
    return query.watch().map((rows) {
      var pending = 0;
      var quarantined = 0;
      for (final r in rows) {
        final n = r.read(count) ?? 0;
        if (r.read(outboxEntries.status) == 'QUARANTINED') {
          quarantined = n;
        } else {
          pending += n;
        }
      }
      return (pending: pending, quarantined: quarantined);
    });
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
    for (final table in <TableInfo>[
      catalogTaxRates,
      catalogCategories,
      catalogProducts,
      catalogVariants,
      catalogBranchPrices,
      syncStateEntries,
      outboxEntries,
      localSales,
      localSaleLines,
      localSaleDiscounts,
    ]) {
      await delete(table).go();
    }
  }

  static Future<void> deleteDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final base = p.join(dbFolder.path, _fileName);
    for (final path in [base, '$base-wal', '$base-shm', '$base-journal']) {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
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
