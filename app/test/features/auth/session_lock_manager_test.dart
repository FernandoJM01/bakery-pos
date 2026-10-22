import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/domain/session_lock_manager.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> values = {};
  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) values[key] = value;
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values.remove(key);

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values.clear();
}

void main() {
  group('SessionLockManager', () {
    late AppDatabase db;
    late SecureStorageService secureStorage;
    late TillAuthService authService;
    late DateTime currentTime;

    const validVerifier =
        r'$argon2id$v=19$m=65536,p=1,t=3$p6+vhCNw8VlT1Bnq34jEeg$cZv+IP6sdJhBnTqEB3+SsD8svzrLHXPiPpDEWJPp/54';

    final staff1 = StaffEntry(
      id: '0192e2b0-0020-7000-8000-000000000020',
      displayName: 'Carlos (Gerente)',
      role: 'BRANCH_MANAGER',
      offlinePinVerifier: validVerifier,
      pinUpdatedAt: DateTime.utc(2026, 1, 1),
    );

    final staff2 = StaffEntry(
      id: '0192e2b0-0030-7000-8000-000000000030',
      displayName: 'Ana (Cajera)',
      role: 'CASHIER',
      offlinePinVerifier: validVerifier,
      pinUpdatedAt: DateTime.utc(2026, 1, 1),
    );

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      secureStorage = SecureStorageService(_FakeSecureStorage());
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(FakeApiInterceptor());
      currentTime = DateTime.utc(2026, 10, 21, 12, 0, 0);

      authService = TillAuthService(
        restClient: RestClient(dio),
        database: db,
        secureStorage: secureStorage,
        clock: () => currentTime,
      );

      await db.replaceStaffBundle(
        staff: [
          StaffEntriesCompanion.insert(
            id: staff1.id,
            displayName: staff1.displayName,
            role: staff1.role,
            offlinePinVerifier: staff1.offlinePinVerifier,
            pinUpdatedAt: staff1.pinUpdatedAt,
          ),
          StaffEntriesCompanion.insert(
            id: staff2.id,
            displayName: staff2.displayName,
            role: staff2.role,
            offlinePinVerifier: staff2.offlinePinVerifier,
            pinUpdatedAt: staff2.pinUpdatedAt,
          ),
        ],
        permissions: [
          RolePermissionsCompanion.insert(
            role: 'BRANCH_MANAGER',
            permissionKey: 'sale.create',
          ),
          RolePermissionsCompanion.insert(
            role: 'CASHIER',
            permissionKey: 'sale.create',
          ),
        ],
      );
    });

    tearDown(() async {
      authService.dispose();
      await db.close();
    });

    test(
      'an idle-timer lock remembers the current screen and blocks access',
      () async {
        await authService.loginWithPin(staff: staff1, pin: '1234');
        final lockManager = SessionLockManager(
          authService: authService,
          clock: () => currentTime,
        )..readCurrentRoute = () => '/till/sales?ticket=7';

        expect(lockManager.hasActiveSession, isTrue);
        currentTime = currentTime.add(const Duration(minutes: 2));
        expect(lockManager.checkInactivity(), isTrue);

        // The session still exists (held state) but is not usable while locked.
        expect(authService.currentSession, isNotNull);
        expect(lockManager.hasActiveSession, isFalse);
        expect(lockManager.lockedRoute, '/till/sales?ticket=7');

        expect(
          lockManager.onLoginSuccess(staff: staff1),
          '/till/sales?ticket=7',
        );
        expect(lockManager.hasActiveSession, isTrue);
        lockManager.dispose();
      },
    );

    test('login and enrollment are never restore targets', () async {
      await authService.loginWithPin(staff: staff1, pin: '1234');
      final lockManager = SessionLockManager(
        authService: authService,
        clock: () => currentTime,
      )..readCurrentRoute = () => '/login';

      lockManager.lockCurrentSession();
      expect(lockManager.lockedRoute, '/till');
      lockManager.dispose();
    });

    test('auto-lock fires at 2:00 and not at 1:59', () async {
      await authService.loginWithPin(staff: staff1, pin: '1234');
      bool navigatedToLogin = false;

      final lockManager = SessionLockManager(
        authService: authService,
        clock: () => currentTime,
        onNavigateToLogin: () => navigatedToLogin = true,
      );

      // Advance by 1 minute 59 seconds: should NOT lock
      currentTime = currentTime.add(const Duration(minutes: 1, seconds: 59));
      expect(lockManager.checkInactivity(), isFalse);
      expect(lockManager.isLocked, isFalse);
      expect(navigatedToLogin, isFalse);

      // Advance by 1 more second (total 2:00): MUST lock
      currentTime = currentTime.add(const Duration(seconds: 1));
      expect(lockManager.checkInactivity(), isTrue);
      expect(lockManager.isLocked, isTrue);
      expect(lockManager.lockedStaffId, staff1.id);
      expect(navigatedToLogin, isTrue);

      lockManager.dispose();
    });

    test('user activity resets inactivity countdown', () async {
      await authService.loginWithPin(staff: staff1, pin: '1234');
      final lockManager = SessionLockManager(
        authService: authService,
        clock: () => currentTime,
      );

      // Advance to 1:30
      currentTime = currentTime.add(const Duration(minutes: 1, seconds: 30));
      expect(lockManager.checkInactivity(), isFalse);

      // Touch / key activity occurs
      lockManager.recordActivity();

      // Advance by another 1:30 (total 3:00 from start, but 1:30 from activity)
      currentTime = currentTime.add(const Duration(minutes: 1, seconds: 30));
      expect(lockManager.checkInactivity(), isFalse);
      expect(lockManager.isLocked, isFalse);

      // Advance 31 more seconds (now 2:01 since activity) -> locks
      currentTime = currentTime.add(const Duration(seconds: 31));
      expect(lockManager.checkInactivity(), isTrue);
      expect(lockManager.isLocked, isTrue);

      lockManager.dispose();
    });

    test('the same user is restored within 30 minutes, and a different user starts fresh', () async {
      await authService.loginWithPin(staff: staff1, pin: '1234');
      final lockManager = SessionLockManager(
        authService: authService,
        clock: () => currentTime,
      );

      // Lock session while on /till/sales with specific screen state
      lockManager.lockCurrentSession(
        currentRoute: '/till/sales',
        inMemoryState: {'cartItems': 3, 'discount': 10},
      );
      expect(lockManager.isLocked, isTrue);
      expect(lockManager.lockedStaffId, staff1.id);
      expect(lockManager.lockedRoute, '/till/sales');
      expect(lockManager.savedState['cartItems'], 3);

      // Advance by 15 minutes (< 30 minutes)
      currentTime = currentTime.add(const Duration(minutes: 15));

      // Same user logs in again
      final destination = lockManager.onLoginSuccess(staff: staff1);
      expect(destination, '/till/sales');
      expect(lockManager.isLocked, isFalse);
      expect(lockManager.lockedStaffId, isNull);

      // Now test different user:
      // Lock again on /till/sales
      lockManager.lockCurrentSession(
        currentRoute: '/till/sales',
        inMemoryState: {'cartItems': 5},
      );
      expect(lockManager.lockedStaffId, staff1.id);

      // Advance 5 minutes
      currentTime = currentTime.add(const Duration(minutes: 5));

      // Different user (staff2) logs in
      final destinationStaff2 = lockManager.onLoginSuccess(staff: staff2);
      // Starts fresh at /till
      expect(destinationStaff2, '/till');
      expect(lockManager.isLocked, isFalse);
      expect(lockManager.lockedStaffId, isNull);
      expect(lockManager.savedState, isEmpty);

      lockManager.dispose();
    });

    test('the old state is discarded after 30 minutes', () async {
      await authService.loginWithPin(staff: staff1, pin: '1234');
      final lockManager = SessionLockManager(
        authService: authService,
        clock: () => currentTime,
      );

      // Lock on /till/sales
      lockManager.lockCurrentSession(
        currentRoute: '/till/sales',
        inMemoryState: {'orderId': '101'},
      );

      // Advance by 30 minutes and 1 second (> 30 minutes)
      currentTime = currentTime.add(const Duration(minutes: 30, seconds: 1));

      // Same user logs in after timeout
      final destination = lockManager.onLoginSuccess(staff: staff1);
      // Discarded! Starts fresh at /till
      expect(destination, '/till');
      expect(lockManager.savedState, isEmpty);
      expect(lockManager.lockedStaffId, isNull);

      lockManager.dispose();
    });
  });
}
