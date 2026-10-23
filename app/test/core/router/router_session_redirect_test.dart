import 'package:bakery_pos/app.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/router/app_router.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/presentation/till_home_screen.dart';
import 'package:bakery_pos/features/auth/presentation/till_login_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  group('Router Session Redirect', () {
    late AppDatabase db;
    late SecureStorageService secureStorage;
    late TillAuthService authService;

    const validVerifier =
        r'$argon2id$v=19$m=65536,p=1,t=3$p6+vhCNw8VlT1Bnq34jEeg$cZv+IP6sdJhBnTqEB3+SsD8svzrLHXPiPpDEWJPp/54';

    final staff1 = StaffEntry(
      id: '0192e2b0-0020-7000-8000-000000000020',
      displayName: 'Carlos (Gerente)',
      role: 'BRANCH_MANAGER',
      offlinePinVerifier: validVerifier,
      pinUpdatedAt: DateTime.utc(2026, 1, 1),
    );

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      secureStorage = SecureStorageService(_FakeSecureStorage());
      // Set device token so device is enrolled
      await secureStorage.saveDeviceToken('test-device-token');

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(FakeApiInterceptor());

      authService = TillAuthService(
        restClient: RestClient(dio),
        database: db,
        secureStorage: secureStorage,
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
        ],
        permissions: [
          RolePermissionsCompanion.insert(
            role: 'BRANCH_MANAGER',
            permissionKey: 'sale.create',
          ),
        ],
      );
    });

    tearDown(() async {
      authService.dispose();
      await db.close();
    });

    testWidgets('redirects to /login when currentSession == null on /till', (
      tester,
    ) async {
      await tester.runAsync(() async {
        await authService.loginWithPin(staff: staff1, pin: '1234');
      });
      expect(authService.currentSession, isNotNull);

      final router = createAppRouter(
        AppMode.till,
        secureStorage: secureStorage,
        refreshListenable: authService,
        hasSession: () => authService.currentSession != null,
        tillLoginBuilder: (context) => const TillLoginScreen(),
        tillHomeBuilder: (context) => const TillHomeScreen(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tillDatabaseProvider.overrideWithValue(db),
            secureStorageProvider.overrideWithValue(secureStorage),
            tillAuthServiceProvider.overrideWithValue(authService),
          ],
          child: MaterialApp.router(
            locale: const Locale('es', 'MX'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to /till
      router.go(AppRoutes.tillHome);
      await tester.pumpAndSettle();

      // Till home screen is shown
      expect(find.byKey(const Key('mode-label')), findsOneWidget);
      expect(find.text('Carlos (Gerente)'), findsOneWidget);

      // Now session ends (e.g. failed refresh or logout)
      await tester.runAsync(() async {
        await authService.logout();
      });
      await tester.pumpAndSettle();

      // Router must redirect immediately to /login
      expect(find.byType(TillLoginScreen), findsOneWidget);
      expect(
        find.byKey(
          const Key('staff-tile-0192e2b0-0020-7000-8000-000000000020'),
        ),
        findsOneWidget,
      );

      authService.dispose();
      router.dispose();
    });
  });
}
