import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/till_auth_service.dart';

class TillHomeScreen extends ConsumerWidget {
  const TillHomeScreen({super.key, this.routeName = 'till-home'});

  final String routeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(tillSessionProvider);
    final l10n = AppLocalizations.of(context)!;
    final isOffline = session?.isOffline ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (session != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              child: Center(
                child: Text(
                  session.staff.displayName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (isOffline)
            Container(
              key: const Key('login-offline-session-banner'),
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
          Expanded(
            child: Center(
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
          ),
        ],
      ),
    );
  }
}
