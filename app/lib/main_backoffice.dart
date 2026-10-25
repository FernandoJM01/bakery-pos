import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'features/backoffice/auth/data/backoffice_auth_service.dart';
import 'features/backoffice/auth/presentation/backoffice_login_screen.dart';
import 'features/backoffice/shell/presentation/backoffice_shell.dart';
import 'features/audit/presentation/audit_screen.dart';
import 'features/branches/presentation/branches_screen.dart';
import 'features/devices/presentation/devices_screen.dart';
import 'features/staff/presentation/staff_screen.dart';

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
        if (route == AppRoutes.backofficeStaff) {
          return const StaffScreen();
        }
        if (route == AppRoutes.backofficeDevices) {
          return const DevicesScreen();
        }
        if (route == AppRoutes.backofficeAudit) {
          return const AuditScreen();
        }
        return BackofficeSectionPlaceholder.forRoute(route);
      },
    );
  }
}
