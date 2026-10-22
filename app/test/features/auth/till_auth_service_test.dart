import 'dart:io';

import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/domain/till_auth_state.dart';
import 'package:bakery_pos/features/staff/data/staff_sync_service.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    // Fixture for 1234
    const validVerifier =
        r'$argon2id$v=19$m=65536,p=1,t=3$p6+vhCNw8VlT1Bnq34jEeg$cZv+IP6sdJhBnTqEB3+SsD8svzrLHXPiPpDEWJPp/54';

    final testStaff = StaffEntry(
      id: '0192e2b0-0020-7000-8000-000000000020',
      displayName: 'Carlos (Gerente)',
      role: 'BRANCH_MANAGER',
      offlinePinVerifier: validVerifier,
      pinUpdatedAt: DateTime.utc(2026, 1, 1),
    );

    setUpAll(() {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    });

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      fakeStore = FakeSecureStorageStore();
      secureStorage = SecureStorageService(fakeStore);
      dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(FakeApiInterceptor());
      restClient = RestClient(dio);
      currentTime = DateTime.utc(2026, 10, 21, 12, 0, 0);

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
        authService.dispose();
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

        await expectLater(
          () => authService.loginWithPin(staff: testStaff, pin: '9876'),
          throwsA(isA<TillAuthInvalidPinException>()),
        );
        authService.dispose();
      },
    );

    test('online login on AUTH_NOT_ALLOWED throws TillAuthNotAllowedException and does not record strike', () async {
      final authService = TillAuthService(
        restClient: restClient,
        database: db,
        secureStorage: secureStorage,
        clock: () => currentTime,
      );

      // pin 0000 triggers AUTH_NOT_ALLOWED in FakeApiInterceptor
      await expectLater(
        () => authService.loginWithPin(staff: testStaff, pin: '0000'),
        throwsA(isA<TillAuthNotAllowedException>()),
      );

      // Lockout count should be zero
      final activeLockout = await db.getActiveLockout(
        testStaff.id,
        currentTime,
      );
      expect(activeLockout, isNull);
      authService.dispose();
    });

    test('online login on DEVICE_REVOKED or DEVICE_UNKNOWN rethrows without touching database', () async {
      final revokedDio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 401,
                    data: {
                      'code': 'DEVICE_REVOKED',
                      'message': 'Device has been revoked',
                    },
                  ),
                ),
              );
            },
          ),
        );

      final authService = TillAuthService(
        restClient: RestClient(revokedDio),
        database: db,
        secureStorage: secureStorage,
        clock: () => currentTime,
      );

      await expectLater(
        () => authService.loginWithPin(staff: testStaff, pin: '1234'),
        throwsA(
          isA<DioException>().having(
            (e) => (e.response?.data as Map)['code'],
            'code',
            'DEVICE_REVOKED',
          ),
        ),
      );

      final activeLockout = await db.getActiveLockout(
        testStaff.id,
        currentTime,
      );
      expect(activeLockout, isNull);
      authService.dispose();
    });

    test('online login on server AUTH_LOCKED sets lockout locally without incrementing strikes', () async {
      final authService = TillAuthService(
        restClient: restClient,
        database: db,
        secureStorage: secureStorage,
        clock: () => currentTime,
      );

      // 999999 triggers AUTH_LOCKED in FakeApiInterceptor
      await expectLater(
        () => authService.loginWithPin(staff: testStaff, pin: '999999'),
        throwsA(isA<TillAuthLockoutException>()),
      );

      final activeLockout = await db.getActiveLockout(
        testStaff.id,
        currentTime,
      );
      expect(activeLockout, isNotNull);
      authService.dispose();
    });

    test('server 400 or 500 errors throw TillAuthGenericException without falling back to offline login', () async {
      final serverErrorDio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 500,
                    data: {
                      'code': 'INTERNAL_ERROR',
                      'message': 'Database connection lost on server',
                    },
                  ),
                ),
              );
            },
          ),
        );

      final authService = TillAuthService(
        restClient: RestClient(serverErrorDio),
        database: db,
        secureStorage: secureStorage,
        clock: () => currentTime,
      );

      await expectLater(
        () => authService.loginWithPin(staff: testStaff, pin: '1234'),
        throwsA(isA<TillAuthGenericException>()),
      );
      authService.dispose();
    });

    test(
      'A15: locks staff member for 5 minutes after 5 wrong attempts',
      () async {
        final authService = TillAuthService(
          restClient: restClient,
          database: db,
          secureStorage: secureStorage,
          clock: () => currentTime,
        );

        // 4 wrong attempts: throws TillAuthInvalidPinException
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
        await expectLater(
          () => authService.loginWithPin(staff: testStaff, pin: '1234'),
          throwsA(isA<TillAuthLockoutException>()),
        );

        // Advance time by 4 minutes 59 seconds: still locked
        currentTime = currentTime.add(const Duration(minutes: 4, seconds: 59));
        await expectLater(
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
        authService.dispose();
      },
    );

    test('A15 Offline: network off, wrong PIN x 5 locks for 5 min, survives DB reopen, unlocks after 5 min', () async {
      final offlineDio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionError,
                  error: const SocketException('Failed host lookup'),
                ),
              );
            },
          ),
        );

      // Use a persistent SQLite file on disk so we can close and reopen it
      final tempDir = Directory.systemTemp.createTempSync('a15_test_');
      final dbFile = File('${tempDir.path}/a15_test.db');
      var fileDb = AppDatabase(NativeDatabase(dbFile));

      await fileDb.replaceStaffBundle(
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
        ],
      );

      var authService = TillAuthService(
        restClient: RestClient(offlineDio),
        database: fileDb,
        secureStorage: secureStorage,
        clock: () => currentTime,
      );

      // Right PIN succeeds offline first
      final initialSession = await authService.loginWithPin(
        staff: testStaff,
        pin: '1234',
      );
      expect(initialSession.isOffline, isTrue);

      // 4 wrong attempts
      for (int i = 1; i <= 4; i++) {
        await expectLater(
          () => authService.loginWithPin(staff: testStaff, pin: '111$i'),
          throwsA(isA<TillAuthInvalidPinException>()),
        );
      }

      // 5th wrong attempt triggers lockout
      await expectLater(
        () => authService.loginWithPin(staff: testStaff, pin: '8888'),
        throwsA(isA<TillAuthLockoutException>()),
      );

      // 6th attempt is locked
      await expectLater(
        () => authService.loginWithPin(staff: testStaff, pin: '1234'),
        throwsA(isA<TillAuthLockoutException>()),
      );

      // Close and reopen database
      authService.dispose();
      await fileDb.close();

      // Reopen database from same file
      fileDb = AppDatabase(NativeDatabase(dbFile));
      authService = TillAuthService(
        restClient: RestClient(offlineDio),
        database: fileDb,
        secureStorage: secureStorage,
        clock: () => currentTime,
      );

      // Verify lockout survived DB close & reopen
      await expectLater(
        () => authService.loginWithPin(staff: testStaff, pin: '1234'),
        throwsA(isA<TillAuthLockoutException>()),
      );

      // Advance fake clock by 5 minutes 1 second
      currentTime = currentTime.add(const Duration(minutes: 5, seconds: 1));

      // Now correct PIN succeeds!
      final unlockedSession = await authService.loginWithPin(
        staff: testStaff,
        pin: '1234',
      );
      expect(unlockedSession.isOffline, isTrue);

      authService.dispose();
      await fileDb.close();
      tempDir.deleteSync(recursive: true);
    });

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
        authService.dispose();
      },
    );

    test('silent refresh on 401 logs out and deletes refresh token', () async {
      final authService = TillAuthService(
        restClient: restClient,
        database: db,
        secureStorage: secureStorage,
        clock: () => currentTime,
      );

      await authService.loginWithPin(staff: testStaff, pin: '1234');
      expect(authService.currentSession, isNotNull);

      // Set refresh token to invalid-token which triggers 401 in FakeApiInterceptor
      await secureStorage.saveRefreshToken('invalid-token');

      await authService.silentRefresh();

      expect(authService.currentSession, isNull);
      expect(await secureStorage.getRefreshToken(), isNull);
      authService.dispose();
    });

    test(
      'reauthenticateOnline re-logs in currently logged-in staff member',
      () async {
        final authService = TillAuthService(
          restClient: restClient,
          database: db,
          secureStorage: secureStorage,
          clock: () => currentTime,
        );

        await authService.loginWithPin(staff: testStaff, pin: '1234');
        final reauthenticated = await authService.reauthenticateOnline('1234');
        expect(reauthenticated.isOffline, isFalse);
        expect(reauthenticated.staff.id, testStaff.id);
        authService.dispose();
      },
    );

    test('reauthenticateOnline throws when no active session', () async {
      final authService = TillAuthService(
        restClient: restClient,
        database: db,
        secureStorage: secureStorage,
        clock: () => currentTime,
      );

      await expectLater(
        () => authService.reauthenticateOnline('1234'),
        throwsA(isA<TillAuthGenericException>()),
      );
      authService.dispose();
    });

    test('TillSessionNotifier syncs with TillAuthService state', () async {
      final container = ProviderContainer(
        overrides: [
          tillDatabaseProvider.overrideWithValue(db),
          secureStorageProvider.overrideWithValue(secureStorage),
          restClientProvider.overrideWithValue(restClient),
        ],
      );

      expect(container.read(tillSessionProvider), isNull);

      final notifier = container.read(tillSessionProvider.notifier);
      final session = await notifier.login(staff: testStaff, pin: '1234');
      expect(session.isOffline, isFalse);
      expect(container.read(tillSessionProvider), isNotNull);

      await notifier.reauthenticateOnline('1234');
      expect(container.read(tillSessionProvider), isNotNull);

      await notifier.logout();
      expect(container.read(tillSessionProvider), isNull);

      container.dispose();
    });

    test('online re-authentication is required after an offline session before sync', () async {
      final offlineDio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) => handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: const SocketException('offline'),
              ),
            ),
          ),
        );
      final offlineAuth = TillAuthService(
        restClient: RestClient(offlineDio),
        database: db,
        secureStorage: secureStorage,
        clock: () => currentTime,
      );

      final session = await offlineAuth.loginWithPin(
        staff: testStaff,
        pin: '1234',
      );
      expect(session.isOffline, isTrue);

      final syncService = StaffSyncService(
        restClient: restClient,
        database: db,
        authService: offlineAuth,
      );

      // Attempt sync during offline session -> MUST throw
      await expectLater(
        () => syncService.syncStaffBundle(),
        throwsA(isA<TillAuthGenericException>()),
      );

      // Attempt reauthenticateOnline while still offline -> throws and stays offline
      await expectLater(
        () => offlineAuth.reauthenticateOnline('1234'),
        throwsA(isA<TillAuthGenericException>()),
      );
      expect(offlineAuth.currentSession?.isOffline, isTrue);

      // Still cannot sync
      await expectLater(
        () => syncService.syncStaffBundle(),
        throwsA(isA<TillAuthGenericException>()),
      );

      offlineAuth.dispose();
    });

    test('logout calls POST /v1/auth/logout and clears tokens', () async {
      bool logoutEndpointCalled = false;
      final logoutDio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path.endsWith('/v1/auth/logout') &&
                  options.method == 'POST') {
                logoutEndpointCalled = true;
                return handler.resolve(
                  Response(requestOptions: options, statusCode: 204),
                );
              }
              handler.next(options);
            },
          ),
        )
        ..interceptors.add(FakeApiInterceptor());

      final auth = TillAuthService(
        restClient: RestClient(logoutDio),
        database: db,
        secureStorage: secureStorage,
        clock: () => currentTime,
      );

      await auth.loginWithPin(staff: testStaff, pin: '1234');
      expect(auth.currentSession, isNotNull);

      await auth.logout();
      expect(logoutEndpointCalled, isTrue);
      expect(auth.currentSession, isNull);
      expect(await secureStorage.getRefreshToken(), isNull);
      auth.dispose();
    });
  });
}
