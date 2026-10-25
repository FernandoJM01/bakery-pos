import 'package:bakery_pos/app.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/router/app_router.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/domain/session_lock_manager.dart';
import 'package:bakery_pos/features/auth/presentation/till_home_screen.dart';
import 'package:bakery_pos/features/auth/presentation/till_login_screen.dart';
import 'package:bakery_pos/features/auth/presentation/user_activity_detector.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('A16 Auto-lock and Restore Integration Test', () {
    late AppDatabase db;
    late SecureStorageService secureStorage;
    late TillAuthService authService;
    late SessionLockManager lockManager;
    late GoRouter router;
    late DateTime currentTime;

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
      secureStorage = SecureStorageService(_FakeSecureStorage());
      await secureStorage.saveDeviceToken('active-device-token');

      currentTime = DateTime.utc(2026, 10, 21, 12, 0, 0);
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(FakeApiInterceptor());

      // Pass dio so the service installs TillAuthInterceptor, as the app's
      // provider does; without it requests carry no access token.
      authService = TillAuthService(
        restClient: RestClient(dio),
        dio: dio,
        database: db,
        secureStorage: secureStorage,
        clock: () => currentTime,
      );

      lockManager = SessionLockManager(
        authService: authService,
        clock: () => currentTime,
      );

      await db.replaceStaffBundle(
        staff: [staff1, staff2],
        permissions: [
          RolePermissionsCompanion.insert(
            role: 'BRANCH_MANAGER',
            permissionKey: 'sale.create',
          ),
          RolePermissionsCompanion.insert(
            role: 'BRANCH_MANAGER',
            permissionKey: 'cash.open_shift',
          ),
          RolePermissionsCompanion.insert(
            role: 'CASHIER',
            permissionKey: 'sale.create',
          ),
        ],
      );

      router = createAppRouter(
        AppMode.till,
        secureStorage: secureStorage,
        // Wired as in main_till.dart: a locked session counts as no access,
        // and the router refreshes on lock changes too.
        refreshListenable: Listenable.merge([authService, lockManager]),
        hasSession: () => lockManager.hasActiveSession,
        getPermissions: () =>
            authService.currentSession?.permissions ?? const [],
        tillLoginBuilder: (context) => const TillLoginScreen(),
        tillShellBuilder: (context, state, child) =>
            TillHomeScreen(child: child),
        tillSectionBuilder: (context, route) =>
            TillSectionPlaceholder.forRoute(route),
      );
      lockManager.readCurrentRoute = () =>
          router.routerDelegate.currentConfiguration.uri.toString();
    });

    tearDown(() async {
      lockManager.dispose();
      authService.dispose();
      await db.close();
      router.dispose();
    });

    testWidgets(
      'A16: auto-locks after 2 minutes idle and restores the same user on re-login',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tillDatabaseProvider.overrideWithValue(db),
              secureStorageProvider.overrideWithValue(secureStorage),
              tillAuthServiceProvider.overrideWithValue(authService),
              sessionLockManagerProvider.overrideWithValue(lockManager),
            ],
            child: MaterialApp.router(
              locale: const Locale('es', 'MX'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
              builder: (context, child) =>
                  UserActivityDetector(child: child ?? const SizedBox.shrink()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Initial screen is TillLoginScreen
        expect(find.byType(TillLoginScreen), findsOneWidget);

        // Select Carlos (Gerente)
        await tester.tap(
          find.byKey(
            const Key('staff-tile-0192e2b0-0020-7000-8000-000000000020'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter PIN: 1234
        for (final digit in ['1', '2', '3', '4']) {
          await tester.tap(find.byKey(Key('keypad-$digit')));
        }
        await tester.pump();

        await tester.runAsync(() async {
          await tester.tap(find.byKey(const Key('keypad-confirm')));
        });
        await tester.pumpAndSettle();

        // Carlos is on TillHomeScreen
        expect(find.byType(TillHomeScreen), findsOneWidget);
        expect(find.text('Carlos (Gerente)'), findsOneWidget);

        // Navigate to Caja section
        await tester.tap(find.byKey(const Key('nav-icon-cash')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('section-cash')), findsOneWidget);

        // 2. Advance time by 1m 59s -> NOT locked yet
        currentTime = currentTime.add(const Duration(minutes: 1, seconds: 59));
        lockManager.checkInactivity(currentRoute: AppRoutes.tillCash);
        await tester.pumpAndSettle();
        expect(find.byType(TillHomeScreen), findsOneWidget);

        // 3. Advance by 1 more second (2:00 idle) -> AUTO-LOCK FIRES
        currentTime = currentTime.add(const Duration(seconds: 1));
        lockManager.checkInactivity(currentRoute: AppRoutes.tillCash);
        await tester.pumpAndSettle();

        // Returned to login screen, Carlos's work is kept
        expect(find.byType(TillLoginScreen), findsOneWidget);
        expect(lockManager.isLocked, isTrue);
        expect(
          lockManager.lockedStaffId,
          '0192e2b0-0020-7000-8000-000000000020',
        );
        expect(lockManager.lockedRoute, AppRoutes.tillCash);

        // 4. Same user (Carlos) logs back in within 30 minutes (e.g. 10 minutes later)
        currentTime = currentTime.add(const Duration(minutes: 10));

        // Carlos enters PIN: 1234
        for (final digit in ['1', '2', '3', '4']) {
          await tester.tap(find.byKey(Key('keypad-$digit')));
        }
        await tester.pump();

        await tester.runAsync(() async {
          await tester.tap(find.byKey(const Key('keypad-confirm')));
        });
        await tester.pumpAndSettle();

        // Restored to Carlos's screen on Caja!
        expect(find.byType(TillHomeScreen), findsOneWidget);
        expect(find.text('Carlos (Gerente)'), findsOneWidget);
        expect(find.byKey(const Key('section-cash')), findsOneWidget);
        expect(lockManager.isLocked, isFalse);

        // 5. Test switch user: tap Carlos's name in top bar
        await tester.tap(find.byKey(const Key('switch-user-button')));
        await tester.pumpAndSettle();

        // Goes to login immediately with state held
        expect(find.byType(TillLoginScreen), findsOneWidget);
        expect(lockManager.isLocked, isTrue);

        // Ana (Cajera) logs in instead
        await tester.tap(
          find.byKey(
            const Key('staff-tile-0192e2b0-0030-7000-8000-000000000030'),
          ),
        );
        await tester.pumpAndSettle();

        for (final digit in ['1', '2', '3', '4']) {
          await tester.tap(find.byKey(Key('keypad-$digit')));
        }
        await tester.pump();

        await tester.runAsync(() async {
          await tester.tap(find.byKey(const Key('keypad-confirm')));
        });
        await tester.pumpAndSettle();

        // Ana starts fresh! Old state discarded
        expect(find.byType(TillHomeScreen), findsOneWidget);
        expect(find.text('Ana (Cajera)'), findsOneWidget);
        expect(lockManager.savedState, isEmpty);
      },
    );
  });
}
