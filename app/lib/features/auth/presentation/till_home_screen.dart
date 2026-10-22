import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../staff/data/staff_sync_service.dart';
import '../data/till_auth_service.dart';
import '../domain/session_lock_manager.dart';

class TillHomeScreen extends ConsumerWidget {
  const TillHomeScreen({super.key, this.routeName = 'till-home'});

  final String routeName;

  Future<void> _handleSync(BuildContext context, WidgetRef ref) async {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(tillSessionProvider);
    final l10n = AppLocalizations.of(context)!;
    final isOffline = session?.isOffline ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            key: const Key('home-sync-button'),
            icon: const Icon(Icons.sync_rounded),
            tooltip: l10n.commonRetry,
            onPressed: () => _handleSync(context, ref),
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
                    final normalizedRoute = routeName.startsWith('/')
                        ? routeName
                        : '/$routeName';
                    ref
                        .read(sessionLockManagerProvider)
                        .lockCurrentSession(currentRoute: normalizedRoute);
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
              onTap: () => _handleSync(context, ref),
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
