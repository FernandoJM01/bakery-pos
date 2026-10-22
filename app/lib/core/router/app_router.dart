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

  static const String backofficeLogin = '/backoffice/login';
  static const String backofficeDashboard = '/backoffice/dashboard';
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(
  AppMode mode, {
  SecureStorageService? secureStorage,
  WidgetBuilder? tillLoginBuilder,
  WidgetBuilder? tillHomeBuilder,
}) {
  final initialLocation = mode == AppMode.till
      ? AppRoutes.tillLogin
      : AppRoutes.backofficeLogin;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
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

        if (!hasToken && !isEnrollment) {
          return AppRoutes.tillEnrollment;
        }
        if (hasToken && isEnrollment) {
          return AppRoutes.tillLogin;
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
      GoRoute(
        path: AppRoutes.tillHome,
        builder: (context, state) =>
            tillHomeBuilder?.call(context) ??
            const _RoutePlaceholder(
              titleKey: 'appTitle',
              routeName: 'till-home',
            ),
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
