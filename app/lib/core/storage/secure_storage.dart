import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _deviceTokenKey = 'bakery_pos_device_token';
  static const _refreshTokenKey = 'bakery_pos_refresh_token';

  Future<String?> getDeviceToken() async {
    return _storage.read(key: _deviceTokenKey);
  }

  Future<void> saveDeviceToken(String token) async {
    await _storage.write(key: _deviceTokenKey, value: token);
  }

  Future<void> deleteDeviceToken() async {
    await _storage.delete(key: _deviceTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  const storage = FlutterSecureStorage(aOptions: AndroidOptions());
  return SecureStorageService(storage);
});
