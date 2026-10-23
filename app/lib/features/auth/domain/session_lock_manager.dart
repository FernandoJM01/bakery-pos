import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_database.dart';
import '../data/till_auth_service.dart';

/// Registry of user-scoped resets that must be run when
/// user state is discarded (on different user login, 30m idle timeout, or logout).
final userScopedResetCallbacks = <void Function(Ref ref)>[];

final sessionLockManagerProvider = Provider<SessionLockManager>((ref) {
  final authService = ref.watch(tillAuthServiceProvider);
  final manager = SessionLockManager(
    authService: authService,
    onResetUserState: () {
      for (final callback in userScopedResetCallbacks) {
        callback(ref);
      }
    },
  );
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

class ClockStopwatch implements Stopwatch {
  ClockStopwatch(this._clock);
  final DateTime Function() _clock;
  DateTime? _start;
  Duration _accumulated = Duration.zero;
  bool _running = false;

  @override
  Duration get elapsed {
    if (!_running) return _accumulated;
    return _accumulated + _clock().difference(_start!);
  }

  @override
  int get elapsedMilliseconds => elapsed.inMilliseconds;
  @override
  int get elapsedMicroseconds => elapsed.inMicroseconds;
  @override
  int get elapsedTicks => elapsed.inMicroseconds;
  @override
  int get frequency => 1000000;
  @override
  bool get isRunning => _running;

  @override
  void reset() {
    _accumulated = Duration.zero;
    _start = _clock();
  }

  @override
  void start() {
    if (!_running) {
      _start = _clock();
      _running = true;
    }
  }

  @override
  void stop() {
    if (_running) {
      _accumulated += _clock().difference(_start!);
      _running = false;
    }
  }
}

class SessionLockManager extends ChangeNotifier {
  SessionLockManager({
    required this.authService,
    this.inactivityTimeout = const Duration(minutes: 2),
    this.stateHoldTimeout = const Duration(minutes: 30),
    DateTime Function()? clock,
    Stopwatch? stopwatch,
    this.readCurrentRoute,
    this.onResetUserState,
  }) : _clock = clock ?? DateTime.now,
       _stopwatch =
           stopwatch ?? (clock != null ? ClockStopwatch(clock) : Stopwatch()) {
    authService.addListener(_onAuthChanged);
    _startTimer();
  }

  final TillAuthService authService;
  final Duration inactivityTimeout;
  final Duration stateHoldTimeout;
  final DateTime Function() _clock;
  final Stopwatch _stopwatch;
  final void Function()? onResetUserState;

  /// Reads the current location (set by main_till.dart from the router), so a
  /// lock fired by the idle timer still remembers which screen to restore.
  String? Function()? readCurrentRoute;

  /// True only for a logged-in, unlocked session. The router uses this, so a
  /// locked till cannot reach any till screen without the PIN.
  bool get hasActiveSession => authService.currentSession != null && !_isLocked;

  Timer? _inactivityTimer;
  Timer? _stateHoldTimer;
  bool _isDisposed = false;

  bool _isLocked = false;
  bool get isLocked => _isLocked;

  LockedUserState? _lockedUser;
  LockedUserState? get lockedUser => _lockedUser;

  String? get lockedStaffId => _lockedUser?.staffId;
  String? get lockedRoute => _lockedUser?.route;
  DateTime? get lockedAt => _lockedUser?.lockedAt;
  Map<String, dynamic> get savedState => _lockedUser?.state ?? {};

  void _onAuthChanged() {
    if (authService.currentSession == null) {
      if (_lockedUser != null || _isLocked) {
        clearLockedState();
      }
    }
  }

  void recordActivity() {
    _stopwatch.reset();
    _stopwatch.start();
    if (!_isLocked && authService.currentSession != null) {
      _startTimer();
    }
  }

  void _startTimer() {
    _inactivityTimer?.cancel();
    if (_isDisposed || _isLocked || authService.currentSession == null) return;
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
    }
    final elapsed = _stopwatch.elapsed;
    final remaining = inactivityTimeout - elapsed;
    final delay = remaining > Duration.zero ? remaining : Duration.zero;
    _inactivityTimer = Timer(delay, () {
      if (!checkInactivity()) {
        _startTimer();
      }
    });
  }

  bool checkInactivity({
    String? currentRoute,
    Map<String, dynamic>? inMemoryState,
  }) {
    if (_isLocked || authService.currentSession == null) return false;
    if (_stopwatch.elapsed >= inactivityTimeout) {
      lockCurrentSession(
        currentRoute: currentRoute,
        inMemoryState: inMemoryState,
      );
      return true;
    }
    _startTimer();
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
    _stopwatch.stop();
    _stopwatch.reset();

    // Drop access token and pause refresh while locked
    authService.pauseForLock();

    // Arm 30-minute hold timer to log out and discard state
    _stateHoldTimer?.cancel();
    _stateHoldTimer = Timer(stateHoldTimeout, () async {
      await _onStateHoldExpired();
    });

    notifyListeners();
  }

  Future<void> _onStateHoldExpired() async {
    final userToLogout = _lockedUser;
    clearLockedState();
    if (userToLogout != null) {
      await authService.logout();
    }
    onResetUserState?.call();
  }

  String onLoginSuccess({required StaffEntry staff}) {
    _stateHoldTimer?.cancel();
    _stopwatch.reset();
    _stopwatch.start();
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
        onResetUserState?.call();
        _startTimer();
        notifyListeners();
        return '/till';
      }
    }

    _startTimer();
    notifyListeners();
    return '/till';
  }

  void clearLockedState({bool resetUserState = true}) {
    _stateHoldTimer?.cancel();
    _lockedUser = null;
    _isLocked = false;
    if (resetUserState) {
      onResetUserState?.call();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    authService.removeListener(_onAuthChanged);
    _inactivityTimer?.cancel();
    _stateHoldTimer?.cancel();
    _stopwatch.stop();
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
