import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/domain/till_auth_state.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSecureStorageStore extends Fake implements FlutterSecureStorage {
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
  group('TillAuthService', () {
    late AppDatabase db;
    late FakeSecureStorageStore fakeStore;
    late SecureStorageService secureStorage;
    late Dio dio;
    late RestClient restClient;
    late DateTime currentTime;

    final testStaff = StaffEntry(
      id: '0192e2b0-0020-7000-8000-000000000020',
      displayName: 'Carlos (Gerente)',
      role: 'BRANCH_MANAGER',
      offlinePinVerifier: r'$argon2id$v=19$m=65536,t=3,p=1$dGVzdHNhbHQxMjM0$a3eQTmzY2EF7EnnZVEMeIqJEhBxWE2OCvFk+kud2a/4',
      pinUpdatedAt: DateTime.utc(2026, 1, 1),
    );

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      fakeStore = FakeSecureStorageStore();
      secureStorage = SecureStorageService(fakeStore);
      dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(FakeApiInterceptor());
      restClient = RestClient(dio);
      currentTime = DateTime.utc(2026, 10, 21, 12, 0, 0);

      // Insert staff & role permissions into db
      await db.replaceStaffBundle(
        staff: [
          StaffEntriesCompanion.insert(
            id: testStaff.id,
            displayName: testStaff.displayName,
            role: testStaff.role,
            offlinePinVerifier: testStaff.offlinePinVerifier,
            pinUpdatedAt: testStaff.pinUpdatedAt,
          ),
        ],
        permissions: [
          RolePermissionsCompanion.insert(
            role: 'BRANCH_MANAGER',
            permissionKey: 'sale.create',
          ),
          RolePermissionsCompanion.insert(
            role: 'BRANCH_MANAGER',
            permissionKey: 'cash.close_shift',
          ),
        ],
      );
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'online login succeeds with valid PIN and stores refresh token',
      () async {
        final authService = TillAuthService(
          restClient: restClient,
          database: db,
          secureStorage: secureStorage,
          clock: () => currentTime,
        );

        final session = await authService.loginWithPin(
          staff: testStaff,
          pin: '1234',
        );

        expect(session.isOffline, isFalse);
        expect(session.staff.id, testStaff.id);
        expect(session.accessToken, isNotNull);
        expect(await secureStorage.getRefreshToken(), isNotNull);
        expect(session.hasPermission('sale.create'), isTrue);
      },
    );

    test(
      'online login throws TillAuthInvalidPinException on wrong PIN',
      () async {
        final authService = TillAuthService(
          restClient: restClient,
          database: db,
          secureStorage: secureStorage,
          clock: () => currentTime,
        );

        expect(
          () => authService.loginWithPin(staff: testStaff, pin: '9876'),
          throwsA(isA<TillAuthInvalidPinException>()),
        );
      },
    );

    test(
      'A15: locks staff member for 5 minutes after 5 wrong attempts',
      () async {
        final authService = TillAuthService(
          restClient: restClient,
          database: db,
          secureStorage: secureStorage,
          clock: () => currentTime,
        );

        // 4 wrong attempts: should throw TillAuthInvalidPinException
        for (int i = 1; i <= 4; i++) {
          await expectLater(
            () => authService.loginWithPin(staff: testStaff, pin: '111$i'),
            throwsA(isA<TillAuthInvalidPinException>()),
          );
        }

        // 5th wrong attempt triggers lockout
        await expectLater(
          () => authService.loginWithPin(staff: testStaff, pin: '9999'),
          throwsA(isA<TillAuthLockoutException>()),
        );

        // Attempt 6 (even with right PIN) should be locked
        expect(
          () => authService.loginWithPin(staff: testStaff, pin: '1234'),
          throwsA(isA<TillAuthLockoutException>()),
        );

        // Advance time by 4 minutes 59 seconds: still locked
        currentTime = currentTime.add(const Duration(minutes: 4, seconds: 59));
        expect(
          () => authService.loginWithPin(staff: testStaff, pin: '1234'),
          throwsA(isA<TillAuthLockoutException>()),
        );

        // Advance time by 2 more seconds (total > 5 minutes): unlocked!
        currentTime = currentTime.add(const Duration(seconds: 2));
        final session = await authService.loginWithPin(
          staff: testStaff,
          pin: '1234',
        );
        expect(session.isOffline, isFalse);
      },
    );

    test(
      'offline login verifies PIN with Argon2id and sets isOffline=true',
      () async {
        // Create a Dio that always fails (simulating network down / timeout)
        final offlineDio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.connectionError,
                    error: 'Network unreachable',
                  ),
                );
              },
            ),
          );

        final authService = TillAuthService(
          restClient: RestClient(offlineDio),
          database: db,
          secureStorage: secureStorage,
          clock: () => currentTime,
        );

        // Correct PIN -> offline session with permissions loaded from local DB
        final session = await authService.loginWithPin(
          staff: testStaff,
          pin: '1234',
        );
        expect(session.isOffline, isTrue);
        expect(session.accessToken, isNull);
        expect(session.hasPermission('sale.create'), isTrue);
        expect(session.hasPermission('cash.close_shift'), isTrue);

        // Wrong PIN offline -> throws TillAuthInvalidPinException
        expect(
          () => authService.loginWithPin(staff: testStaff, pin: '0000'),
          throwsA(isA<TillAuthInvalidPinException>()),
        );
      },
    );

    test(
      'silent refresh rotates refresh token and updates access token',
      () async {
        final authService = TillAuthService(
          restClient: restClient,
          database: db,
          secureStorage: secureStorage,
          clock: () => currentTime,
        );

        await authService.loginWithPin(staff: testStaff, pin: '1234');
        final initialRefreshToken = await secureStorage.getRefreshToken();
        expect(initialRefreshToken, isNotNull);

        // Run silent refresh
        await authService.silentRefresh();

        final updatedSession = authService.currentSession;
        expect(updatedSession, isNotNull);
        expect(updatedSession!.accessToken, 'fake-refreshed-jwt');
        expect(await secureStorage.getRefreshToken(), 'fake-new-refresh-token');
      },
    );
  });
}
