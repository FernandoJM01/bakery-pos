import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';

class AppRoutes {
  static const String tillEnrollment = '/enrollment';
  static const String tillLogin = '/login';
  static const String tillHome = '/till';

  static const String backofficeLogin = '/backoffice/login';
  static const String backofficeDashboard = '/backoffice/dashboard';
}

GoRouter createAppRouter(AppMode mode) {
  final initialLocation = mode == AppMode.till
      ? AppRoutes.tillLogin
      : AppRoutes.backofficeLogin;

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.tillEnrollment,
        builder: (context, state) => const _RoutePlaceholder(
          titleKey: 'enrollmentTitle',
          routeName: 'enrollment',
        ),
      ),
      GoRoute(
        path: AppRoutes.tillLogin,
        builder: (context, state) => const _RoutePlaceholder(
          titleKey: 'loginEnterPin',
          routeName: 'till-login',
        ),
      ),
      GoRoute(
        path: AppRoutes.tillHome,
        builder: (context, state) => const _RoutePlaceholder(
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
