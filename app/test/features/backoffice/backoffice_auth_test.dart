import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/features/backoffice/auth/data/backoffice_auth_service.dart';
import 'package:bakery_pos/features/backoffice/auth/domain/backoffice_auth_exceptions.dart';
import 'package:bakery_pos/features/backoffice/auth/presentation/backoffice_login_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackofficeAuthService', () {
    late Dio dio;
    late RestClient restClient;
    late BackofficeAuthService authService;

    setUp(() {
      dio = Dio();
      dio.interceptors.add(FakeApiInterceptor());
      restClient = RestClient(dio);
      authService = BackofficeAuthService(restClient: restClient, dio: dio);
      addTearDown(() => authService.dispose());
    });

    test('successful login sets session in memory', () async {
      expect(authService.isAuthenticated, isFalse);

      final session = await authService.login(
        'owner@panaderia.com',
        'Admin123456!',
      );

      expect(authService.isAuthenticated, isTrue);
      expect(session.accessToken, isNotEmpty);
      expect(session.refreshToken, isNotEmpty);
      expect(session.staff.displayName, 'Fernando');
      expect(session.permissions, contains('branches.manage'));
    });

    test(
      'login with wrong password throws InvalidCredentialsException',
      () async {
        expect(
          () => authService.login('owner@panaderia.com', 'wrongpassword'),
          throwsA(isA<BackofficeAuthInvalidCredentialsException>()),
        );
        expect(authService.isAuthenticated, isFalse);
      },
    );

    test('login with locked email throws LockedException with time', () async {
      expect(
        () => authService.login('locked@panaderia.com', 'Admin123456!'),
        throwsA(
          isA<BackofficeAuthLockedException>().having(
            (e) => e.lockedUntil,
            'lockedUntil',
            isNotNull,
          ),
        ),
      );
      expect(authService.isAuthenticated, isFalse);
    });

    test('logout clears session from memory', () async {
      await authService.login('owner@panaderia.com', 'Admin123456!');
      expect(authService.isAuthenticated, isTrue);

      await authService.logout();
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentSession, isNull);
    });

    test('silentRefresh updates session tokens', () async {
      await authService.login('owner@panaderia.com', 'Admin123456!');
      final oldAccess = authService.currentSession!.accessToken;

      final newAccess = await authService.silentRefresh();
      expect(newAccess, isNotNull);
      expect(newAccess, isNot(oldAccess));
      expect(authService.currentSession!.accessToken, newAccess);
    });
  });

  group('BackofficeLoginScreen widget', () {
    late Dio dio;
    late RestClient restClient;
    late BackofficeAuthService authService;

    setUp(() {
      dio = Dio();
      dio.interceptors.add(FakeApiInterceptor());
      restClient = RestClient(dio);
      authService = BackofficeAuthService(restClient: restClient, dio: dio);
      addTearDown(() => authService.dispose());
    });

    Widget createTestApp() {
      return ProviderScope(
        overrides: [
          backofficeAuthServiceProvider.overrideWithValue(authService),
        ],
        child: const MaterialApp(
          locale: Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BackofficeLoginScreen(),
        ),
      );
    }

    testWidgets('shows validation errors when fields are empty', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('backoffice-login-button')));
      await tester.pumpAndSettle();

      expect(find.text('Revisa el código ingresado.'), findsNWidgets(2));
    });

    testWidgets('shows invalid credentials message on failed login', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('backoffice-email-input')),
        'admin@test.com',
      );
      await tester.enterText(
        find.byKey(const Key('backoffice-password-input')),
        'WrongPassword123!',
      );
      await tester.tap(find.byKey(const Key('backoffice-login-button')));
      await tester.pumpAndSettle();

      expect(find.text('Credenciales inválidas'), findsOneWidget);
    });

    testWidgets('shows locked account message when account is locked', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('backoffice-email-input')),
        'locked@panaderia.com',
      );
      await tester.enterText(
        find.byKey(const Key('backoffice-password-input')),
        'Admin123456!',
      );
      await tester.tap(find.byKey(const Key('backoffice-login-button')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Demasiados intentos. Bloqueado hasta las'),
        findsOneWidget,
      );
    });

    testWidgets('logs in successfully with valid credentials', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('backoffice-email-input')),
        'owner@panaderia.com',
      );
      await tester.enterText(
        find.byKey(const Key('backoffice-password-input')),
        'Admin123456!',
      );
      await tester.tap(find.byKey(const Key('backoffice-login-button')));
      await tester.pumpAndSettle();

      expect(authService.isAuthenticated, isTrue);
      authService.dispose();
    });
  });
}
