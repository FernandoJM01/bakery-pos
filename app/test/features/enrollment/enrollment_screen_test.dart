import 'package:bakery_pos/app.dart';
import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/router/app_router.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/presentation/till_login_screen.dart';
import 'package:bakery_pos/features/enrollment/presentation/enrollment_screen.dart';
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

Widget createEnrollmentTestWidget({
  required FakeSecureStorageStore fakeStore,
  bool isRevoked = false,
  RestClient? customRestClient,
}) {
  final secureStorage = SecureStorageService(fakeStore);
  final fakeDio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
    ..interceptors.add(FakeApiInterceptor());
  final restClient = customRestClient ?? RestClient(fakeDio);

  return ProviderScope(
    overrides: [
      secureStorageProvider.overrideWithValue(secureStorage),
      restClientProvider.overrideWithValue(restClient),
    ],
    child: MaterialApp(
      locale: const Locale('es', 'MX'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: EnrollmentScreen(isRevoked: isRevoked),
    ),
  );
}

void main() {
  group('EnrollmentScreen Widget Tests', () {
    late FakeSecureStorageStore fakeStore;

    setUp(() {
      fakeStore = FakeSecureStorageStore();
    });

    testWidgets('displays enrollment form elements with prefilled server URL', (
      tester,
    ) async {
      await tester.pumpWidget(createEnrollmentTestWidget(fakeStore: fakeStore));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('enrollment-server-url-field')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('enrollment-code-field')), findsOneWidget);
      expect(find.byKey(const Key('enrollment-submit-button')), findsOneWidget);

      final urlField = tester.widget<TextFormField>(
        find.byKey(const Key('enrollment-server-url-field')),
      );
      expect(urlField.controller?.text, 'http://localhost:3000');
    });

    testWidgets(
      'enforces Crockford Base32, uppercasing, and 8-character limit',
      (tester) async {
        await tester.pumpWidget(
          createEnrollmentTestWidget(fakeStore: fakeStore),
        );
        await tester.pumpAndSettle();

        final codeField = find.byKey(const Key('enrollment-code-field'));

        // 0, 1, I, O and symbols should be filtered out; letters uppercased
        await tester.enterText(codeField, 'ab01io!@#23cde99999');
        await tester.pumpAndSettle();

        // 'ab' -> 'AB', '0','1','i','o','!','@','#' filtered out, '23cde' -> '23CDE'
        // 'AB' + '23CDE' + '9' = 8 chars max: 'AB23CDE9'
        expect(find.text('AB23CDE9'), findsOneWidget);
      },
    );

    testWidgets('shows validation errors for short code and invalid URL', (
      tester,
    ) async {
      await tester.pumpWidget(createEnrollmentTestWidget(fakeStore: fakeStore));
      await tester.pumpAndSettle();

      final urlField = find.byKey(const Key('enrollment-server-url-field'));
      final codeField = find.byKey(const Key('enrollment-code-field'));
      final submitButton = find.byKey(const Key('enrollment-submit-button'));

      await tester.enterText(urlField, 'invalid-url-without-scheme');
      await tester.enterText(codeField, 'ABC');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(
        find.text('El código debe tener exactamente 8 caracteres'),
        findsOneWidget,
      );
      expect(
        find.text('Ingrese una URL válida (ej. http://192.168.1.100:3000)'),
        findsOneWidget,
      );
    });

    testWidgets(
      'shows Spanish error for expired or invalid code from Fake API',
      (tester) async {
        await tester.pumpWidget(
          createEnrollmentTestWidget(fakeStore: fakeStore),
        );
        await tester.pumpAndSettle();

        final codeField = find.byKey(const Key('enrollment-code-field'));
        final submitButton = find.byKey(const Key('enrollment-submit-button'));

        await tester.enterText(codeField, 'EXPR2345');
        await tester.ensureVisible(submitButton);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('enrollment-error-banner')),
          findsOneWidget,
        );
        expect(
          find.text('El código es inválido o ha expirado'),
          findsOneWidget,
        );
      },
    );

    testWidgets('shows Spanish error for rate limiting (429 RATE_LIMITED)', (
      tester,
    ) async {
      await tester.pumpWidget(createEnrollmentTestWidget(fakeStore: fakeStore));
      await tester.pumpAndSettle();

      final codeField = find.byKey(const Key('enrollment-code-field'));
      final submitButton = find.byKey(const Key('enrollment-submit-button'));

      await tester.enterText(codeField, 'RATELMT2');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('enrollment-error-banner')), findsOneWidget);
      expect(
        find.text(
          'Demasiados intentos. Espera unos minutos e intenta de nuevo.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'shows Spanish error for code validation failure (400 VALIDATION_FAILED)',
      (tester) async {
        await tester.pumpWidget(
          createEnrollmentTestWidget(fakeStore: fakeStore),
        );
        await tester.pumpAndSettle();

        final codeField = find.byKey(const Key('enrollment-code-field'));
        final submitButton = find.byKey(const Key('enrollment-submit-button'));

        await tester.enterText(codeField, 'BADCD234');
        await tester.ensureVisible(submitButton);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('enrollment-error-banner')),
          findsOneWidget,
        );
        expect(find.text('Revisa el código ingresado.'), findsOneWidget);
      },
    );

    testWidgets(
      'activates device successfully with valid code and stores credentials',
      (tester) async {
        final secureStorage = SecureStorageService(fakeStore);
        final fakeDio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
          ..interceptors.add(FakeApiInterceptor());

        final router = GoRouter(
          initialLocation: AppRoutes.tillEnrollment,
          routes: [
            GoRoute(
              path: AppRoutes.tillEnrollment,
              builder: (context, state) => const EnrollmentScreen(),
            ),
            GoRoute(
              path: AppRoutes.tillLogin,
              builder: (context, state) => const Scaffold(
                body: Text('till-login-screen', key: Key('till-login-screen')),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              secureStorageProvider.overrideWithValue(secureStorage),
              restClientProvider.overrideWithValue(RestClient(fakeDio)),
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

        final codeField = find.byKey(const Key('enrollment-code-field'));
        final submitButton = find.byKey(const Key('enrollment-submit-button'));

        await tester.enterText(codeField, 'ABCD2345');
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('till-login-screen')), findsOneWidget);
        expect(
          await secureStorage.getDeviceToken(),
          'fake-device-token-secret-32-bytes',
        );
        expect(await secureStorage.getEnrolledDevice(), contains('Caja 1'));
        expect(
          await secureStorage.getEnrolledBranch(),
          contains('Sucursal Centro'),
        );
        expect(await secureStorage.getServerUrl(), 'http://localhost:3000');
      },
    );

    testWidgets('displays revoked banner when redirected as revoked', (
      tester,
    ) async {
      await tester.pumpWidget(
        createEnrollmentTestWidget(fakeStore: fakeStore, isRevoked: true),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('enrollment-revoked-banner')),
        findsOneWidget,
      );
      expect(find.text('Dispositivo revocado'), findsOneWidget);
      expect(
        find.text(
          'Este dispositivo ha sido revocado. Los datos locales serán eliminados.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('router redirect: unenrolled till lands on /enrollment', (
      tester,
    ) async {
      final secureStorage = SecureStorageService(fakeStore);
      // No token in fakeStore
      final router = createAppRouter(
        AppMode.till,
        secureStorage: secureStorage,
        tillLoginBuilder: (context) => const TillLoginScreen(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [secureStorageProvider.overrideWithValue(secureStorage)],
          child: MaterialApp.router(
            locale: const Locale('es', 'MX'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Even though till initialLocation is /login, redirect sends it to /enrollment
      expect(find.byKey(const Key('enrollment-submit-button')), findsOneWidget);
    });

    testWidgets('router redirect: enrolled till lands on /login', (
      tester,
    ) async {
      final secureStorage = SecureStorageService(fakeStore);
      await secureStorage.saveDeviceToken('active-device-token');
      final inMemoryDb = AppDatabase(NativeDatabase.memory());
      final fakeDio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(FakeApiInterceptor());
      final router = createAppRouter(
        AppMode.till,
        secureStorage: secureStorage,
        tillLoginBuilder: (context) => const TillLoginScreen(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(secureStorage),
            tillDatabaseProvider.overrideWithValue(inMemoryDb),
            restClientProvider.overrideWithValue(RestClient(fakeDio)),
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

      // With token present, lands on TillLoginScreen
      expect(find.byType(TillLoginScreen), findsOneWidget);
      await inMemoryDb.close();
    });
  });
}
