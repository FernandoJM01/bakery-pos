import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageKeys {
  static const deviceToken = 'bakery_pos_device_token';
  static const refreshToken = 'bakery_pos_refresh_token';
  static const dbEncryptionKey = 'bakery_pos_db_key';
  static const serverUrl = 'bakery_pos_server_url';
  static const deviceData = 'bakery_pos_device_data';
  static const branchData = 'bakery_pos_branch_data';
  static const branchName = 'bakery_pos_branch_name';
}

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<String> getOrCreateDatabaseKey() async {
    final existing = await _storage.read(
      key: SecureStorageKeys.dbEncryptionKey,
    );
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _storage.write(key: SecureStorageKeys.dbEncryptionKey, value: key);
    return key;
  }

  Future<String?> getDeviceToken() =>
      _storage.read(key: SecureStorageKeys.deviceToken);

  Future<void> saveDeviceToken(String token) =>
      _storage.write(key: SecureStorageKeys.deviceToken, value: token);

  Future<void> deleteDeviceToken() =>
      _storage.delete(key: SecureStorageKeys.deviceToken);

  Future<String?> getRefreshToken() =>
      _storage.read(key: SecureStorageKeys.refreshToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: SecureStorageKeys.refreshToken, value: token);

  Future<void> deleteRefreshToken() =>
      _storage.delete(key: SecureStorageKeys.refreshToken);

  Future<String?> getServerUrl() =>
      _storage.read(key: SecureStorageKeys.serverUrl);

  Future<void> saveServerUrl(String url) =>
      _storage.write(key: SecureStorageKeys.serverUrl, value: url);

  Future<void> saveEnrolledDevice({
    required String deviceToken,
    required String deviceJson,
    required String branchJson,
    String? branchName,
  }) async {
    await _storage.write(
      key: SecureStorageKeys.deviceToken,
      value: deviceToken,
    );
    await _storage.write(key: SecureStorageKeys.deviceData, value: deviceJson);
    await _storage.write(key: SecureStorageKeys.branchData, value: branchJson);
    String? resolvedName = branchName;
    if (resolvedName == null) {
      try {
        final map = jsonDecode(branchJson) as Map<String, dynamic>;
        resolvedName = map['name'] as String?;
      } catch (_) {}
    }
    if (resolvedName != null) {
      await _storage.write(
        key: SecureStorageKeys.branchName,
        value: resolvedName,
      );
    }
  }

  Future<String?> getEnrolledDevice() =>
      _storage.read(key: SecureStorageKeys.deviceData);

  Future<String?> getEnrolledBranch() =>
      _storage.read(key: SecureStorageKeys.branchData);

  Future<String?> getEnrolledBranchName() async {
    final direct = await _storage.read(key: SecureStorageKeys.branchName);
    if (direct != null && direct.isNotEmpty) return direct;
    final branchJson = await getEnrolledBranch();
    if (branchJson == null || branchJson.isEmpty) return null;
    try {
      final map = jsonDecode(branchJson) as Map<String, dynamic>;
      return map['name'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBranchName(String name) =>
      _storage.write(key: SecureStorageKeys.branchName, value: name);

  Future<void> clearAll() => _storage.deleteAll();
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  const storage = FlutterSecureStorage(aOptions: AndroidOptions());
  return SecureStorageService(storage);
});

final enrolledBranchNameProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return storage.getEnrolledBranchName();
});
