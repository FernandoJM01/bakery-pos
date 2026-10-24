import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../features/backoffice/shell/presentation/backoffice_shell.dart';
import '../../features/branches/presentation/branches_screen.dart';
import '../../features/enrollment/presentation/enrollment_screen.dart';
import '../storage/secure_storage.dart';

class AppRoutes {
  static const String tillEnrollment = '/enrollment';
  static const String tillLogin = '/login';
  static const String tillHome = '/till';
  static const String tillSales = '/till/ventas';
  static const String tillCash = '/till/caja';
  static const String tillProduction = '/till/produccion';
  static const String tillOrders = '/till/pedidos';
  static const String tillOven = '/till/horno';
  static const String tillReports = '/till/reportes';

  static const String backofficeLogin = '/backoffice/login';
  static const String backofficeDashboard = '/backoffice/dashboard';
  static const String backofficeBranches = '/backoffice/branches';
  static const String backofficeStaff = '/backoffice/staff';
  static const String backofficeDevices = '/backoffice/devices';
  static const String backofficeAudit = '/backoffice/audit';
}

const tillSectionRoutes = [
  AppRoutes.tillSales,
  AppRoutes.tillCash,
  AppRoutes.tillProduction,
  AppRoutes.tillOrders,
  AppRoutes.tillOven,
  AppRoutes.tillReports,
];

const backofficeSectionRoutes = [
  AppRoutes.backofficeBranches,
  AppRoutes.backofficeStaff,
  AppRoutes.backofficeDevices,
  AppRoutes.backofficeAudit,
];

List<String> getPermittedTillRoutes(List<String> permissions) {
  final permitted = <String>[];
  if (permissions.contains('sale.create')) {
    permitted.add(AppRoutes.tillSales);
  }
  if (permissions.contains('cash.open_shift')) {
    permitted.add(AppRoutes.tillCash);
  }
  if (permissions.contains('stock.production_entry')) {
    permitted.add(AppRoutes.tillProduction);
  }
  if (permissions.contains('orders.pickup')) {
    permitted.add(AppRoutes.tillOrders);
  }
  if (permissions.contains('oven.intake_pickup') ||
      permissions.contains('oven.board')) {
    permitted.add(AppRoutes.tillOven);
  }
  if (permissions.contains('reports.branch')) {
    permitted.add(AppRoutes.tillReports);
  }
  return permitted;
}

List<String> getPermittedBackofficeRoutes(List<String> permissions) {
  final permitted = <String>[];
  if (permissions.contains('branches.manage')) {
    permitted.add(AppRoutes.backofficeBranches);
  }
  if (permissions.contains('staff.manage')) {
    permitted.add(AppRoutes.backofficeStaff);
  }
  if (permissions.contains('devices.manage')) {
    permitted.add(AppRoutes.backofficeDevices);
  }
  if (permissions.contains('audit.view')) {
    permitted.add(AppRoutes.backofficeAudit);
  }
  return permitted;
}

typedef TillShellBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  Widget child,
);

typedef TillSectionBuilder = Widget Function(
  BuildContext context,
  String route,
);

typedef BackofficeShellBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  Widget child,
);

typedef BackofficeSectionBuilder = Widget Function(
  BuildContext context,
  String route,
);

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(
  AppMode mode, {
  SecureStorageService? secureStorage,
  Listenable? refreshListenable,
  bool Function()? hasSession,
  List<String> Function()? getPermissions,
  WidgetBuilder? tillLoginBuilder,
  WidgetBuilder? tillHomeBuilder,
  TillShellBuilder? tillShellBuilder,
  TillSectionBuilder? tillSectionBuilder,
  WidgetBuilder? backofficeLoginBuilder,
  BackofficeShellBuilder? backofficeShellBuilder,
  BackofficeSectionBuilder? backofficeSectionBuilder,
}) {
  final initialLocation = mode == AppMode.till
      ? AppRoutes.tillLogin
      : AppRoutes.backofficeLogin;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: (context, state) async {
      if (mode == AppMode.till) {
        final storage =
            secureStorage ??
            SecureStorageService(
              const FlutterSecureStorage(aOptions: AndroidOptions()),
            );
        final token = await storage.getDeviceToken();
        final hasToken = token != null && token.isNotEmpty;
        final isEnrollment = state.matchedLocation == AppRoutes.tillEnrollment;
        final isLogin = state.matchedLocation == AppRoutes.tillLogin;

        if (!hasToken && !isEnrollment) {
          return AppRoutes.tillEnrollment;
        }
        if (hasToken && isEnrollment) {
          return AppRoutes.tillLogin;
        }
        if (hasToken &&
            hasSession != null &&
            !hasSession() &&
            !isLogin &&
            !isEnrollment) {
          return AppRoutes.tillLogin;
        }

        if (hasToken && (hasSession == null || hasSession())) {
          if (getPermissions != null) {
            final permissions = getPermissions();
            final permittedRoutes = getPermittedTillRoutes(permissions);

            if (state.matchedLocation == AppRoutes.tillHome) {
              if (permittedRoutes.isNotEmpty) {
                return permittedRoutes.first;
              }
            } else if (tillSectionRoutes.contains(state.matchedLocation)) {
              if (!permittedRoutes.contains(state.matchedLocation)) {
                return permittedRoutes.isNotEmpty
                    ? permittedRoutes.first
                    : AppRoutes.tillHome;
              }
            }
          }
        }
      }

      if (mode == AppMode.backoffice) {
        final isLogin = state.matchedLocation == AppRoutes.backofficeLogin;
        if (hasSession != null) {
          final sessionActive = hasSession();
          if (!sessionActive && !isLogin) {
            return AppRoutes.backofficeLogin;
          }
          if (sessionActive) {
            final permissions = getPermissions?.call() ?? const [];
            final permittedRoutes = getPermittedBackofficeRoutes(permissions);
            final defaultRoute = permittedRoutes.isNotEmpty
                ? permittedRoutes.first
                : AppRoutes.backofficeDashboard;

            if (isLogin ||
                state.matchedLocation == AppRoutes.backofficeDashboard) {
              return defaultRoute;
            }

            if (backofficeSectionRoutes.contains(state.matchedLocation)) {
              if (!permittedRoutes.contains(state.matchedLocation)) {
                return defaultRoute;
              }
            }
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.tillEnrollment,
        builder: (context, state) {
          final isRevoked = state.uri.queryParameters['revoked'] == 'true';
          return EnrollmentScreen(isRevoked: isRevoked);
        },
      ),
      GoRoute(
        path: AppRoutes.tillLogin,
        builder: (context, state) =>
            tillLoginBuilder?.call(context) ??
            const _RoutePlaceholder(
              titleKey: 'loginEnterPin',
              routeName: 'till-login',
            ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          if (tillShellBuilder != null) {
            return tillShellBuilder(context, state, child);
          }
          if (tillHomeBuilder != null) {
            return tillHomeBuilder(context);
          }
          return child;
        },
        routes: [
          GoRoute(
            path: AppRoutes.tillHome,
            builder: (context, state) =>
                tillSectionBuilder?.call(context, AppRoutes.tillHome) ??
                const SizedBox.shrink(),
          ),
          GoRoute(
            path: AppRoutes.tillSales,
            builder: (context, state) =>
                tillSectionBuilder?.call(context, AppRoutes.tillSales) ??
                const _RoutePlaceholder(
                  titleKey: 'navSales',
                  routeName: 'till-sales',
                ),
          ),
          GoRoute(
            path: AppRoutes.tillCash,
            builder: (context, state) =>
                tillSectionBuilder?.call(context, AppRoutes.tillCash) ??
                const _RoutePlaceholder(
                  titleKey: 'navCash',
                  routeName: 'till-cash',
                ),
          ),
          GoRoute(
            path: AppRoutes.tillProduction,
            builder: (context, state) =>
                tillSectionBuilder?.call(context, AppRoutes.tillProduction) ??
                const _RoutePlaceholder(
                  titleKey: 'navProduction',
                  routeName: 'till-production',
                ),
          ),
          GoRoute(
            path: AppRoutes.tillOrders,
            builder: (context, state) =>
                tillSectionBuilder?.call(context, AppRoutes.tillOrders) ??
                const _RoutePlaceholder(
                  titleKey: 'navOrders',
                  routeName: 'till-orders',
                ),
          ),
          GoRoute(
            path: AppRoutes.tillOven,
            builder: (context, state) =>
                tillSectionBuilder?.call(context, AppRoutes.tillOven) ??
                const _RoutePlaceholder(
                  titleKey: 'navOven',
                  routeName: 'till-oven',
                ),
          ),
          GoRoute(
            path: AppRoutes.tillReports,
            builder: (context, state) =>
                tillSectionBuilder?.call(context, AppRoutes.tillReports) ??
                const _RoutePlaceholder(
                  titleKey: 'navReports',
                  routeName: 'till-reports',
                ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.backofficeLogin,
        builder: (context, state) =>
            backofficeLoginBuilder?.call(context) ??
            const _RoutePlaceholder(
              titleKey: 'backofficeLoginTitle',
              routeName: 'backoffice-login',
            ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          if (backofficeShellBuilder != null) {
            return backofficeShellBuilder(context, state, child);
          }
          return BackofficeShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.backofficeDashboard,
            builder: (context, state) =>
                backofficeSectionBuilder?.call(
                  context,
                  AppRoutes.backofficeDashboard,
                ) ??
                const SizedBox.shrink(),
          ),
          GoRoute(
            path: AppRoutes.backofficeBranches,
            builder: (context, state) =>
                backofficeSectionBuilder?.call(
                  context,
                  AppRoutes.backofficeBranches,
                ) ??
                const BranchesScreen(),
          ),
          GoRoute(
            path: AppRoutes.backofficeStaff,
            builder: (context, state) =>
                backofficeSectionBuilder?.call(
                  context,
                  AppRoutes.backofficeStaff,
                ) ??
                BackofficeSectionPlaceholder.forRoute(
                  AppRoutes.backofficeStaff,
                ),
          ),
          GoRoute(
            path: AppRoutes.backofficeDevices,
            builder: (context, state) =>
                backofficeSectionBuilder?.call(
                  context,
                  AppRoutes.backofficeDevices,
                ) ??
                BackofficeSectionPlaceholder.forRoute(
                  AppRoutes.backofficeDevices,
                ),
          ),
          GoRoute(
            path: AppRoutes.backofficeAudit,
            builder: (context, state) =>
                backofficeSectionBuilder?.call(
                  context,
                  AppRoutes.backofficeAudit,
                ) ??
                BackofficeSectionPlaceholder.forRoute(
                  AppRoutes.backofficeAudit,
                ),
          ),
        ],
      ),
    ],
  );
}

class _RoutePlaceholder extends StatelessWidget {
  const _RoutePlaceholder({required this.titleKey, required this.routeName});

  final String titleKey;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              routeName,
              key: const Key('mode-label'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
