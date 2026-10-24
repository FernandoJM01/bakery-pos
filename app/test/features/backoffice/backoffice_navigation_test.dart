import 'package:bakery_pos/app.dart';
import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/router/app_router.dart';
import 'package:bakery_pos/features/backoffice/auth/data/backoffice_auth_service.dart';
import 'package:bakery_pos/features/backoffice/auth/presentation/backoffice_login_screen.dart';
import 'package:bakery_pos/features/backoffice/shell/presentation/backoffice_shell.dart';
import 'package:bakery_pos/features/branches/presentation/branches_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Backoffice Navigation and Permissions', () {
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
          dioProvider.overrideWithValue(dio),
          restClientProvider.overrideWithValue(restClient),
          backofficeAuthServiceProvider.overrideWithValue(authService),
        ],
        child: BakeryPosApp(
          mode: AppMode.backoffice,
          refreshListenable: authService,
          hasSession: () => authService.isAuthenticated,
          getPermissions: () =>
              authService.currentSession?.permissions ?? const [],
          backofficeLoginBuilder: (context) => const BackofficeLoginScreen(),
          backofficeShellBuilder: (context, state, child) =>
              BackofficeShell(child: child),
          backofficeSectionBuilder: (context, route) {
            if (route == AppRoutes.backofficeBranches) {
              return const BranchesScreen();
            }
            return BackofficeSectionPlaceholder.forRoute(route);
          },
        ),
      );
    }

    testWidgets('unauthenticated user is redirected to login', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(BackofficeLoginScreen), findsOneWidget);
      expect(find.byKey(const Key('backoffice-email-input')), findsOneWidget);
    });

    testWidgets('owner sees all 4 navigation sections', (tester) async {
      await tester.runAsync(
        () => authService.login('owner@panaderia.com', 'Admin123456!'),
      );
      authService.cancelSilentRefreshTimer();

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(BackofficeShell), findsOneWidget);
      expect(find.text('Fernando'), findsOneWidget);
      expect(find.text('OWNER'), findsOneWidget);

      final navRail = find.byKey(const Key('backoffice-nav-rail'));
      expect(
        find.descendant(of: navRail, matching: find.text('Sucursales')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: navRail, matching: find.text('Personal')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: navRail, matching: find.text('Dispositivos')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: navRail, matching: find.text('Auditoría')),
        findsOneWidget,
      );
    });

    testWidgets('manager only sees permitted sections', (tester) async {
      // manager@panaderia.com has: devices.manage, branches.manage, sale.create
      // but NOT staff.manage and NOT audit.view
      await tester.runAsync(
        () => authService.login('manager@panaderia.com', 'Admin123456!'),
      );
      authService.cancelSilentRefreshTimer();

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(BackofficeShell), findsOneWidget);
      expect(find.text('Carlos'), findsOneWidget);
      expect(find.text('BRANCH_MANAGER'), findsOneWidget);

      final navRail = find.byKey(const Key('backoffice-nav-rail'));
      expect(
        find.descendant(of: navRail, matching: find.text('Sucursales')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: navRail, matching: find.text('Dispositivos')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: navRail, matching: find.text('Personal')),
        findsNothing,
      );
      expect(
        find.descendant(of: navRail, matching: find.text('Auditoría')),
        findsNothing,
      );
    });

    testWidgets('logout button logs user out and redirects to login', (
      tester,
    ) async {
      await tester.runAsync(
        () => authService.login('owner@panaderia.com', 'Admin123456!'),
      );
      authService.cancelSilentRefreshTimer();

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(BackofficeShell), findsOneWidget);

      await tester.tap(find.byKey(const Key('backoffice-logout-button')));
      await tester.pumpAndSettle();

      expect(find.byType(BackofficeLoginScreen), findsOneWidget);
      expect(authService.isAuthenticated, isFalse);
    });
  });
}
