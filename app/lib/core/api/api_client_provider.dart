import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fake/fake_api_interceptor.dart';
import 'generated/rest_client.dart';

/// Compile-time switch for the in-memory fake API:
/// `flutter run --dart-define=USE_FAKE_API=true -t lib/main_till.dart`.
/// Being a const, builds without the flag tree-shake the fake (and its test
/// PINs and passwords) out entirely.
const bool useFakeApi = bool.fromEnvironment('USE_FAKE_API');

/// Default server URL for this build: `--dart-define=API_BASE_URL=https://...`.
const String defaultApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

final serverBaseUrlProvider = Provider<String>((ref) => defaultApiBaseUrl);

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(serverBaseUrlProvider);
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
