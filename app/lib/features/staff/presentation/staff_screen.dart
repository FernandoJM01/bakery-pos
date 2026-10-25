import 'package:bakery_pos/core/api/generated/models/role.dart';
import 'package:bakery_pos/core/api/generated/models/staff.dart';
import 'package:bakery_pos/core/api/generated/models/staff_update.dart';
import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/features/branches/data/branches_service.dart';
import 'package:bakery_pos/features/staff/data/staff_admin_service.dart';
import 'package:bakery_pos/features/staff/presentation/staff_form_dialog.dart';
import 'package:bakery_pos/features/staff/presentation/staff_labels.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  String? _branchId;
  Role? _role;
  bool _showInactive = false;

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _setActive(Staff staff, bool active) async {
    final l10n = AppLocalizations.of(context)!;
    if (!active) {
      final ok = await confirmAdminAction(
        context,
        title: l10n.staffDeactivateTitle(staff.displayName),
        message: l10n.staffDeactivateMessage,
        confirmLabel: l10n.staffDeactivate,
      );
      if (!ok) return;
    }
    try {
      await ref
          .read(staffAdminProvider.notifier)
          .updateStaff(staff.id, StaffUpdate(isActive: active));
      _snack(active ? l10n.staffReactivated : l10n.staffDeactivated);
    } catch (e) {
      _snack(staffErrorText(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final staffState = ref.watch(staffAdminProvider);
    final branches = ref.watch(branchesServiceProvider).value ?? const [];
    final branchNames = {for (final b in branches) b.id: b.name};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.staffTitle),
        actions: [
          IconButton(
            key: const Key('refresh-staff-button'),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.commonRefresh,
            onPressed: () => ref.read(staffAdminProvider.notifier).refresh(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
            child: ElevatedButton.icon(
              key: const Key('create-staff-button'),
              icon: const Icon(Icons.person_add_alt),
              label: Text(l10n.staffNew),
              onPressed: () async {
                final created = await showDialog<bool>(
                  context: context,
                  builder: (_) => const StaffFormDialog(),
                );
                if (created == true) _snack(l10n.staffCreated);
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
              runSpacing: AppDimensions.paddingSmall,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String?>(
                    key: const Key('staff-branch-filter'),
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
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<Role?>(
                    key: const Key('staff-role-filter'),
                    initialValue: _role,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.staffRole),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.allRoles)),
                      for (final r in Role.$valuesDefined)
                        DropdownMenuItem(
                          value: r,
                          child: Text(roleLabel(r, l10n)),
                        ),
                    ],
                    onChanged: (v) => setState(() => _role = v),
                  ),
                ),
                FilterChip(
                  key: const Key('staff-show-inactive'),
                  label: Text(l10n.staffShowInactive),
                  selected: _showInactive,
                  onSelected: (v) => setState(() => _showInactive = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: staffState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.staffErrorLoading,
                      style: const TextStyle(color: AppColors.alertRed),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(staffAdminProvider.notifier).refresh(),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
              data: (all) {
                final rows =
                    all
                        .where((s) => _showInactive || s.isActive)
                        .where((s) => _role == null || s.role == _role)
                        .where(
                          (s) =>
                              _branchId == null ||
                              s.branchIds.contains(_branchId),
                        )
                        .toList()
                      ..sort((a, b) => a.fullName.compareTo(b.fullName));
                if (rows.isEmpty) {
                  return Center(child: Text(l10n.staffEmpty));
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                  ),
                  child: Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        key: const Key('staff-table'),
                        columns: [
                          DataColumn(label: Text(l10n.staffFullName)),
                          DataColumn(label: Text(l10n.staffDisplayName)),
                          DataColumn(label: Text(l10n.staffRole)),
                          DataColumn(label: Text(l10n.staffBranches)),
                          DataColumn(label: Text(l10n.branchesStatus)),
                          const DataColumn(label: SizedBox.shrink()),
                        ],
                        rows: [
                          for (final s in rows) _row(s, branchNames, l10n),
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

  DataRow _row(
    Staff s,
    Map<String, String> branchNames,
    AppLocalizations l10n,
  ) {
    final locked =
        s.lockedUntil != null && s.lockedUntil!.isAfter(DateTime.now());
    return DataRow(
      cells: [
        DataCell(
          Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataCell(Text(s.displayName)),
        DataCell(Text(roleLabel(s.role, l10n))),
        DataCell(
          Text(s.branchIds.map((id) => branchNames[id] ?? '—').join(', ')),
        ),
        DataCell(
          AdminStatusChip(
            label: !s.isActive
                ? l10n.staffInactive
                : locked
                ? l10n.staffLocked
                : l10n.staffActive,
            color: !s.isActive
                ? AppColors.surfaceHighlight
                : locked
                ? AppColors.alertRedBg
                : AppColors.successGreenBg,
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: Key('edit-staff-${s.id}'),
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.staffEdit,
                onPressed: () async {
                  final saved = await showDialog<bool>(
                    context: context,
                    builder: (_) => StaffFormDialog(staff: s),
                  );
                  if (saved == true) _snack(l10n.staffUpdated);
                },
              ),
              IconButton(
                key: Key('pin-staff-${s.id}'),
                icon: const Icon(Icons.pin_outlined),
                tooltip: l10n.staffResetPin,
                onPressed: !s.isActive
                    ? null
                    : () async {
                        final saved = await showDialog<bool>(
                          context: context,
                          builder: (_) => StaffPinDialog(staff: s),
                        );
                        if (saved == true) _snack(l10n.staffPinChanged);
                      },
              ),
              IconButton(
                key: Key('toggle-staff-${s.id}'),
                icon: Icon(
                  s.isActive ? Icons.person_off_outlined : Icons.person_outline,
                ),
                tooltip: s.isActive
                    ? l10n.staffDeactivate
                    : l10n.staffReactivate,
                onPressed: () => _setActive(s, !s.isActive),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
