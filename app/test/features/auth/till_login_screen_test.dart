import 'dart:io';

import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/router/app_router.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/presentation/till_login_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

Widget createTillLoginTestWidget({
  required AppDatabase database,
  required SecureStorageService secureStorage,
  required RestClient restClient,
  TillAuthService? authService,
  GoRouter? router,
}) {
  final appRouter =
      router ??
      GoRouter(
        initialLocation: AppRoutes.tillLogin,
        routes: [
          GoRoute(
            path: AppRoutes.tillLogin,
            builder: (context, state) => const TillLoginScreen(),
          ),
          GoRoute(
            path: AppRoutes.tillHome,
            builder: (context, state) => const Scaffold(
              body: Text('till-home-screen', key: Key('till-home-screen')),
            ),
          ),
        ],
      );

  return ProviderScope(
    overrides: [
      tillDatabaseProvider.overrideWithValue(database),
      secureStorageProvider.overrideWithValue(secureStorage),
      restClientProvider.overrideWithValue(restClient),
      if (authService != null)
        tillAuthServiceProvider.overrideWithValue(authService),
    ],
    child: MaterialApp.router(
      locale: const Locale('es', 'MX'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    ),
  );
}

void main() {
  group('TillLoginScreen Widget Tests', () {
    late AppDatabase db;
    late FakeSecureStorageStore fakeStore;
    late SecureStorageService secureStorage;
    late RestClient restClient;
    late TillAuthService authService;

    const validVerifier =
        r'$argon2id$v=19$m=65536,p=1,t=3$p6+vhCNw8VlT1Bnq34jEeg$cZv+IP6sdJhBnTqEB3+SsD8svzrLHXPiPpDEWJPp/54';

    final staff1 = StaffEntriesCompanion.insert(
      id: '0192e2b0-0020-7000-8000-000000000020',
      displayName: 'Carlos (Gerente)',
      role: 'BRANCH_MANAGER',
      offlinePinVerifier: validVerifier,
      pinUpdatedAt: DateTime.utc(2026, 1, 1),
    );

    final staff2 = StaffEntriesCompanion.insert(
      id: '0192e2b0-0030-7000-8000-000000000030',
      displayName: 'Ana (Cajera)',
      role: 'CASHIER',
      offlinePinVerifier: validVerifier,
      pinUpdatedAt: DateTime.utc(2026, 1, 1),
    );

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      fakeStore = FakeSecureStorageStore();
      secureStorage = SecureStorageService(fakeStore);
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(FakeApiInterceptor());
      restClient = RestClient(dio);
      authService = TillAuthService(
        restClient: restClient,
        database: db,
        secureStorage: secureStorage,
      );

      await db.replaceStaffBundle(
        staff: [staff1, staff2],
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

    testWidgets('renders staff tiles and selects staff member', (tester) async {
      await tester.pumpWidget(
        createTillLoginTestWidget(
          database: db,
          secureStorage: secureStorage,
          restClient: restClient,
          authService: authService,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const Key('staff-tile-0192e2b0-0020-7000-8000-000000000020'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('staff-tile-0192e2b0-0030-7000-8000-000000000030'),
        ),
        findsOneWidget,
      );

      // Tap second staff tile
      await tester.tap(
        find.byKey(
          const Key('staff-tile-0192e2b0-0030-7000-8000-000000000030'),
        ),
      );
      await tester.pumpAndSettle();

      // Heading should show Ana (Cajera)
      expect(find.text('Ana (Cajera)'), findsWidgets);
    });

    testWidgets('keypad updates dots and enforces explicit confirm button', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTillLoginTestWidget(
          database: db,
          secureStorage: secureStorage,
          restClient: restClient,
          authService: authService,
        ),
      );
      await tester.pumpAndSettle();

      final confirmBtn = tester.widget<ElevatedButton>(
        find.byKey(const Key('keypad-confirm')),
      );
      // Disabled initially (0 digits)
      expect(confirmBtn.onPressed, isNull);

      // Tap 1, 2, 3
      await tester.tap(find.byKey(const Key('keypad-1')));
      await tester.tap(find.byKey(const Key('keypad-2')));
      await tester.tap(find.byKey(const Key('keypad-3')));
      await tester.pumpAndSettle();

      // Still disabled (< 4 digits)
      expect(
        tester
            .widget<ElevatedButton>(find.byKey(const Key('keypad-confirm')))
            .onPressed,
        isNull,
      );

      // Tap 4
      await tester.tap(find.byKey(const Key('keypad-4')));
      await tester.pumpAndSettle();

      // Now enabled (4 digits)
      expect(
        tester
            .widget<ElevatedButton>(find.byKey(const Key('keypad-confirm')))
            .onPressed,
        isNotNull,
      );

      // Backspace removes one digit
      await tester.tap(find.byKey(const Key('keypad-backspace')));
      await tester.pumpAndSettle();

      // Disabled again (3 digits)
      expect(
        tester
            .widget<ElevatedButton>(find.byKey(const Key('keypad-confirm')))
            .onPressed,
        isNull,
      );
    });

    testWidgets('shows Spanish error for invalid PIN and clears PIN', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTillLoginTestWidget(
          database: db,
          secureStorage: secureStorage,
          restClient: restClient,
          authService: authService,
        ),
      );
      await tester.pumpAndSettle();

      // Enter wrong PIN: 5555
      await tester.tap(find.byKey(const Key('keypad-5')));
      await tester.tap(find.byKey(const Key('keypad-5')));
      await tester.tap(find.byKey(const Key('keypad-5')));
      await tester.tap(find.byKey(const Key('keypad-5')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('keypad-confirm')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login-error-banner')), findsOneWidget);
      expect(find.text('PIN incorrecto'), findsOneWidget);
    });

    testWidgets('shows Spanish error with time when account is locked', (
      tester,
    ) async {
      // Record lockout in DB
      await db.recordFailedPinAttempt(
        '0192e2b0-0020-7000-8000-000000000020',
        DateTime.now().toUtc(),
      );
      for (int i = 0; i < 5; i++) {
        await db.recordFailedPinAttempt(
          '0192e2b0-0020-7000-8000-000000000020',
          DateTime.now().toUtc(),
        );
      }

      await tester.pumpWidget(
        createTillLoginTestWidget(
          database: db,
          secureStorage: secureStorage,
          restClient: restClient,
          authService: authService,
        ),
      );
      await tester.pumpAndSettle();

      // Enter PIN: 1234
      await tester.tap(find.byKey(const Key('keypad-1')));
      await tester.tap(find.byKey(const Key('keypad-2')));
      await tester.tap(find.byKey(const Key('keypad-3')));
      await tester.tap(find.byKey(const Key('keypad-4')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('keypad-confirm')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login-error-banner')), findsOneWidget);
      expect(find.textContaining('Bloqueado hasta las'), findsOneWidget);
    });

    testWidgets('successful login navigates to till home', (tester) async {
      await tester.pumpWidget(
        createTillLoginTestWidget(
          database: db,
          secureStorage: secureStorage,
          restClient: restClient,
          authService: authService,
        ),
      );
      await tester.pumpAndSettle();

      // Enter correct PIN: 1234
      await tester.tap(find.byKey(const Key('keypad-1')));
      await tester.tap(find.byKey(const Key('keypad-2')));
      await tester.tap(find.byKey(const Key('keypad-3')));
      await tester.tap(find.byKey(const Key('keypad-4')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('keypad-confirm')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('till-home-screen')), findsOneWidget);
      authService.dispose();
    });

    testWidgets('shows loginOfflineSession banner when session is offline', (
      tester,
    ) async {
      final offlineDio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionError,
                  error: const SocketException('offline'),
                ),
              );
            },
          ),
        );
      final offlineAuth = TillAuthService(
        restClient: RestClient(offlineDio),
        database: db,
        secureStorage: secureStorage,
      );

      final staff = await db.getStaffById(
        '0192e2b0-0020-7000-8000-000000000020',
      );
      await tester.runAsync(() async {
        await offlineAuth.loginWithPin(staff: staff!, pin: '1234');
      });

      await tester.pumpWidget(
        createTillLoginTestWidget(
          database: db,
          secureStorage: secureStorage,
          restClient: RestClient(offlineDio),
          authService: offlineAuth,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('login-offline-session-banner')),
        findsOneWidget,
      );
      expect(find.text('Sesión sin conexión'), findsOneWidget);
      offlineAuth.dispose();
    });
  });
}
