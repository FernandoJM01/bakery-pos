import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fake/fake_api_interceptor.dart';
import 'generated/rest_client.dart';

// By default in debug or tests, we can enable the fake API if needed
final useFakeApiProvider = Provider<bool>((ref) => kDebugMode);

final serverBaseUrlProvider = Provider<String>(
  (ref) => 'http://localhost:3000',
);

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

  final useFake = ref.watch(useFakeApiProvider);
  if (useFake) {
    dio.interceptors.add(FakeApiInterceptor());
  }

  return dio;
});

final restClientProvider = Provider<RestClient>((ref) {
  final dio = ref.watch(dioProvider);
  final baseUrl = ref.watch(serverBaseUrlProvider);
  return RestClient(dio, baseUrl: baseUrl);
});
