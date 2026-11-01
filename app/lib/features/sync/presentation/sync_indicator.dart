import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/sync_worker.dart';

/// Top bar status (M2 brief 4.3): En línea or Sin conexión, records waiting
/// and a warning badge with the quarantined count. Opens the sync sheet.
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final worker = ref.watch(syncWorkerProvider);
    final counts =
        ref.watch(outboxCountsProvider).value ?? (pending: 0, quarantined: 0);
    return ListenableBuilder(
      listenable: worker,
      builder: (context, _) {
        final online = worker.isOnline;
        final color = online ? AppColors.successGreen : AppColors.warningOrange;
        return InkWell(
          key: const Key('sync-indicator'),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          onTap: () => showModalBottomSheet<void>(
            context: context,
            builder: (_) => const SyncSheet(),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppDimensions.preferredTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    online ? Icons.cloud_done_outlined : Icons.cloud_off,
                    color: color,
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall / 2),
                  Text(
                    online ? l10n.syncOnline : l10n.syncOffline,
                    key: const Key('sync-status-label'),
                    style: TextStyle(color: color),
                  ),
                  if (counts.pending > 0) ...[
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Text(
                      l10n.syncWaiting(counts.pending),
                      key: const Key('sync-waiting-label'),
                    ),
                  ],
                  if (counts.quarantined > 0) ...[
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Badge(
                      key: const Key('sync-quarantine-badge'),
                      backgroundColor: AppColors.alertRed,
                      label: Text(counts.quarantined.toString()),
                      child: const Icon(Icons.warning_amber_rounded),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Waiting and quarantined counts with a "Sincronizar ahora" button.
class SyncSheet extends ConsumerStatefulWidget {
  const SyncSheet({super.key});

  @override
  ConsumerState<SyncSheet> createState() => _SyncSheetState();
}

class _SyncSheetState extends ConsumerState<SyncSheet> {
  bool _busy = false;
  bool? _lastOk;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final counts =
        ref.watch(outboxCountsProvider).value ?? (pending: 0, quarantined: 0);
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.syncTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            l10n.syncWaitingCount(counts.pending),
            key: const Key('sync-sheet-waiting'),
          ),
          Text(
            l10n.syncQuarantinedCount(counts.quarantined),
            key: const Key('sync-sheet-quarantined'),
          ),
          if (counts.quarantined > 0) Text(l10n.syncQuarantinedHelp),
          if (_lastOk != null)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
              child: Text(_lastOk! ? l10n.syncDone : l10n.syncFailed),
            ),
          const SizedBox(height: AppDimensions.paddingMedium),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.preferredTouchTarget,
            child: ElevatedButton.icon(
              key: const Key('sync-now-button'),
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(l10n.syncNow),
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      final ok = await ref.read(syncWorkerProvider).syncNow();
                      if (mounted) {
                        setState(() {
                          _busy = false;
                          _lastOk = ok;
                        });
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
