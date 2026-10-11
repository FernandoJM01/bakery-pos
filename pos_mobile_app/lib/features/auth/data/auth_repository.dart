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

  @override
  Future<User?> verifyPin({required String username, required String pin}) async {
    final db = await dbHelper.database;
    final hashed = hashPin(pin);

    final res = await db.query(
      'cached_users',
      where: 'username = ? AND pin_hash = ? AND is_active = 1',
      whereArgs: [username, hashed],
      limit: 1,
    );

    if (res.isEmpty) return null;
    return User.fromMap(res.first);
  }

  @override
  Future<List<User>> getAvailableUsers() async {
    final db = await dbHelper.database;
    final res = await db.query('cached_users', where: 'is_active = 1', orderBy: 'full_name ASC');
    return res.map((m) => User.fromMap(m)).toList();
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
