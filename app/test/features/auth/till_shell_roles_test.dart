import 'package:bakery_pos/app.dart';
import 'package:bakery_pos/core/router/app_router.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/domain/till_auth_state.dart';
import 'package:bakery_pos/features/auth/presentation/till_home_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeSecureStorageStore extends Fake implements FlutterSecureStorage {
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
}

Widget createTillShellTestWidget({
  required TillSession session,
  String? branchName,
}) {
  return ProviderScope(
    overrides: [
      tillSessionProvider.overrideWith(
        () => _StaticTillSessionNotifier(session),
      ),
      if (branchName != null)
        enrolledBranchNameProvider.overrideWith((ref) => branchName),
    ],
    child: const MaterialApp(
      locale: Locale('es', 'MX'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: TillHomeScreen(),
    ),
  );
}

Widget createTillRouterTestWidget({
  required TillSession session,
  required GoRouter router,
  String? branchName,
}) {
  return ProviderScope(
    overrides: [
      tillSessionProvider.overrideWith(
        () => _StaticTillSessionNotifier(session),
      ),
      if (branchName != null)
        enrolledBranchNameProvider.overrideWith((ref) => branchName),
    ],
    child: MaterialApp.router(
      locale: const Locale('es', 'MX'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

class _StaticTillSessionNotifier extends TillSessionNotifier {
  _StaticTillSessionNotifier(this._initial);
  final TillSession _initial;

  @override
  TillSession? build() => _initial;

  @override
  Future<List<String>> refreshPermissions() async => _initial.permissions;
}

void main() {
  group('Till Shell Roles & Permissions (Acceptance Test A17)', () {
    final cashierEntry = StaffEntry(
      id: '0192e2b0-0030-7000-8000-000000000030',
      displayName: 'Ana (Cajera)',
      role: 'CASHIER',
      offlinePinVerifier: 'verifier',
      pinUpdatedAt: DateTime.utc(2026, 1, 1),
    );

    final bakerEntry = StaffEntry(
      id: '0192e2b0-0040-7000-8000-000000000040',
      displayName: 'Beto (Panadero)',
      role: 'BAKER',
      offlinePinVerifier: 'verifier',
      pinUpdatedAt: DateTime.utc(2026, 1, 1),
    );

    final managerEntry = StaffEntry(
      id: '0192e2b0-0020-7000-8000-000000000020',
      displayName: 'Carlos (Gerente)',
      role: 'BRANCH_MANAGER',
      offlinePinVerifier: 'verifier',
      pinUpdatedAt: DateTime.utc(2026, 1, 1),
    );

    testWidgets(
      'Cashier sees Ventas, Caja, Pedidos, Horno; no Producción or Reportes',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final cashierSession = TillSession(
          staff: cashierEntry,
          permissions: const [
            'sale.create',
            'sale.void_line_before_payment',
            'sale.discount_within_limit',
            'cash.open_shift',
            'cash.close_shift',
            'orders.pickup',
            'oven.intake_pickup',
          ],
          isOffline: false,
        );

        await tester.pumpWidget(
          createTillShellTestWidget(session: cashierSession),
        );
        await tester.pumpAndSettle();

        final l10n = await AppLocalizations.delegate.load(
          const Locale('es', 'MX'),
        );

        // Permitted
        expect(find.text(l10n.navSales), findsWidgets);
        expect(find.text(l10n.navCash), findsWidgets);
        expect(find.text(l10n.navOrders), findsWidgets);
        expect(find.text(l10n.navOven), findsWidgets);

        // Not permitted
        expect(find.text(l10n.navProduction), findsNothing);
        expect(find.text(l10n.navReports), findsNothing);
      },
    );

    testWidgets('Baker sees only Producción and Horno', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final bakerSession = TillSession(
        staff: bakerEntry,
        permissions: const [
          'stock.production_entry',
          'stock.waste',
          'oven.board',
        ],
        isOffline: false,
      );

      await tester.pumpWidget(createTillShellTestWidget(session: bakerSession));
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(
        const Locale('es', 'MX'),
      );

      // Permitted
      expect(find.text(l10n.navProduction), findsWidgets);
      expect(find.text(l10n.navOven), findsWidgets);

      // Not permitted
      expect(find.text(l10n.navSales), findsNothing);
      expect(find.text(l10n.navCash), findsNothing);
      expect(find.text(l10n.navOrders), findsNothing);
      expect(find.text(l10n.navReports), findsNothing);
    });

    testWidgets('Manager sees all till sections, but no owner-only sections', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final managerSession = TillSession(
        staff: managerEntry,
        permissions: const [
          'sale.create',
          'sale.void_line_before_payment',
          'sale.void_after_payment',
          'sale.refund',
          'sale.discount_within_limit',
          'sale.discount_over_limit',
          'cash.open_shift',
          'cash.close_shift',
          'cash.movement',
          'cash.open_drawer_no_sale',
          'stock.production_entry',
          'stock.waste',
          'stock.count_adjust',
          'stock.transfer',
          'orders.manage',
          'orders.pickup',
          'oven.intake_pickup',
          'oven.board',
          'reports.branch',
        ],
        isOffline: false,
      );

      await tester.pumpWidget(
        createTillShellTestWidget(session: managerSession),
      );
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(
        const Locale('es', 'MX'),
      );

      // All till sections visible
      expect(find.text(l10n.navSales), findsWidgets);
      expect(find.text(l10n.navCash), findsWidgets);
      expect(find.text(l10n.navProduction), findsWidgets);
      expect(find.text(l10n.navOrders), findsWidgets);
      expect(find.text(l10n.navOven), findsWidgets);
      expect(find.text(l10n.navReports), findsWidgets);

      // Owner-only backoffice navigation sections not present in till
      expect(find.text(l10n.navStaff), findsNothing);
      expect(find.text(l10n.navDevices), findsNothing);
      expect(find.text(l10n.navBranches), findsNothing);
      expect(find.text(l10n.navSettings), findsNothing);
    });

    testWidgets('Top bar displays enrolled branch name', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cashierSession = TillSession(
        staff: cashierEntry,
        permissions: const ['sale.create'],
        isOffline: false,
      );

      await tester.pumpWidget(
        createTillShellTestWidget(
          session: cashierSession,
          branchName: 'Sucursal Centro',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('branch-name-label')), findsOneWidget);
      expect(find.text('Sucursal Centro'), findsOneWidget);
    });

    testWidgets(
      'Navigating to unpermitted section redirects to first permitted section',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        // Baker only has stock.production_entry and oven.board
        final bakerSession = TillSession(
          staff: bakerEntry,
          permissions: const ['stock.production_entry', 'oven.board'],
          isOffline: false,
        );

        final fakeStore = _FakeSecureStorageStore();
        final secureStorage = SecureStorageService(fakeStore);
        await secureStorage.saveDeviceToken('active-token');

        final router = createAppRouter(
          AppMode.till,
          secureStorage: secureStorage,
          hasSession: () => true,
          getPermissions: () => bakerSession.permissions,
          tillShellBuilder: (context, state, child) =>
              TillHomeScreen(child: child),
          tillSectionBuilder: (context, route) =>
              TillSectionPlaceholder.forRoute(route),
        );

        await tester.pumpWidget(
          createTillRouterTestWidget(session: bakerSession, router: router),
        );
        await tester.pumpAndSettle();

        // 1. Direct hit on /till redirects to first permitted: /till/produccion
        router.go(AppRoutes.tillHome);
        await tester.pumpAndSettle();
        expect(
          router.routerDelegate.currentConfiguration.uri.toString(),
          AppRoutes.tillProduction,
        );
        expect(find.byKey(const Key('section-production')), findsOneWidget);

        // 2. Direct hit on unpermitted /till/caja redirects to first permitted: /till/produccion
        router.go(AppRoutes.tillCash);
        await tester.pumpAndSettle();
        expect(
          router.routerDelegate.currentConfiguration.uri.toString(),
          AppRoutes.tillProduction,
        );
        expect(find.byKey(const Key('section-production')), findsOneWidget);

        // 3. User with no permissions lands on /till with no infinite loop
        final noPermSession = TillSession(
          staff: bakerEntry,
          permissions: const [],
          isOffline: false,
        );
        final noPermRouter = createAppRouter(
          AppMode.till,
          secureStorage: secureStorage,
          hasSession: () => true,
          getPermissions: () => noPermSession.permissions,
          tillShellBuilder: (context, state, child) =>
              TillHomeScreen(child: child),
          tillSectionBuilder: (context, route) =>
              TillSectionPlaceholder.forRoute(route),
        );

        await tester.pumpWidget(
          createTillRouterTestWidget(
            session: noPermSession,
            router: noPermRouter,
          ),
        );
        await tester.pumpAndSettle();

        noPermRouter.go(AppRoutes.tillSales);
        await tester.pumpAndSettle();
        expect(
          noPermRouter.routerDelegate.currentConfiguration.uri.toString(),
          AppRoutes.tillHome,
        );
      },
    );
  });
}
