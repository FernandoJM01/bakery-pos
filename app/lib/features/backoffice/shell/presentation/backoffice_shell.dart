import 'package:bakery_pos/core/router/app_router.dart';
import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/auth/data/backoffice_auth_service.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BackofficeShell extends ConsumerWidget {
  const BackofficeShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authService = ref.watch(backofficeAuthServiceProvider);
    final session = authService.currentSession;
    final permissions = session?.permissions ?? const [];

    final navItems = <_NavItem>[];
    if (permissions.contains('branches.manage')) {
      navItems.add(
        _NavItem(
          route: AppRoutes.backofficeBranches,
          label: l10n.navBranches,
          icon: Icons.storefront_outlined,
          selectedIcon: Icons.storefront,
        ),
      );
    }
    if (permissions.contains('catalog.manage')) {
      navItems.add(
        _NavItem(
          route: AppRoutes.backofficeCatalog,
          label: l10n.navCatalog,
          icon: Icons.bakery_dining_outlined,
          selectedIcon: Icons.bakery_dining,
        ),
      );
      navItems.add(
        _NavItem(
          route: AppRoutes.backofficeDayOld,
          label: l10n.navDayOld,
          icon: Icons.history_toggle_off,
          selectedIcon: Icons.history_toggle_off,
        ),
      );
      navItems.add(
        _NavItem(
          route: AppRoutes.backofficeOven,
          label: l10n.navOven,
          icon: Icons.outdoor_grill_outlined,
          selectedIcon: Icons.outdoor_grill,
        ),
      );
    }
    if (permissions.contains('staff.manage')) {
      navItems.add(
        _NavItem(
          route: AppRoutes.backofficeStaff,
          label: l10n.navStaff,
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
        ),
      );
    }
    if (permissions.contains('devices.manage')) {
      navItems.add(
        _NavItem(
          route: AppRoutes.backofficeDevices,
          label: l10n.navDevices,
          icon: Icons.devices_outlined,
          selectedIcon: Icons.devices,
        ),
      );
    }
    if (permissions.contains('audit.view')) {
      navItems.add(
        _NavItem(
          route: AppRoutes.backofficeAudit,
          label: l10n.navAudit,
          icon: Icons.history_outlined,
          selectedIcon: Icons.history,
        ),
      );
    }
    if (permissions.contains('orders.manage')) {
      navItems.add(
        _NavItem(
          route: AppRoutes.backofficeOrders,
          label: l10n.navOrders,
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment,
        ),
      );
    }
    if (permissions.contains('reports.branch')) {
      navItems.add(
        _NavItem(
          route: AppRoutes.backofficeReports,
          label: l10n.navReports,
          icon: Icons.insights_outlined,
          selectedIcon: Icons.insights,
        ),
      );
      navItems.add(
        _NavItem(
          route: AppRoutes.backofficeSales,
          label: l10n.navSales,
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
        ),
      );
      navItems.add(
        _NavItem(
          route: AppRoutes.backofficeShifts,
          label: l10n.navShifts,
          icon: Icons.point_of_sale_outlined,
          selectedIcon: Icons.point_of_sale,
        ),
      );
      navItems.add(
        _NavItem(
          route: AppRoutes.backofficeStock,
          label: l10n.stockInventory,
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
        ),
      );
    }
    if (permissions.contains('settings.manage')) {
      navItems.add(
        _NavItem(
          route: AppRoutes.backofficeSync,
          label: l10n.navSync,
          icon: Icons.sync_problem_outlined,
          selectedIcon: Icons.sync_problem,
        ),
      );
    }

    final currentRoute = GoRouterState.of(context).matchedLocation;
    final selectedIndex = navItems.indexWhere(
      (item) => item.route == currentRoute,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backofficeTitle),
        actions: [
          if (session != null) ...[
            Center(
              child: Text(
                session.staff.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Center(
              child: Chip(
                label: Text(session.staff.role.json ?? session.staff.role.name),
                backgroundColor: AppColors.amberGlow,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            IconButton(
              key: const Key('backoffice-logout-button'),
              icon: const Icon(Icons.logout),
              tooltip: l10n.commonLogout,
              onPressed: () => ref.read(backofficeAuthServiceProvider).logout(),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
          ],
        ],
      ),
      body: Row(
        children: [
          if (navItems.isNotEmpty)
            // The owner has many sections: on a short screen the rail scrolls
            // instead of overflowing.
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      key: const Key('backoffice-nav-rail'),
                      selectedIndex: selectedIndex == -1 ? null : selectedIndex,
                      onDestinationSelected: (index) {
                        final dest = navItems[index];
                        context.go(dest.route);
                      },
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        for (final item in navItems)
                          NavigationRailDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(item.selectedIcon),
                            label: Text(item.label),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: navItems.isEmpty
                ? Center(
                    child: Text(
                      l10n.backofficeNoPermissions,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                : child,
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class BackofficeSectionPlaceholder extends StatelessWidget {
  const BackofficeSectionPlaceholder({super.key, required this.title});

  final String title;

  static Widget forRoute(String route) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        String title;
        if (route == AppRoutes.backofficeStaff) {
          title = l10n.navStaff;
        } else if (route == AppRoutes.backofficeDevices) {
          title = l10n.navDevices;
        } else if (route == AppRoutes.backofficeAudit) {
          title = l10n.navAudit;
        } else if (route == AppRoutes.backofficeCatalog) {
          title = l10n.navCatalog;
        } else if (route == AppRoutes.backofficeSync) {
          title = l10n.navSync;
        } else if (route == AppRoutes.backofficeSales) {
          title = l10n.navSales;
        } else if (route == AppRoutes.backofficeShifts) {
          title = l10n.navShifts;
        } else if (route == AppRoutes.backofficeReports) {
          title = l10n.navReports;
        } else if (route == AppRoutes.backofficeOrders) {
          title = l10n.navOrders;
        } else if (route == AppRoutes.backofficeDayOld) {
          title = l10n.navDayOld;
        } else if (route == AppRoutes.backofficeOven) {
          title = l10n.navOven;
        } else if (route == AppRoutes.backofficeStock) {
          title = l10n.stockInventory;
        } else {
          title = l10n.placeholderSectionTitle;
        }
        return BackofficeSectionPlaceholder(title: title);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.construction_outlined,
              size: 48,
              color: AppColors.primaryAmber,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              l10n.placeholderSectionTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              l10n.placeholderSectionMessage,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
