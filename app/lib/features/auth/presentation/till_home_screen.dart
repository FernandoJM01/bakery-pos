import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../staff/data/staff_sync_service.dart';
import '../data/till_auth_service.dart';
import '../domain/session_lock_manager.dart';
import '../domain/till_auth_state.dart';
import 'approval_dialog.dart';

enum TillSection {
  sales(AppRoutes.tillSales),
  cash(AppRoutes.tillCash),
  production(AppRoutes.tillProduction),
  orders(AppRoutes.tillOrders),
  oven(AppRoutes.tillOven),
  reports(AppRoutes.tillReports);

  const TillSection(this.route);
  final String route;
}

class TillSectionConfig {
  const TillSectionConfig({
    required this.section,
    required this.primaryPermission,
    this.secondaryPermission,
    required this.getLabel,
    required this.icon,
  });

  final TillSection section;
  String get route => section.route;
  final String primaryPermission;
  final String? secondaryPermission;
  final String Function(AppLocalizations) getLabel;
  final IconData icon;

  bool isAllowed(TillSession session) {
    if (session.hasPermission(primaryPermission)) return true;
    if (secondaryPermission != null &&
        session.hasPermission(secondaryPermission!)) {
      return true;
    }
    return false;
  }
}

final tillSectionsConfig = [
  TillSectionConfig(
    section: TillSection.sales,
    primaryPermission: 'sale.create',
    getLabel: (l10n) => l10n.navSales,
    icon: Icons.point_of_sale_rounded,
  ),
  TillSectionConfig(
    section: TillSection.cash,
    primaryPermission: 'cash.open_shift',
    getLabel: (l10n) => l10n.navCash,
    icon: Icons.payments_rounded,
  ),
  TillSectionConfig(
    section: TillSection.production,
    primaryPermission: 'stock.production_entry',
    getLabel: (l10n) => l10n.navProduction,
    icon: Icons.bakery_dining_rounded,
  ),
  TillSectionConfig(
    section: TillSection.orders,
    primaryPermission: 'orders.pickup',
    getLabel: (l10n) => l10n.navOrders,
    icon: Icons.receipt_long_rounded,
  ),
  TillSectionConfig(
    section: TillSection.oven,
    primaryPermission: 'oven.intake_pickup',
    secondaryPermission: 'oven.board',
    getLabel: (l10n) => l10n.navOven,
    icon: Icons.local_fire_department_rounded,
  ),
  TillSectionConfig(
    section: TillSection.reports,
    primaryPermission: 'reports.branch',
    getLabel: (l10n) => l10n.navReports,
    icon: Icons.bar_chart_rounded,
  ),
];

class TillHomeScreen extends ConsumerStatefulWidget {
  const TillHomeScreen({super.key, this.child});

  final Widget? child;

  @override
  ConsumerState<TillHomeScreen> createState() => _TillHomeScreenState();
}

class _TillHomeScreenState extends ConsumerState<TillHomeScreen> {
  TillSection? _selectedSection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPermissions();
    });
  }

  Future<void> _loadPermissions() async {
    try {
      await ref.read(tillSessionProvider.notifier).refreshPermissions();
    } catch (_) {}
  }

  Future<void> _handleSync(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.read(tillSessionProvider);

    if (session != null && session.isOffline) {
      final pin = await showDialog<String>(
        context: context,
        builder: (ctx) => const _ReauthPinDialog(),
      );
      if (pin == null || pin.isEmpty) return;

      try {
        await ref.read(tillSessionProvider.notifier).reauthenticateOnline(pin);
        await ref.read(staffSyncServiceProvider).syncStaffBundle();
        await ref.read(tillSessionProvider.notifier).refreshPermissions();
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.loginSyncSuccess)));
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.loginSyncFailed)));
        }
      }
      return;
    }

    try {
      await ref.read(staffSyncServiceProvider).syncStaffBundle();
      await ref.read(tillSessionProvider.notifier).refreshPermissions();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.loginSyncSuccess)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.loginSyncFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(tillSessionProvider);
    final branchName = ref.watch(enrolledBranchNameProvider).asData?.value;
    final l10n = AppLocalizations.of(context)!;
    final isOffline = session?.isOffline ?? false;

    final permittedSections = session == null
        ? <TillSectionConfig>[]
        : tillSectionsConfig.where((s) => s.isAllowed(session)).toList();

    String? currentRoute;
    try {
      currentRoute = GoRouterState.of(context).matchedLocation;
    } catch (_) {}

    final activeConfig = permittedSections
        .cast<TillSectionConfig?>()
        .firstWhere(
          (s) => s != null && s.route == currentRoute,
          orElse: () => null,
        );

    TillSection currentSection;
    if (activeConfig != null) {
      currentSection = activeConfig.section;
    } else if (_selectedSection != null &&
        permittedSections.any((s) => s.section == _selectedSection)) {
      currentSection = _selectedSection!;
    } else if (permittedSections.isNotEmpty) {
      currentSection = permittedSections.first.section;
    } else {
      currentSection = TillSection.sales;
    }

    final selectedIndex = permittedSections.isEmpty
        ? 0
        : permittedSections
              .indexWhere((s) => s.section == currentSection)
              .clamp(0, permittedSections.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle, key: const Key('mode-label')),
        actions: [
          // Branch name
          if (branchName != null && branchName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  branchName,
                  key: const Key('branch-name-label'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Online / Offline Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOffline
                      ? Icons.cloud_off_rounded
                      : Icons.cloud_done_rounded,
                  key: Key(
                    isOffline
                        ? 'status-offline-indicator'
                        : 'status-online-indicator',
                  ),
                  color: isOffline
                      ? AppColors.primaryAmber
                      : AppColors.successGreen,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  isOffline ? l10n.statusOffline : l10n.statusOnline,
                  style: TextStyle(
                    color: isOffline
                        ? AppColors.primaryAmber
                        : AppColors.successGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('home-sync-button'),
            icon: const Icon(Icons.sync_rounded),
            tooltip: l10n.commonRetry,
            onPressed: () => _handleSync(context),
          ),
          IconButton(
            key: const Key('home-settings-button'),
            icon: const Icon(Icons.palette_outlined),
            tooltip: l10n.settingsAppearance,
            onPressed: () => context.go(AppRoutes.tillSettings),
          ),
          if (session != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              child: Center(
                child: InkWell(
                  key: const Key('switch-user-button'),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  onTap: () {
                    final uri = GoRouterState.of(context).uri.toString();
                    ref
                        .read(sessionLockManagerProvider)
                        .lockCurrentSession(currentRoute: uri);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Text(
                      session.staff.displayName,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            key: const Key('home-logout-button'),
            icon: const Icon(Icons.logout_rounded),
            tooltip: l10n.commonLogout,
            onPressed: () async {
              ref.read(sessionLockManagerProvider).clearLockedState();
              await ref.read(tillSessionProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isOffline)
            InkWell(
              key: const Key('login-offline-session-banner'),
              onTap: () => _handleSync(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: AppDimensions.paddingMedium,
                ),
                color: AppColors.surfaceHighlight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.primaryAmber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.loginOfflineSession,
                      style: const TextStyle(
                        color: AppColors.primaryAmber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: permittedSections.isEmpty
                ? Center(
                    child: Text(
                      l10n.placeholderSectionMessage,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : Row(
                    children: [
                      NavigationRail(
                        key: const Key('till-navigation-rail'),
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (index) {
                          final target = permittedSections[index];
                          try {
                            context.go(target.route);
                          } catch (_) {
                            setState(() {
                              _selectedSection = target.section;
                            });
                          }
                        },
                        backgroundColor: AppColors.surfaceCard,
                        selectedIconTheme: const IconThemeData(
                          color: AppColors.primaryAmber,
                        ),
                        unselectedIconTheme: const IconThemeData(
                          color: AppColors.textMuted,
                        ),
                        selectedLabelTextStyle: const TextStyle(
                          color: AppColors.primaryAmber,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelTextStyle: const TextStyle(
                          color: AppColors.textMuted,
                        ),
                        labelType: NavigationRailLabelType.all,
                        destinations: permittedSections.map((config) {
                          return NavigationRailDestination(
                            icon: Icon(
                              config.icon,
                              key: Key('nav-icon-${config.section.name}'),
                            ),
                            selectedIcon: Icon(config.icon),
                            label: Text(config.getLabel(l10n)),
                          );
                        }).toList(),
                      ),
                      const VerticalDivider(
                        thickness: 1,
                        width: 1,
                        color: AppColors.surfaceHighlight,
                      ),
                      Expanded(
                        child:
                            widget.child ??
                            TillSectionPlaceholder(
                              key: Key('section-${currentSection.name}'),
                              section: currentSection,
                            ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class TillSectionPlaceholder extends ConsumerWidget {
  const TillSectionPlaceholder({super.key, required this.section});

  final TillSection section;

  static Widget forRoute(String route) {
    switch (route) {
      case AppRoutes.tillSales:
        return const TillSectionPlaceholder(
          key: Key('section-sales'),
          section: TillSection.sales,
        );
      case AppRoutes.tillCash:
        return const TillSectionPlaceholder(
          key: Key('section-cash'),
          section: TillSection.cash,
        );
      case AppRoutes.tillProduction:
        return const TillSectionPlaceholder(
          key: Key('section-production'),
          section: TillSection.production,
        );
      case AppRoutes.tillOrders:
        return const TillSectionPlaceholder(
          key: Key('section-orders'),
          section: TillSection.orders,
        );
      case AppRoutes.tillOven:
        return const TillSectionPlaceholder(
          key: Key('section-oven'),
          section: TillSection.oven,
        );
      case AppRoutes.tillReports:
        return const TillSectionPlaceholder(
          key: Key('section-reports'),
          section: TillSection.reports,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final config = tillSectionsConfig.firstWhere((s) => s.section == section);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, size: 72, color: AppColors.primaryAmber),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              config.getLabel(l10n),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              l10n.placeholderSectionMessage,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            if (section == TillSection.cash && kDebugMode) ...[
              const SizedBox(height: AppDimensions.paddingLarge),
              ElevatedButton.icon(
                key: const Key('debug-open-drawer-button'),
                icon: const Icon(Icons.lock_open_rounded),
                label: Text(l10n.debugOpenDrawerNoSale),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceHighlight,
                  foregroundColor: AppColors.primaryAmber,
                  minimumSize: const Size(
                    0,
                    AppDimensions.preferredTouchTarget,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                    vertical: AppDimensions.paddingMedium,
                  ),
                ),
                onPressed: () async {
                  final result = await requestApproval(
                    context,
                    action: 'cash.open_drawer_no_sale',
                  );
                  if (result != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.approvalGranted)),
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReauthPinDialog extends StatefulWidget {
  const _ReauthPinDialog();

  @override
  State<_ReauthPinDialog> createState() => _ReauthPinDialogState();
}

class _ReauthPinDialogState extends State<_ReauthPinDialog> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.loginEnterPin),
      content: TextField(
        key: const Key('reauth-pin-field'),
        controller: _pinController,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 6,
        decoration: InputDecoration(hintText: l10n.loginPinHint),
      ),
      actions: [
        TextButton(
          key: const Key('reauth-cancel-button'),
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          key: const Key('reauth-confirm-button'),
          onPressed: () => Navigator.of(context).pop(_pinController.text),
          child: Text(l10n.commonConfirm),
        ),
      ],
    );
  }
}
