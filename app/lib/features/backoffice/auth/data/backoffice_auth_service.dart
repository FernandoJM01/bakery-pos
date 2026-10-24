import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client_provider.dart';
import '../../../../core/api/backoffice_auth_interceptor.dart';
import '../../../../core/api/generated/models/me.dart';
import '../../../../core/api/generated/models/password_login_request.dart';
import '../../../../core/api/generated/models/refresh_request.dart';
import '../../../../core/api/generated/models/staff.dart';
import '../../../../core/api/generated/models/token_pair.dart';
import '../../../../core/api/generated/rest_client.dart';
import '../domain/backoffice_auth_exceptions.dart';

class BackofficeSession {
  const BackofficeSession({
    required this.accessToken,
    required this.refreshToken,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
    required this.me,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;
  final Me me;

  Staff get staff => me.staff;
  List<String> get permissions => me.permissions
      .map((p) => p.json ?? '')
      .where((s) => s.isNotEmpty)
      .toList();
  bool hasPermission(String permission) => permissions.contains(permission);
}

final backofficeAuthServiceProvider = Provider<BackofficeAuthService>((ref) {
  final dio = ref.watch(dioProvider);
  final restClient = ref.watch(restClientProvider);
  return BackofficeAuthService(restClient: restClient, dio: dio);
});

class BackofficeAuthService extends ChangeNotifier {
  BackofficeAuthService({
    required this.restClient,
    this.dio,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    if (dio != null) {
      _authInterceptor = BackofficeAuthInterceptor(
        dio: dio,
        getAccessToken: () => _currentSession?.accessToken,
        silentRefresh: silentRefresh,
        onSessionExpired: clearLocalSession,
      );
      dio!.interceptors.insert(0, _authInterceptor!);
    }
  }

  final RestClient restClient;
  final Dio? dio;
  final DateTime Function() _clock;

  BackofficeAuthInterceptor? _authInterceptor;
  BackofficeSession? _currentSession;
  Timer? _refreshTimer;
  Completer<String?>? _refreshCompleter;

  BackofficeSession? get currentSession => _currentSession;
  bool get isAuthenticated => _currentSession != null;

  Future<BackofficeSession> login(String email, String password) async {
    try {
      final response = await restClient.auth.passwordLogin(
        body: PasswordLoginRequest(email: email.trim(), password: password),
      );

      final session = BackofficeSession(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        accessTokenExpiresAt: response.accessTokenExpiresAt,
        refreshTokenExpiresAt: response.refreshTokenExpiresAt,
        me: response.me,
      );

      _currentSession = session;
      _scheduleSilentRefresh(session.accessTokenExpiresAt);
      notifyListeners();
      return session;
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code']?.toString() : null;

      if (code == 'AUTH_INVALID_CREDENTIALS') {
        throw const BackofficeAuthInvalidCredentialsException();
      }

      if (code == 'AUTH_LOCKED') {
        DateTime? lockedUntil;
        if (data is Map && data['details'] is Map) {
          final untilStr = (data['details'] as Map)['lockedUntil']?.toString();
          if (untilStr != null) {
            lockedUntil = DateTime.tryParse(untilStr);
          }
        }
        throw BackofficeAuthLockedException(lockedUntil: lockedUntil);
      }

      final msg = data is Map ? data['message']?.toString() : null;
      throw BackofficeAuthGenericException(msg ?? 'Error de autenticación');
    }
  }

  void cancelSilentRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _scheduleSilentRefresh(DateTime? expiresAt) {
    _refreshTimer?.cancel();
    if (expiresAt == null) return;

    final now = _clock();
    final diff = expiresAt.difference(now) - const Duration(minutes: 1);
    final delay = diff > Duration.zero ? diff : const Duration(seconds: 10);

    _refreshTimer = Timer(delay, () async {
      await silentRefresh();
    });
  }

  Future<String?> silentRefresh() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    if (_currentSession == null) return null;

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final TokenPair pair = await restClient.auth.refreshToken(
        body: RefreshRequest(refreshToken: _currentSession!.refreshToken),
      );

      _currentSession = BackofficeSession(
        accessToken: pair.accessToken,
        refreshToken: pair.refreshToken,
        accessTokenExpiresAt: pair.accessTokenExpiresAt,
        refreshTokenExpiresAt: pair.refreshTokenExpiresAt,
        me: _currentSession!.me,
      );

      _scheduleSilentRefresh(pair.accessTokenExpiresAt);
      notifyListeners();
      completer.complete(pair.accessToken);
      return pair.accessToken;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        clearLocalSession();
      }
      completer.complete(null);
      return null;
    } catch (_) {
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  void clearLocalSession() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _currentSession = null;
    notifyListeners();
  }

  Future<void> logout() async {
    _refreshTimer?.cancel();
    _refreshTimer = null;

    try {
      await restClient.auth.logout();
    } catch (_) {
      // Swallowed on logout
    } finally {
      _currentSession = null;
      notifyListeners();
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _refreshTimer?.cancel();
    if (dio != null && _authInterceptor != null) {
      dio!.interceptors.remove(_authInterceptor);
    }
    super.dispose();
  }
}
