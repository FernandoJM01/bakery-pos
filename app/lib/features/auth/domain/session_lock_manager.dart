import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_database.dart';
import '../data/till_auth_service.dart';

final sessionLockManagerProvider = Provider<SessionLockManager>((ref) {
  final authService = ref.watch(tillAuthServiceProvider);
  final manager = SessionLockManager(authService: authService);
  ref.onDispose(manager.dispose);
  return manager;
});

class LockedUserState {
  LockedUserState({
    required this.staffId,
    required this.route,
    required this.lockedAt,
    Map<String, dynamic>? state,
  }) : state = state != null ? Map.from(state) : {};

  final String staffId;
  final String route;
  final DateTime lockedAt;
  final Map<String, dynamic> state;
}

class SessionLockManager extends ChangeNotifier {
  SessionLockManager({
    required this.authService,
    this.inactivityTimeout = const Duration(minutes: 2),
    this.stateHoldTimeout = const Duration(minutes: 30),
    DateTime Function()? clock,
    this.onNavigateToLogin,
  }) : _clock = clock ?? DateTime.now {
    _lastActivity = _clock();
    _startTimer();
  }

  final TillAuthService authService;
  final Duration inactivityTimeout;
  final Duration stateHoldTimeout;
  final DateTime Function() _clock;
  void Function()? onNavigateToLogin;

  /// Reads the current location (set by main_till.dart from the router), so a
  /// lock fired by the idle timer still remembers which screen to restore.
  String? Function()? readCurrentRoute;

  /// True only for a logged-in, unlocked session. The router uses this, so a
  /// locked till cannot reach any till screen without the PIN.
  bool get hasActiveSession => authService.currentSession != null && !_isLocked;

  DateTime _lastActivity = DateTime.now();
  Timer? _inactivityTimer;
  bool _isDisposed = false;

  bool _isLocked = false;
  bool get isLocked => _isLocked;

  LockedUserState? _lockedUser;
  LockedUserState? get lockedUser => _lockedUser;

  String? get lockedStaffId => _lockedUser?.staffId;
  String? get lockedRoute => _lockedUser?.route;
  DateTime? get lockedAt => _lockedUser?.lockedAt;
  Map<String, dynamic> get savedState => _lockedUser?.state ?? {};

  void recordActivity() {
    _lastActivity = _clock();
    if (!_isLocked && authService.currentSession != null) {
      _startTimer();
    }
  }

  void _startTimer() {
    _inactivityTimer?.cancel();
    if (_isDisposed || _isLocked || authService.currentSession == null) return;
    final elapsed = _clock().difference(_lastActivity);
    final remaining = inactivityTimeout - elapsed;
    final delay = remaining > Duration.zero ? remaining : Duration.zero;
    _inactivityTimer = Timer(delay, () {
      checkInactivity();
    });
  }

  bool checkInactivity({
    String? currentRoute,
    Map<String, dynamic>? inMemoryState,
  }) {
    if (_isLocked || authService.currentSession == null) return false;
    final elapsed = _clock().difference(_lastActivity);
    if (elapsed >= inactivityTimeout) {
      lockCurrentSession(
        currentRoute: currentRoute,
        inMemoryState: inMemoryState,
      );
      return true;
    }
    return false;
  }

  void lockCurrentSession({
    String? currentRoute,
    Map<String, dynamic>? inMemoryState,
  }) {
    final session = authService.currentSession;
    if (session == null) return;

    _lockedUser = LockedUserState(
      staffId: session.staff.id,
      route: _restorableRoute(currentRoute ?? readCurrentRoute?.call()),
      lockedAt: _clock(),
      state: inMemoryState,
    );
    _isLocked = true;
    _inactivityTimer?.cancel();
    notifyListeners();
    onNavigateToLogin?.call();
  }

  String onLoginSuccess({required StaffEntry staff}) {
    _lastActivity = _clock();
    _isLocked = false;

    if (_lockedUser != null) {
      final isSameUser = _lockedUser!.staffId == staff.id;
      final elapsed = _clock().difference(_lockedUser!.lockedAt);
      final isWithinHold = elapsed <= stateHoldTimeout;

      if (isSameUser && isWithinHold) {
        final restoredRoute = _lockedUser!.route;
        _lockedUser = null;
        _startTimer();
        notifyListeners();
        return restoredRoute;
      } else {
        // Different user, or 30 minutes expired: discard!
        _lockedUser = null;
        _startTimer();
        notifyListeners();
        return '/till';
      }
    }

    _startTimer();
    notifyListeners();
    return '/till';
  }

  void clearLockedState() {
    _lockedUser = null;
    _isLocked = false;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _inactivityTimer?.cancel();
    super.dispose();
  }
}

/// Login and enrollment are never restore targets.
String _restorableRoute(String? route) {
  if (route == null ||
      route.isEmpty ||
      route.startsWith('/login') ||
      route.startsWith('/enrollment')) {
    return '/till';
  }
  return route;
}
