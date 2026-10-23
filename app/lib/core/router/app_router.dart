import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
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
}

const tillSectionRoutes = [
  AppRoutes.tillSales,
  AppRoutes.tillCash,
  AppRoutes.tillProduction,
  AppRoutes.tillOrders,
  AppRoutes.tillOven,
  AppRoutes.tillReports,
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

typedef TillShellBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  Widget child,
);

typedef TillSectionBuilder = Widget Function(
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
        builder: (context, state) => const _RoutePlaceholder(
          titleKey: 'backofficeLoginTitle',
          routeName: 'backoffice-login',
        ),
      ),
      GoRoute(
        path: AppRoutes.backofficeDashboard,
        builder: (context, state) => const _RoutePlaceholder(
          titleKey: 'appTitle',
          routeName: 'backoffice-dashboard',
        ),
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
