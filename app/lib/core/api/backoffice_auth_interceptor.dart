import 'package:dio/dio.dart';

/// Attaches the back office access token as `Authorization: Bearer <token>`
/// to authenticated requests.
///
/// On 401 with `AUTH_TOKEN_EXPIRED`, attempts a silent refresh and retries once.
class BackofficeAuthInterceptor extends Interceptor {
  BackofficeAuthInterceptor({
    required this.getAccessToken,
    required this.silentRefresh,
    this.dio,
  });

  final String? Function() getAccessToken;
  final Future<String?> Function() silentRefresh;
  final Dio? dio;

  /// Set on a request after its one refresh-and-retry, so a second 401
  /// (clock skew, a revoked session) is returned instead of looping.
  static const retriedKey = 'backofficeAuthRetried';

  static bool isPublicRoute(String path) {
    final clean = path.split('?').first;
    return clean.endsWith('/v1/auth/password-login') ||
        clean.endsWith('/v1/auth/refresh');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (isPublicRoute(options.path)) {
      return handler.next(options);
    }
    final token = getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    final code = data is Map ? data['code']?.toString() : null;

    if (status == 401 &&
        (code == 'AUTH_TOKEN_EXPIRED' || code == 'AUTH_REQUIRED') &&
        !isPublicRoute(err.requestOptions.path) &&
        err.requestOptions.extra[retriedKey] != true) {
      final newToken = await silentRefresh();
      if (newToken != null && dio != null) {
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';
        opts.extra[retriedKey] = true;
        try {
          final res = await dio!.fetch(opts);
          return handler.resolve(res);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      }
    }
    handler.next(err);
  }
}
