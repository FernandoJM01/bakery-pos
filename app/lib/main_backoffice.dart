import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'features/backoffice/auth/data/backoffice_auth_service.dart';
import 'features/backoffice/auth/presentation/backoffice_login_screen.dart';
import 'features/backoffice/shell/presentation/backoffice_shell.dart';
import 'features/audit/presentation/audit_screen.dart';
import 'features/branches/presentation/branches_screen.dart';
import 'features/catalog/presentation/catalog_screen.dart';
import 'features/devices/presentation/devices_screen.dart';
import 'features/staff/presentation/staff_screen.dart';
import 'features/day_old_rules/presentation/day_old_rules_screen.dart';
import 'features/orders_admin/presentation/orders_admin_screen.dart';
import 'features/reports/presentation/reports_screen.dart';
import 'features/sales_admin/presentation/sales_admin_screen.dart';
import 'features/shifts_admin/presentation/shifts_admin_screen.dart';
import 'features/stock_admin/presentation/stock_admin_screen.dart';
import 'features/sync_admin/presentation/sync_admin_screen.dart';

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
        if (route == AppRoutes.backofficeCatalog) {
          return const CatalogScreen();
        }
        if (route == AppRoutes.backofficeAudit) {
          return const AuditScreen();
        }
        if (route == AppRoutes.backofficeSync) {
          return const SyncAdminScreen();
        }
        if (route == AppRoutes.backofficeSales) {
          return const SalesAdminScreen();
        }
        if (route == AppRoutes.backofficeShifts) {
          return const ShiftsAdminScreen();
        }
        if (route == AppRoutes.backofficeReports) {
          return const ReportsScreen();
        }
        if (route == AppRoutes.backofficeOrders) {
          return const OrdersAdminScreen();
        }
        if (route == AppRoutes.backofficeDayOld) {
          return const DayOldRulesScreen();
        }
        if (route == AppRoutes.backofficeStock) {
          return const StockAdminScreen();
        }
        return BackofficeSectionPlaceholder.forRoute(route);
      },
    );
  }
}
