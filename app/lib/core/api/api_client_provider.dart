import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../storage/secure_storage.dart';
import 'fake/fake_api_interceptor.dart';
import 'generated/rest_client.dart';
import 'till_device_interceptor.dart';

/// Compile-time switch for the in-memory fake API:
/// `flutter run --dart-define=USE_FAKE_API=true -t lib/main_till.dart`.
const bool useFakeApi = bool.fromEnvironment('USE_FAKE_API');

/// Default server URL for this build: `--dart-define=API_BASE_URL=https://...`.
const String defaultApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

final serverBaseUrlProvider = NotifierProvider<ServerBaseUrlNotifier, String>(
  ServerBaseUrlNotifier.new,
);

class ServerBaseUrlNotifier extends Notifier<String> {
  /// [savedUrl] is the URL stored at enrollment, loaded by main_till.dart so
  /// an enrolled till keeps talking to its server after a restart.
  ServerBaseUrlNotifier([this.savedUrl]);

  final String? savedUrl;

  @override
  String build() => savedUrl ?? defaultApiBaseUrl;

  void setBaseUrl(String url) {
    state = url;
  }
}

typedef DeviceRevocationHandler = Future<void> Function();

final deviceRevocationHandlerProvider = Provider<DeviceRevocationHandler>((
  ref,
) {
  return () async {
    final storage = ref.read(secureStorageProvider);
    await storage.clearAll();
  };
});

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(serverBaseUrlProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final revocationHandler = ref.watch(deviceRevocationHandlerProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    TillDeviceInterceptor(
      getDeviceToken: secureStorage.getDeviceToken,
      onRevoked: revocationHandler,
      onNavigateToEnrollment: () {
        rootNavigatorKey.currentContext?.go(
          '${AppRoutes.tillEnrollment}?revoked=true',
        );
      },
    ),
  );

  if (useFakeApi) {
    dio.interceptors.add(FakeApiInterceptor());
  }

  return dio;
});

final restClientProvider = Provider<RestClient>((ref) {
  final dio = ref.watch(dioProvider);
  final baseUrl = ref.watch(serverBaseUrlProvider);
  return RestClient(dio, baseUrl: baseUrl);
});
