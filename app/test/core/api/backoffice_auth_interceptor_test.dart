import 'package:bakery_pos/core/api/backoffice_auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every request with 401 AUTH_TOKEN_EXPIRED, like a server whose
/// clock is ahead of the token's expiry.
class _AlwaysExpired extends Interceptor {
  int requests = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests++;
    handler.reject(
      DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: 401,
          data: {'code': 'AUTH_TOKEN_EXPIRED', 'message': 'expired'},
        ),
      ),
      true,
    );
  }
}

void main() {
  test('refreshes and retries a 401 once, then gives up', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    var refreshes = 0;
    final server = _AlwaysExpired();
    dio.interceptors
      ..add(
        BackofficeAuthInterceptor(
          dio: dio,
          getAccessToken: () => 'token',
          silentRefresh: () async {
            refreshes++;
            return 'token-$refreshes';
          },
        ),
      )
      ..add(server);

    await expectLater(
      dio.get<dynamic>('/v1/me'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
    expect(refreshes, 1);
    expect(server.requests, 2);
  });
}
