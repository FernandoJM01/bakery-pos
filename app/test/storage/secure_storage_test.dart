import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeFlutterSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.clear();
  }
}

void main() {
  group('SecureStorageService', () {
    late SecureStorageService service;
    late FakeFlutterSecureStorage fakeStorage;

    setUp(() {
      fakeStorage = FakeFlutterSecureStorage();
      service = SecureStorageService(fakeStorage);
    });

    test('saves, reads, and deletes device token', () async {
      expect(await service.getDeviceToken(), isNull);

      await service.saveDeviceToken('device-secret-token');
      expect(await service.getDeviceToken(), 'device-secret-token');

      await service.deleteDeviceToken();
      expect(await service.getDeviceToken(), isNull);
    });

    test('saves, reads, and deletes refresh token', () async {
      expect(await service.getRefreshToken(), isNull);

      await service.saveRefreshToken('refresh-token-opaque');
      expect(await service.getRefreshToken(), 'refresh-token-opaque');

      await service.deleteRefreshToken();
      expect(await service.getRefreshToken(), isNull);
    });

    test('clearAll removes all stored keys', () async {
      await service.saveDeviceToken('tok-1');
      await service.saveRefreshToken('tok-2');

      await service.clearAll();

      expect(await service.getDeviceToken(), isNull);
      expect(await service.getRefreshToken(), isNull);
    });
  });
}
