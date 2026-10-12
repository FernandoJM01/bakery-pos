import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/local_database_helper.dart';
import '../domain/user.dart';

abstract class AuthRepository {
  Future<User?> verifyPin({required String username, required String pin});
  Future<List<User>> getAvailableUsers();
  Future<void> cacheUsers(List<User> users);
}

class AuthRepositoryImpl implements AuthRepository {
  final LocalDatabaseHelper dbHelper;

  AuthRepositoryImpl({LocalDatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? LocalDatabaseHelper.instance;

  String hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  static const List<User> fallbackUsers = [
    User(
      id: 'b0000000-0000-0000-0000-000000000001',
      branchId: 'a0000000-0000-0000-0000-000000000001',
      username: 'cashier1',
      pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', // 1234
      fullName: 'Maria Gonzalez',
      role: UserRole.cashier,
      avatarAsset: 'assets/users/maria_gonzalez.jpg',
    ),
    User(
      id: 'b0000000-0000-0000-0000-000000000002',
      branchId: 'a0000000-0000-0000-0000-000000000001',
      username: 'baker1',
      pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', // 1234
      fullName: 'Marco Rossi',
      role: UserRole.localBaker,
      avatarAsset: 'assets/users/marco_rossi.jpg',
    ),
    User(
      id: 'b0000000-0000-0000-0000-000000000003',
      branchId: 'a0000000-0000-0000-0000-000000000001',
      username: 'manager1',
      pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', // 1234
      fullName: 'Elena Rostova',
      role: UserRole.branchManager,
      avatarAsset: 'assets/users/elena_rostova.jpg',
    ),
  ];

  @override
  Future<User?> verifyPin({required String username, required String pin}) async {
    final hashed = hashPin(pin);

    // 1. Direct in-memory check for instant offline authentication (0ms latency)
    for (final u in fallbackUsers) {
      if (u.username == username && u.pinHash == hashed) {
        return u;
      }
    }

    // 2. Fallback to cached SQLite DB with strict 500ms timeout for sync-added users
    try {
      final db = await dbHelper.database.timeout(const Duration(milliseconds: 500));
      final res = await db.query(
        'cached_users',
        where: 'username = ? AND pin_hash = ? AND is_active = 1',
        whereArgs: [username, hashed],
        limit: 1,
      ).timeout(const Duration(milliseconds: 500));

      if (res.isNotEmpty) {
        return User.fromMap(res.first);
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<List<User>> getAvailableUsers() async {
    try {
      final db = await dbHelper.database.timeout(const Duration(milliseconds: 500));
      final res = await db.query('cached_users', where: 'is_active = 1', orderBy: 'full_name ASC').timeout(const Duration(milliseconds: 500));
      if (res.isNotEmpty) {
        return res.map((m) => User.fromMap(m)).toList();
      }
    } catch (_) {}
    return fallbackUsers;
  }

  @override
  Future<void> cacheUsers(List<User> users) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (final u in users) {
      batch.insert('cached_users', u.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
