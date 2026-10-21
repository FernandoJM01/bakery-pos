import 'package:dio/dio.dart';

/// Interceptor applied to till HTTP requests.
///
/// Sends `X-Device-Token` on every request if present.
/// On 401 with `DEVICE_REVOKED` or `DEVICE_UNKNOWN`, it wipes local storage
/// and invokes the navigation callback to return to enrollment.
class TillDeviceInterceptor extends Interceptor {
  TillDeviceInterceptor({
    required this.getDeviceToken,
    required this.onRevoked,
    this.onNavigateToEnrollment,
  });

  final Future<String?> Function() getDeviceToken;
  final Future<void> Function() onRevoked;
  final void Function()? onNavigateToEnrollment;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.headers.containsKey('X-Device-Token')) {
      final token = await getDeviceToken();
      if (token != null && token.isNotEmpty) {
        options.headers['X-Device-Token'] = token;
      }
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
    if (status == 401) {
      String? code;
      if (data is Map) {
        code = data['code']?.toString();
      }
      if (code == 'DEVICE_REVOKED' || code == 'DEVICE_UNKNOWN') {
        await onRevoked();
        onNavigateToEnrollment?.call();
      }
    }
    handler.next(err);
  }
}
