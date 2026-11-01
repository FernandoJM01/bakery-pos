import 'dart:convert';

import 'package:bakery_pos/core/api/generated/models/device.dart';
import 'package:bakery_pos/core/api/generated/models/quarantine_entry.dart';
import 'package:bakery_pos/core/api/generated/models/status.dart';
import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/features/sync_admin/data/sync_admin_service.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Back office Sincronización (M2 brief 4.3 and 5): records the server
/// quarantined, newest first, and each till's last sync. Owner only, under
/// `settings.manage`.
class SyncAdminScreen extends ConsumerWidget {
  const SyncAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(quarantineFilterProvider);
    final list = ref.watch(quarantineListProvider(filter));
    final devices = ref.watch(syncDevicesProvider);
    final deviceNames = {
      for (final d in devices.value ?? const <Device>[]) d.id: d.name,
    };

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      children: [
        Text(
          l10n.syncAdminDevicesTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        devices.when(
          data: (items) => _DevicesCard(devices: items),
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => AdminErrorBanner(message: commonAdminError(l10n, e)),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        Text(
          l10n.syncAdminQuarantineTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.paddingSmall / 2),
        Text(l10n.syncAdminQuarantineHelp),
        const SizedBox(height: AppDimensions.paddingMedium),
        SegmentedButton<Status>(
          key: const Key('quarantine-filter'),
          segments: [
            ButtonSegment(
              value: Status.open,
              label: Text(l10n.syncAdminFilterOpen),
            ),
            ButtonSegment(
              value: Status.resolved,
              label: Text(l10n.syncAdminFilterResolved),
            ),
            ButtonSegment(
              value: Status.all,
              label: Text(l10n.syncAdminFilterAll),
            ),
          ],
          selected: {filter},
          onSelectionChanged: (s) =>
              ref.read(quarantineFilterProvider.notifier).set(s.first),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        ...list.when(
          data: (page) => [
            if (page.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Text(
                  l10n.syncAdminEmpty,
                  key: const Key('quarantine-empty'),
                  textAlign: TextAlign.center,
                ),
              ),
            for (final e in page.items)
              _QuarantineCard(
                key: Key('quarantine-${e.recordId}'),
                entry: e,
                deviceName: deviceNames[e.deviceId],
                onResolve: () => _resolve(context, ref, filter, e),
              ),
            if (page.nextCursor != null)
              Center(
                child: TextButton(
                  key: const Key('quarantine-load-more'),
                  onPressed: () => ref
                      .read(quarantineListProvider(filter).notifier)
                      .loadMore(),
                  child: Text(l10n.syncAdminLoadMore),
                ),
              ),
          ],
          loading: () => [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingLarge),
                child: CircularProgressIndicator(),
              ),
            ),
          ],
          error: (e, _) => [
            AdminErrorBanner(message: commonAdminError(l10n, e)),
            Center(
              child: TextButton(
                onPressed: () => ref.invalidate(quarantineListProvider(filter)),
                child: Text(l10n.commonRetry),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _resolve(
    BuildContext context,
    WidgetRef ref,
    Status filter,
    QuarantineEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final done = await showDialog<bool>(
      context: context,
      builder: (_) => _ResolveDialog(
        onSubmit: (note) => ref
            .read(quarantineListProvider(filter).notifier)
            .resolve(entry.recordId, note),
      ),
    );
    if (done == true) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.syncAdminResolved)));
    }
  }
}

class _DevicesCard extends StatelessWidget {
  const _DevicesCard({required this.devices});

  final List<Device> devices;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Column(
        children: [
          for (final d in devices)
            ListTile(
              key: Key('sync-device-${d.id}'),
              leading: const Icon(Icons.point_of_sale),
              title: Text(d.name),
              subtitle: Text(
                d.lastSeenAt == null
                    ? l10n.syncAdminDeviceNever
                    : l10n.syncAdminDeviceLastSync(
                        formatAdminDateTime(d.lastSeenAt!),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuarantineCard extends StatelessWidget {
  const _QuarantineCard({
    super.key,
    required this.entry,
    required this.deviceName,
    required this.onResolve,
  });

  final QuarantineEntry entry;
  final String? deviceName;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.alertRed,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Expanded(
                  child: Text(entry.type, style: theme.textTheme.titleMedium),
                ),
                if (entry.resolvedAt == null)
                  OutlinedButton(
                    key: Key('quarantine-resolve-${entry.recordId}'),
                    onPressed: onResolve,
                    child: Text(l10n.syncAdminResolve),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSmall / 2),
            Text(
              l10n.syncAdminEntrySubtitle(
                deviceName ?? l10n.syncAdminUnknownDevice,
                formatAdminDateTime(entry.occurredAt),
                formatAdminDateTime(entry.receivedAt),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall / 2),
            Text(
              l10n.syncAdminErrorLine(entry.errorCode, entry.errorMessage),
              key: Key('quarantine-error-${entry.recordId}'),
              style: const TextStyle(color: AppColors.alertRed),
            ),
            if (entry.resolvedAt != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.paddingSmall / 2,
                ),
                child: Text(
                  l10n.syncAdminResolvedLine(
                    formatAdminDateTime(entry.resolvedAt!),
                    entry.resolutionNote ?? '',
                  ),
                  key: Key('quarantine-resolution-${entry.recordId}'),
                ),
              ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: SelectableText(
                formatPayload(entry.payload),
                key: Key('quarantine-payload-${entry.recordId}'),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The record's payload as indented JSON, for reading.
String formatPayload(Object? payload) =>
    const JsonEncoder.withIndent('  ').convert(payload);

class _ResolveDialog extends StatefulWidget {
  const _ResolveDialog({required this.onSubmit});

  final Future<void> Function(String note) onSubmit;

  @override
  State<_ResolveDialog> createState() => _ResolveDialogState();
}

class _ResolveDialogState extends State<_ResolveDialog> {
  final _note = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final note = _note.text.trim();
    if (note.isEmpty) {
      setState(() => _error = l10n.syncAdminNoteRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSubmit(note);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = apiErrorCode(e) == 'CONFLICT'
            ? l10n.syncAdminAlreadyResolved
            : commonAdminError(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.syncAdminResolveTitle),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) AdminErrorBanner(message: _error!),
            Text(l10n.syncAdminResolveHelp),
            const SizedBox(height: AppDimensions.paddingMedium),
            TextField(
              key: const Key('quarantine-note'),
              controller: _note,
              maxLength: 500,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.syncAdminNote),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          key: const Key('quarantine-note-submit'),
          onPressed: _busy ? null : _submit,
          child: Text(l10n.syncAdminResolve),
        ),
      ],
    );
  }
}
