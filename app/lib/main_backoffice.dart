import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'features/backoffice/auth/data/backoffice_auth_service.dart';
import 'features/backoffice/auth/presentation/backoffice_login_screen.dart';
import 'features/backoffice/shell/presentation/backoffice_shell.dart';
import 'features/branches/presentation/branches_screen.dart';

void main() => runApp(const ProviderScope(child: BackofficeAppRoot()));

class BackofficeAppRoot extends ConsumerWidget {
  const BackofficeAppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(backofficeAuthServiceProvider);
    return BakeryPosApp(
      mode: AppMode.backoffice,
      refreshListenable: authService,
      hasSession: () => authService.isAuthenticated,
      getPermissions: () => authService.currentSession?.permissions ?? const [],
      backofficeLoginBuilder: (context) => const BackofficeLoginScreen(),
      backofficeShellBuilder: (context, state, child) =>
          BackofficeShell(child: child),
      backofficeSectionBuilder: (context, route) {
        if (route == AppRoutes.backofficeBranches) {
          return const BranchesScreen();
        }
        return BackofficeSectionPlaceholder.forRoute(route);
      },
    );
  }
}
