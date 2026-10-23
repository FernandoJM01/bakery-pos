import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/models/pin_login_request.dart';
import '../../../core/api/generated/models/refresh_request.dart';
import '../../../core/api/generated/rest_client.dart';
import '../../../core/api/till_auth_interceptor.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/offline_pin_verifier.dart';
import '../domain/till_auth_state.dart';

final tillAuthServiceProvider = Provider<TillAuthService>((ref) {
  final dio = ref.watch(dioProvider);
  final restClient = ref.watch(restClientProvider);
  final database = ref.watch(tillDatabaseProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final service = TillAuthService(
    restClient: restClient,
    dio: dio,
    database: database,
    secureStorage: secureStorage,
    verifier: const OfflinePinVerifier(),
  );
  ref.onDispose(service.dispose);
  return service;
});

final tillSessionProvider = NotifierProvider<TillSessionNotifier, TillSession?>(
  TillSessionNotifier.new,
);

class TillSessionNotifier extends Notifier<TillSession?> {
  @override
  TillSession? build() {
    final service = ref.watch(tillAuthServiceProvider);
    service.addListener(_onServiceChanged);
    ref.onDispose(() => service.removeListener(_onServiceChanged));
    return service.currentSession;
  }

  void _onServiceChanged() {
    state = ref.read(tillAuthServiceProvider).currentSession;
  }

  Future<TillSession> login({
    required StaffEntry staff,
    required String pin,
  }) async {
    final service = ref.read(tillAuthServiceProvider);
    final session = await service.loginWithPin(staff: staff, pin: pin);
    state = session;
    return session;
  }

  Future<void> logout() async {
    final service = ref.read(tillAuthServiceProvider);
    await service.logout();
    state = null;
  }

  Future<TillSession> reauthenticateOnline(String pin) async {
    final service = ref.read(tillAuthServiceProvider);
    final session = await service.reauthenticateOnline(pin);
    state = session;
    return session;
  }

  Future<List<String>> refreshPermissions() async {
    final service = ref.read(tillAuthServiceProvider);
    final perms = await service.refreshPermissions();
    state = service.currentSession;
    return perms;
  }
}

class TillAuthService extends ChangeNotifier {
  TillAuthService({
    required this.restClient,
    this.dio,
    required this.database,
    required this.secureStorage,
    this.verifier = const OfflinePinVerifier(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    if (dio != null) {
      _authInterceptor = TillAuthInterceptor(
        dio: dio!,
        getAccessToken: () => _currentSession?.accessToken,
        isSessionOffline: () => _currentSession?.isOffline ?? false,
        refreshAccessToken: silentRefresh,
      );
      dio!.interceptors.insert(0, _authInterceptor!);
    }
  }

  final RestClient restClient;
  final Dio? dio;
  final AppDatabase database;
  final SecureStorageService secureStorage;
  final OfflinePinVerifier verifier;
  final DateTime Function() _clock;

  TillAuthInterceptor? _authInterceptor;
  TillSession? _currentSession;
  Timer? _refreshTimer;
  Completer<String?>? _refreshCompleter;

  TillSession? get currentSession => _currentSession;

  Future<TillSession> loginWithPin({
    required StaffEntry staff,
    required String pin,
  }) async {
    // If a different user is logging in, log out the previous user first
    if (_currentSession != null && _currentSession!.staff.id != staff.id) {
      await logout();
    }

    final now = _clock();

    // Check active local lockout
    final activeLockout = await database.getActiveLockout(staff.id, now);
    if (activeLockout != null) {
      throw TillAuthLockoutException(activeLockout);
    }

    try {
      final response = await restClient.auth.pinLogin(
        body: PinLoginRequest(staffId: staff.id, pin: pin),
      );

      await database.resetLockout(staff.id);
      await secureStorage.saveRefreshToken(response.refreshToken);

      final permissions = response.me.permissions
          .map((p) => p.json ?? p.name)
          .toList();

      final session = TillSession(
        staff: staff,
        permissions: permissions,
        isOffline: false,
        accessToken: response.accessToken,
        accessTokenExpiresAt: response.accessTokenExpiresAt,
      );

      _currentSession = session;
      _scheduleSilentRefresh(response.accessTokenExpiresAt);
      notifyListeners();
      return session;
    } on DioException catch (e) {
      // Offline login only when the server cannot be reached (brief 5.2:
      // "no connection or a timeout"). A server that answers, even with an
      // error, never unlocks the offline path.
      if (_isUnreachable(e)) {
        return _loginOffline(staff, pin, now);
      }

      final data = e.response?.data;
      final code = data is Map ? data['code']?.toString() : null;
      switch (code) {
        case 'DEVICE_REVOKED':
        case 'DEVICE_UNKNOWN':
          // The till interceptor handles revocation; rethrow without touching local database
          rethrow;
        case 'AUTH_INVALID_PIN':
          final lockedUntil = await database.recordFailedPinAttempt(
            staff.id,
            now,
          );
          if (lockedUntil != null) {
            throw TillAuthLockoutException(lockedUntil);
          }
          throw const TillAuthInvalidPinException();
        case 'AUTH_NOT_ALLOWED':
          throw const TillAuthNotAllowedException();
        case 'AUTH_LOCKED':
          DateTime? lockedUntil;
          if (data is Map && data['details'] is Map) {
            final timeStr = (data['details'] as Map)['lockedUntil'];
            if (timeStr is String) lockedUntil = DateTime.tryParse(timeStr);
          }
          lockedUntil ??= now.add(const Duration(minutes: 5));
          await database.setLockoutUntil(staff.id, lockedUntil);
          throw TillAuthLockoutException(lockedUntil);
        default:
          throw TillAuthGenericException(
            (data is Map && data['message'] is String)
                ? data['message'] as String
                : (code ?? e.message ?? 'HTTP ${e.response?.statusCode}'),
          );
      }
    }
  }

  static const _unreachableTypes = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  };

  /// No HTTP response at all: timeout or connection failure. Certificate
  /// errors are deliberately excluded.
  static bool _isUnreachable(DioException e) =>
      e.response == null &&
      (_unreachableTypes.contains(e.type) ||
          (e.type == DioExceptionType.unknown && e.error is SocketException));

  Future<TillSession> _loginOffline(
    StaffEntry staff,
    String pin,
    DateTime now,
  ) async {
    final isValid = await verifier.verify(pin, staff.offlinePinVerifier);
    if (!isValid) {
      final lockedUntil = await database.recordFailedPinAttempt(staff.id, now);
      if (lockedUntil != null) {
        throw TillAuthLockoutException(lockedUntil);
      }
      throw const TillAuthInvalidPinException();
    }

    await database.resetLockout(staff.id);
    final permissions = await database.getPermissionsForRole(staff.role);
    final session = TillSession(
      staff: staff,
      permissions: permissions,
      isOffline: true,
    );
    _currentSession = session;
    notifyListeners();
    return session;
  }

  Future<List<String>> refreshPermissions() async {
    if (_currentSession == null) return [];
    if (!_currentSession!.isOffline && _currentSession!.accessToken != null) {
      try {
        final me = await restClient.auth.getMe();
        final permissions = me.permissions
            .map((p) => p.json ?? p.name)
            .toList();
        _currentSession = _currentSession!.copyWith(permissions: permissions);
        notifyListeners();
        return permissions;
      } on DioException catch (e) {
        if (!_isUnreachable(e)) {
          rethrow;
        }
      }
    }
    final permissions = await database.getPermissionsForRole(
      _currentSession!.staff.role,
    );
    _currentSession = _currentSession!.copyWith(permissions: permissions);
    notifyListeners();
    return permissions;
  }

  void pauseForLock() {
    _refreshTimer?.cancel();
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(clearAccessToken: true);
      notifyListeners();
    }
  }

  void clearLocalSession() {
    _refreshTimer?.cancel();
    _currentSession = null;
    notifyListeners();
  }

  void _scheduleSilentRefresh(DateTime expiresAt) {
    _refreshTimer?.cancel();
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
    if (_currentSession == null || _currentSession!.isOffline) return null;
    final token = await secureStorage.getRefreshToken();
    if (token == null) {
      await logout();
      return null;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final res = await restClient.auth.refreshToken(
        body: RefreshRequest(refreshToken: token),
      );
      await secureStorage.saveRefreshToken(res.refreshToken);
      _currentSession = TillSession(
        staff: _currentSession!.staff,
        permissions: _currentSession!.permissions,
        isOffline: false,
        accessToken: res.accessToken,
        accessTokenExpiresAt: res.accessTokenExpiresAt,
      );
      _scheduleSilentRefresh(res.accessTokenExpiresAt);
      notifyListeners();
      completer.complete(res.accessToken);
      return res.accessToken;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout();
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

  Future<TillSession> reauthenticateOnline(String pin) async {
    if (_currentSession == null) {
      throw const TillAuthGenericException('No active session');
    }
    final previousSession = _currentSession!;
    final session = await loginWithPin(staff: previousSession.staff, pin: pin);
    if (session.isOffline) {
      _currentSession = previousSession;
      notifyListeners();
      throw const TillAuthGenericException('Still offline');
    }
    return session;
  }

  Future<void> logout() async {
    _refreshTimer?.cancel();
    if (_currentSession != null && !_currentSession!.isOffline) {
      try {
        if (_currentSession!.accessToken == null) {
          await silentRefresh();
        }
        await restClient.auth.logout();
      } catch (_) {}
    }
    _refreshTimer?.cancel();
    _currentSession = null;
    await secureStorage.deleteRefreshToken();
    notifyListeners();
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _refreshTimer?.cancel();
    if (_authInterceptor != null && dio != null) {
      dio!.interceptors.remove(_authInterceptor);
    }
    super.dispose();
  }
}
