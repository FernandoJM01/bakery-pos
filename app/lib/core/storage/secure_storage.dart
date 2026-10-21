import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _deviceTokenKey = 'bakery_pos_device_token';
  static const _refreshTokenKey = 'bakery_pos_refresh_token';
  static const _dbEncryptionKeyName = 'bakery_pos_db_key';
  static const _serverUrlKey = 'bakery_pos_server_url';
  static const _deviceDataKey = 'bakery_pos_device_data';
  static const _branchDataKey = 'bakery_pos_branch_data';

  Future<String> getOrCreateDatabaseKey() async {
    final existing = await _storage.read(key: _dbEncryptionKeyName);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _storage.write(key: _dbEncryptionKeyName, value: key);
    return key;
  }

  Future<String?> getDeviceToken() => _storage.read(key: _deviceTokenKey);

  Future<void> saveDeviceToken(String token) =>
      _storage.write(key: _deviceTokenKey, value: token);

  Future<void> deleteDeviceToken() => _storage.delete(key: _deviceTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<void> deleteRefreshToken() => _storage.delete(key: _refreshTokenKey);

  Future<String?> getServerUrl() => _storage.read(key: _serverUrlKey);

  Future<void> saveServerUrl(String url) =>
      _storage.write(key: _serverUrlKey, value: url);

  Future<void> saveEnrolledDevice({
    required String deviceToken,
    required String deviceJson,
    required String branchJson,
  }) async {
    await _storage.write(key: _deviceTokenKey, value: deviceToken);
    await _storage.write(key: _deviceDataKey, value: deviceJson);
    await _storage.write(key: _branchDataKey, value: branchJson);
  }

  Future<String?> getEnrolledDevice() => _storage.read(key: _deviceDataKey);

  Future<String?> getEnrolledBranch() => _storage.read(key: _branchDataKey);

  Future<void> clearAll() => _storage.deleteAll();
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  const storage = FlutterSecureStorage(aOptions: AndroidOptions());
  return SecureStorageService(storage);
});
