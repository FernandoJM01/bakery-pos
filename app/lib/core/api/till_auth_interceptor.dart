import 'package:dio/dio.dart';

import '../../features/auth/domain/till_auth_exceptions.dart';

/// Interceptor that attaches the staff access token as `Authorization: Bearer <token>`
/// to authenticated till requests.
///
/// If an authenticated request is attempted during an offline session, it is
/// rejected immediately without hitting the network.
/// On `401 AUTH_TOKEN_EXPIRED`, it silently refreshes the token once and retries.
class TillAuthInterceptor extends Interceptor {
  TillAuthInterceptor({
    required this.dio,
    required this.getAccessToken,
    required this.isSessionOffline,
    this.refreshAccessToken,
  });

  final Dio dio;
  final String? Function() getAccessToken;
  final bool Function() isSessionOffline;
  final Future<String?> Function()? refreshAccessToken;

  static bool isPublicOrDeviceRoute(String path) {
    final cleanPath = path.split('?').first;
    return cleanPath.endsWith('/v1/devices/activate') ||
        cleanPath.endsWith('/v1/devices/me/staff') ||
        cleanPath.endsWith('/v1/auth/pin-login') ||
        cleanPath.endsWith('/v1/auth/password-login') ||
        cleanPath.endsWith('/v1/auth/refresh');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (isPublicOrDeviceRoute(options.path)) {
      return handler.next(options);
    }

    if (isSessionOffline()) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: const TillAuthGenericException(
            'Online re-authentication required',
          ),
        ),
      );
    }

    final token = getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      return handler.next(options);
    }

    return handler.reject(
      DioException(
        requestOptions: options,
        error: const TillAuthGenericException('Authentication required'),
      ),
    );
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    String? code;
    if (data is Map) {
      code = data['code']?.toString();
    }

    if (status == 401 &&
        code == 'AUTH_TOKEN_EXPIRED' &&
        err.requestOptions.extra['auth_retry'] != true &&
        refreshAccessToken != null) {
      err.requestOptions.extra['auth_retry'] = true;
      try {
        final newToken = await refreshAccessToken!();
        if (newToken != null && newToken.isNotEmpty) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        }
      } catch (_) {
        // Refresh failed, fall through to default error handling
      }
    }

    handler.next(err);
  }
}
