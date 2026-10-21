import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSecureStorageStore extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data[key];

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
    if (value != null) _data[key] = value;
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data.clear();
}

class _CustomUrlNotifier extends ServerBaseUrlNotifier {
  @override
  String build() => 'https://api.bakery.pos';
}

void main() {
  group('api_client_provider', () {
    test('serverBaseUrlProvider has default and allows updates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(serverBaseUrlProvider), defaultApiBaseUrl);

      container
          .read(serverBaseUrlProvider.notifier)
          .setBaseUrl('http://192.168.1.50:4000');
      expect(container.read(serverBaseUrlProvider), 'http://192.168.1.50:4000');
    });

    test('deviceRevocationHandlerProvider clears secure storage', () async {
      final fakeStore = _FakeSecureStorageStore();
      final secureStorage = SecureStorageService(fakeStore);
      await secureStorage.saveDeviceToken('tok-to-wipe');

      final container = ProviderContainer(
        overrides: [secureStorageProvider.overrideWithValue(secureStorage)],
      );
      addTearDown(container.dispose);

      final handler = container.read(deviceRevocationHandlerProvider);
      await handler();

      expect(await secureStorage.getDeviceToken(), isNull);
    });

    test('dioProvider and restClientProvider configure Dio correctly', () {
      final fakeStore = _FakeSecureStorageStore();
      final secureStorage = SecureStorageService(fakeStore);

      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secureStorage),
          serverBaseUrlProvider.overrideWith(_CustomUrlNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      expect(dio.options.baseUrl, 'https://api.bakery.pos');
      expect(dio.options.headers['Content-Type'], 'application/json');
      expect(dio.options.headers['Accept'], 'application/json');
      expect(dio.options.connectTimeout, const Duration(seconds: 10));

      final restClient = container.read(restClientProvider);
      expect(restClient, isNotNull);
    });

    test('serverBaseUrlProvider starts from the URL saved at enrollment', () {
      final container = ProviderContainer(
        overrides: [
          serverBaseUrlProvider.overrideWith(
            () => ServerBaseUrlNotifier('https://suc1.example.mx'),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(serverBaseUrlProvider), 'https://suc1.example.mx');
      expect(
        container.read(dioProvider).options.baseUrl,
        'https://suc1.example.mx',
      );
    });

    test('serverBaseUrlProvider falls back to the build default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(serverBaseUrlProvider), defaultApiBaseUrl);
    });
  });
}
