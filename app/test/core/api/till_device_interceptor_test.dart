import 'package:bakery_pos/core/api/till_device_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockStatusAdapter implements HttpClientAdapter {
  _MockStatusAdapter(this.statusCode, this.responseBody);

  final int statusCode;
  final String responseBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      responseBody,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  group('TillDeviceInterceptor', () {
    test('sends X-Device-Token header when device token exists', () async {
      final dio = Dio();
      dio.interceptors.add(
        TillDeviceInterceptor(
          getDeviceToken: () async => 'test-device-token-123',
          onRevoked: () async {},
        ),
      );
      dio.httpClientAdapter = _MockStatusAdapter(200, '{"status":"ok"}');

      final response = await dio.get('https://example.com/test');
      expect(response.statusCode, 200);
      expect(
        response.requestOptions.headers['X-Device-Token'],
        'test-device-token-123',
      );
    });

    test(
      'does not send X-Device-Token header when token is null or empty',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          TillDeviceInterceptor(
            getDeviceToken: () async => null,
            onRevoked: () async {},
          ),
        );
        dio.httpClientAdapter = _MockStatusAdapter(200, '{"status":"ok"}');

        final response = await dio.get('https://example.com/test');
        expect(response.statusCode, 200);
        expect(
          response.requestOptions.headers.containsKey('X-Device-Token'),
          isFalse,
        );
      },
    );

    test('wipes data and triggers redirect on 401 DEVICE_REVOKED', () async {
      var wiped = false;
      var redirected = false;

      final dio = Dio();
      dio.interceptors.add(
        TillDeviceInterceptor(
          getDeviceToken: () async => 'revoked-token',
          onRevoked: () async {
            wiped = true;
          },
          onNavigateToEnrollment: () {
            redirected = true;
          },
        ),
      );
      dio.httpClientAdapter = _MockStatusAdapter(
        401,
        '{"code":"DEVICE_REVOKED","message":"Device token has been revoked"}',
      );

      try {
        await dio.get('https://example.com/protected');
        fail('Should throw DioException');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 401);
      }

      expect(wiped, isTrue);
      expect(redirected, isTrue);
    });

    test('wipes data and triggers redirect on 401 DEVICE_UNKNOWN', () async {
      var wiped = false;
      var redirected = false;

      final dio = Dio();
      dio.interceptors.add(
        TillDeviceInterceptor(
          getDeviceToken: () async => 'unknown-token',
          onRevoked: () async {
            wiped = true;
          },
          onNavigateToEnrollment: () {
            redirected = true;
          },
        ),
      );
      dio.httpClientAdapter = _MockStatusAdapter(
        401,
        '{"code":"DEVICE_UNKNOWN","message":"Device token is unknown"}',
      );

      try {
        await dio.get('https://example.com/protected');
        fail('Should throw DioException');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 401);
      }

      expect(wiped, isTrue);
      expect(redirected, isTrue);
    });

    test('does not wipe or redirect on unrelated 401 error', () async {
      var wiped = false;
      var redirected = false;

      final dio = Dio();
      dio.interceptors.add(
        TillDeviceInterceptor(
          getDeviceToken: () async => 'valid-device-token',
          onRevoked: () async {
            wiped = true;
          },
          onNavigateToEnrollment: () {
            redirected = true;
          },
        ),
      );
      dio.httpClientAdapter = _MockStatusAdapter(
        401,
        '{"code":"AUTH_INVALID_PIN","message":"Invalid staff PIN"}',
      );

      try {
        await dio.get('https://example.com/protected');
        fail('Should throw DioException');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 401);
      }

      expect(wiped, isFalse);
      expect(redirected, isFalse);
    });
  });
}
