import 'package:bakery_pos/core/api/generated/models/device.dart';
import 'package:bakery_pos/core/api/generated/models/device_create.dart';
import 'package:bakery_pos/core/api/generated/models/device_enrollment.dart';
import 'package:bakery_pos/core/api/generated/models/device_status.dart';
import 'package:bakery_pos/core/api/generated/models/device_type.dart';
import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/features/branches/data/branches_service.dart';
import 'package:bakery_pos/features/devices/data/devices_admin_service.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String deviceTypeLabel(DeviceType type, AppLocalizations l10n) =>
    type == DeviceType.production
    ? l10n.deviceTypeProduction
    : l10n.deviceTypeTill;

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  String? _branchId;
  bool _showRevoked = false;

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _newCode(Device d) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await confirmAdminAction(
      context,
      title: l10n.deviceNewCodeTitle(d.name),
      message: l10n.deviceNewCodeMessage,
      confirmLabel: l10n.deviceNewCode,
    );
    if (!ok || !mounted) return;
    try {
      final enrollment = await ref
          .read(devicesAdminProvider.notifier)
          .newCode(d.id);
      if (mounted) await showEnrollmentCode(context, enrollment);
    } catch (e) {
      _snack(commonAdminError(l10n, e));
    }
  }

  Future<void> _revoke(Device d) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await confirmAdminAction(
      context,
      title: l10n.deviceRevokeTitle(d.name),
      message: l10n.deviceRevokeMessage,
      confirmLabel: l10n.deviceRevoke,
    );
    if (!ok) return;
    try {
      await ref.read(devicesAdminProvider.notifier).revoke(d.id);
      _snack(l10n.deviceRevoked);
    } catch (e) {
      _snack(commonAdminError(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final devicesState = ref.watch(devicesAdminProvider);
    final branches = ref.watch(branchesServiceProvider).value ?? const [];
    final branchNames = {for (final b in branches) b.id: b.name};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.devicesTitle),
        actions: [
          IconButton(
            key: const Key('refresh-devices-button'),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.commonRefresh,
            onPressed: () => ref.read(devicesAdminProvider.notifier).refresh(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
            child: ElevatedButton.icon(
              key: const Key('create-device-button'),
              icon: const Icon(Icons.add),
              label: Text(l10n.deviceNew),
              onPressed: () async {
                final enrollment = await showDialog<DeviceEnrollment>(
                  context: context,
                  builder: (_) => const DeviceCreateDialog(),
                );
                if (enrollment != null && context.mounted) {
                  await showEnrollmentCode(context, enrollment);
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Wrap(
              spacing: AppDimensions.paddingMedium,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String?>(
                    key: const Key('devices-branch-filter'),
                    initialValue: _branchId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.staffBranch),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.allBranches),
                      ),
                      for (final b in branches)
                        DropdownMenuItem(value: b.id, child: Text(b.name)),
                    ],
                    onChanged: (v) => setState(() => _branchId = v),
                  ),
                ),
                FilterChip(
                  key: const Key('devices-show-revoked'),
                  label: Text(l10n.deviceShowRevoked),
                  selected: _showRevoked,
                  onSelected: (v) => setState(() => _showRevoked = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: devicesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.devicesErrorLoading,
                      style: const TextStyle(color: AppColors.alertRed),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(devicesAdminProvider.notifier).refresh(),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
              data: (all) {
                final rows =
                    all
                        .where(
                          (d) =>
                              _showRevoked || d.status != DeviceStatus.revoked,
                        )
                        .where(
                          (d) => _branchId == null || d.branchId == _branchId,
                        )
                        .toList()
                      ..sort((a, b) => a.name.compareTo(b.name));
                if (rows.isEmpty) return Center(child: Text(l10n.devicesEmpty));
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                  ),
                  child: Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        key: const Key('devices-table'),
                        columns: [
                          DataColumn(label: Text(l10n.deviceName)),
                          DataColumn(label: Text(l10n.staffBranch)),
                          DataColumn(label: Text(l10n.deviceType)),
                          DataColumn(label: Text(l10n.branchesStatus)),
                          DataColumn(label: Text(l10n.deviceLastSeen)),
                          const DataColumn(label: SizedBox.shrink()),
                        ],
                        rows: [
                          for (final d in rows)
                            DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    d.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataCell(Text(branchNames[d.branchId] ?? '—')),
                                DataCell(Text(deviceTypeLabel(d.type, l10n))),
                                DataCell(_statusChip(d.status, l10n)),
                                DataCell(
                                  Text(
                                    d.lastSeenAt == null
                                        ? '—'
                                        : formatAdminDateTime(d.lastSeenAt!),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (d.status == DeviceStatus.pending)
                                        TextButton(
                                          key: Key('new-code-${d.id}'),
                                          onPressed: () => _newCode(d),
                                          child: Text(l10n.deviceNewCode),
                                        ),
                                      if (d.status != DeviceStatus.revoked)
                                        TextButton(
                                          key: Key('revoke-${d.id}'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColors.alertRed,
                                          ),
                                          onPressed: () => _revoke(d),
                                          child: Text(l10n.deviceRevoke),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(DeviceStatus status, AppLocalizations l10n) {
    switch (status) {
      case DeviceStatus.active:
        return AdminStatusChip(
          label: l10n.deviceStatusActive,
          color: AppColors.successGreenBg,
        );
      case DeviceStatus.pending:
        return AdminStatusChip(
          label: l10n.deviceStatusPending,
          color: AppColors.amberGlow,
        );
      default:
        return AdminStatusChip(
          label: l10n.deviceStatusRevoked,
          color: AppColors.surfaceHighlight,
        );
    }
  }
}

class DeviceCreateDialog extends ConsumerStatefulWidget {
  const DeviceCreateDialog({super.key});

  @override
  ConsumerState<DeviceCreateDialog> createState() => _DeviceCreateDialogState();
}

class _DeviceCreateDialogState extends ConsumerState<DeviceCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  String? _branchId;
  DeviceType _type = DeviceType.till;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final enrollment = await ref
          .read(devicesAdminProvider.notifier)
          .create(
            DeviceCreate(
              branchId: _branchId!,
              name: _name.text.trim(),
              type: _type,
            ),
          );
      if (mounted) Navigator.of(context).pop(enrollment);
    } catch (e) {
      if (mounted) {
        setState(() {
          // The server answers 400 for an inactive branch.
          _error = apiErrorCode(e) == 'VALIDATION_FAILED'
              ? l10n.deviceBranchInactive
              : commonAdminError(l10n, e);
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branches = (ref.watch(branchesServiceProvider).value ?? const [])
        .where((b) => b.isActive)
        .toList();
    return AlertDialog(
      title: Text(l10n.deviceNew),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, minWidth: 380),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) AdminErrorBanner(message: _error!),
              DropdownButtonFormField<String>(
                key: const Key('device-branch-input'),
                initialValue: _branchId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.staffBranch),
                items: [
                  for (final b in branches)
                    DropdownMenuItem(value: b.id, child: Text(b.name)),
                ],
                validator: (v) => v == null ? l10n.deviceBranchRequired : null,
                onChanged: (v) => setState(() => _branchId = v),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              TextFormField(
                key: const Key('device-name-input'),
                controller: _name,
                decoration: InputDecoration(
                  labelText: l10n.deviceName,
                  helperText: l10n.deviceNameHelp,
                ),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  return t.isEmpty || t.length > 60
                      ? l10n.deviceNameInvalid
                      : null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              SegmentedButton<DeviceType>(
                key: const Key('device-type-input'),
                segments: [
                  for (final t in DeviceType.$valuesDefined)
                    ButtonSegment(
                      value: t,
                      label: Text(deviceTypeLabel(t, l10n)),
                    ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('cancel-button'),
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          key: const Key('save-device-button'),
          onPressed: _saving ? null : _save,
          child: Text(l10n.deviceCreateAndGetCode),
        ),
      ],
    );
  }
}

/// Shows an enrollment code once. The code is never stored in the back office.
Future<void> showEnrollmentCode(
  BuildContext context,
  DeviceEnrollment enrollment,
) {
  final l10n = AppLocalizations.of(context)!;
  final code = enrollment.enrollmentCode;
  final pretty = '${code.substring(0, 4)} ${code.substring(4)}';
  final expires = formatAdminTime(enrollment.expiresAt);
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(l10n.deviceCodeTitle(enrollment.device.name)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              pretty,
              key: const Key('enrollment-code'),
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
                color: AppColors.primaryAmber,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              l10n.deviceCodeInstructions(expires),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          key: const Key('copy-code-button'),
          icon: const Icon(Icons.copy),
          label: Text(l10n.deviceCopyCode),
          onPressed: () => Clipboard.setData(ClipboardData(text: code)),
        ),
        ElevatedButton(
          key: const Key('code-done-button'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.deviceCodeDone),
        ),
      ],
    ),
  );
}
