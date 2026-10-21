import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/models/pin_login_request.dart';
import '../../../core/api/generated/models/refresh_request.dart';
import '../../../core/api/generated/rest_client.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/offline_pin_verifier.dart';
import '../domain/till_auth_state.dart';

final tillAuthServiceProvider = Provider<TillAuthService>((ref) {
  final restClient = ref.watch(restClientProvider);
  final database = ref.watch(tillDatabaseProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final service = TillAuthService(
    restClient: restClient,
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
  TillSession? build() => null;

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
}

class TillAuthService {
  TillAuthService({
    required this.restClient,
    required this.database,
    required this.secureStorage,
    this.verifier = const OfflinePinVerifier(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final RestClient restClient;
  final AppDatabase database;
  final SecureStorageService secureStorage;
  final OfflinePinVerifier verifier;
  final DateTime Function() _clock;

  TillSession? _currentSession;
  Timer? _refreshTimer;

  TillSession? get currentSession => _currentSession;

  Future<TillSession> loginWithPin({
    required StaffEntry staff,
    required String pin,
  }) async {
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
      return session;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      String? code;
      if (data is Map<String, dynamic>) {
        code = data['code'] as String?;
      }

      if (status == 401 || code == 'AUTH_INVALID_PIN') {
        final lockedUntil = await database.recordFailedPinAttempt(
          staff.id,
          now,
        );
        if (lockedUntil != null) {
          throw TillAuthLockoutException(lockedUntil);
        }
        throw const TillAuthInvalidPinException();
      }

      if (status == 403 || code == 'AUTH_NOT_ALLOWED') {
        throw const TillAuthNotAllowedException();
      }

      if (status == 423 || code == 'AUTH_LOCKED') {
        DateTime? lockedUntil;
        if (data is Map<String, dynamic> && data['details'] is Map) {
          final details = data['details'] as Map;
          final timeStr = details['lockedUntil'] as String?;
          if (timeStr != null) {
            lockedUntil = DateTime.tryParse(timeStr);
          }
        }
        lockedUntil ??= now.add(const Duration(minutes: 5));
        await database.recordFailedPinAttempt(staff.id, now);
        throw TillAuthLockoutException(lockedUntil);
      }

      // Offline or network error: attempt offline Argon2id verification
      return _loginOffline(staff, pin, now);
    } catch (_) {
      return _loginOffline(staff, pin, now);
    }
  }

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
    return session;
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

  Future<void> silentRefresh() async {
    if (_currentSession == null || _currentSession!.isOffline) return;
    final token = await secureStorage.getRefreshToken();
    if (token == null) return;

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
    } catch (_) {
      // If refresh fails silently, next network request will handle 401
    }
  }

  Future<void> logout() async {
    _refreshTimer?.cancel();
    _currentSession = null;
    await secureStorage.deleteRefreshToken();
  }

  void dispose() {
    _refreshTimer?.cancel();
  }
}
