import 'dart:convert';

import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/generated/models/audit_action.dart';
import 'package:bakery_pos/core/api/generated/models/audit_entry.dart';
import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/features/branches/data/branches_service.dart';
import 'package:bakery_pos/features/staff/data/staff_admin_service.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String auditActionLabel(AuditAction action, AppLocalizations l10n) {
  switch (action.json) {
    case 'auth.login_success':
      return l10n.auditLoginSuccess;
    case 'auth.login_failure':
      return l10n.auditLoginFailure;
    case 'auth.locked':
      return l10n.auditLocked;
    case 'auth.logout':
      return l10n.auditLogout;
    case 'auth.approval_granted':
      return l10n.auditApprovalGranted;
    case 'auth.approval_denied':
      return l10n.auditApprovalDenied;
    case 'staff.created':
      return l10n.auditStaffCreated;
    case 'staff.updated':
      return l10n.auditStaffUpdated;
    case 'staff.deactivated':
      return l10n.auditStaffDeactivated;
    case 'staff.pin_changed':
      return l10n.auditStaffPinChanged;
    case 'device.created':
      return l10n.auditDeviceCreated;
    case 'device.activated':
      return l10n.auditDeviceActivated;
    case 'device.revoked':
      return l10n.auditDeviceRevoked;
    case 'branch.created':
      return l10n.auditBranchCreated;
    case 'branch.updated':
      return l10n.auditBranchUpdated;
    default:
      return action.json ?? action.name;
  }
}

class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  static const _pageSize = 50;

  AuditAction? _action;
  String? _branchId;
  String? _staffId;
  DateTimeRange? _range;

  final List<AuditEntry> _items = [];
  String? _nextCursor;
  bool _loading = true;
  String? _error;

  /// Bumped on every request; a response for an older request (a filter
  /// changed or a reload started meanwhile) is dropped instead of mixing
  /// rows from two filters.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
  }

  Future<void> _load({required bool reset}) async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref
          .read(restClientProvider)
          .audit
          .listAuditLog(
            limit: _pageSize,
            action: _action,
            branchId: _branchId,
            staffId: _staffId,
            from: _range?.start.toUtc(),
            // Through the end of the last chosen day.
            to: _range?.end.add(const Duration(days: 1)).toUtc(),
            cursor: reset ? null : _nextCursor,
          );
      if (!mounted || generation != _generation) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(page.items);
        _nextCursor = page.nextCursor;
      });
    } catch (e) {
      if (mounted && generation == _generation) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _error = commonAdminError(l10n, e));
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  void _setFilter(VoidCallback change) {
    setState(change);
    _load(reset: true);
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _range,
    );
    if (picked != null) _setFilter(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branches = ref.watch(branchesServiceProvider).value ?? const [];
    final staff = ref.watch(staffAdminProvider).value ?? const [];
    final branchNames = {for (final b in branches) b.id: b.name};
    final staffNames = {for (final s in staff) s.id: s.displayName};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.auditTitle),
        actions: [
          IconButton(
            key: const Key('refresh-audit-button'),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.commonRefresh,
            onPressed: _loading ? null : () => _load(reset: true),
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
                  width: 260,
                  child: DropdownButtonFormField<AuditAction?>(
                    key: const Key('audit-action-filter'),
                    initialValue: _action,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.auditAction),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.auditAllActions),
                      ),
                      for (final a in AuditAction.$valuesDefined)
                        DropdownMenuItem(
                          value: a,
                          child: Text(auditActionLabel(a, l10n)),
                        ),
                    ],
                    onChanged: (v) => _setFilter(() => _action = v),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String?>(
                    key: const Key('audit-branch-filter'),
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
                    onChanged: (v) => _setFilter(() => _branchId = v),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String?>(
                    key: const Key('audit-staff-filter'),
                    initialValue: _staffId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.auditPerson),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.auditAllPeople),
                      ),
                      for (final s in staff)
                        DropdownMenuItem(
                          value: s.id,
                          child: Text(s.displayName),
                        ),
                    ],
                    onChanged: (v) => _setFilter(() => _staffId = v),
                  ),
                ),
                OutlinedButton.icon(
                  key: const Key('audit-date-filter'),
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _range == null
                        ? l10n.auditAnyDate
                        : '${formatAdminDateTime(_range!.start).split(' ').first} – ${formatAdminDateTime(_range!.end).split(' ').first}',
                  ),
                  onPressed: _pickRange,
                ),
                if (_range != null)
                  IconButton(
                    key: const Key('audit-clear-dates'),
                    icon: const Icon(Icons.clear),
                    tooltip: l10n.auditClearDates,
                    onPressed: () => _setFilter(() => _range = null),
                  ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              child: AdminErrorBanner(message: _error!),
            ),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: _loading
                        ? const CircularProgressIndicator()
                        : Text(l10n.auditEmpty),
                  )
                : ListView.separated(
                    key: const Key('audit-list'),
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    itemCount: _items.length + 1,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      if (i == _items.length) {
                        if (_nextCursor == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingMedium,
                          ),
                          child: Center(
                            child: OutlinedButton(
                              key: const Key('audit-load-more'),
                              onPressed: _loading
                                  ? null
                                  : () => _load(reset: false),
                              child: Text(l10n.auditLoadMore),
                            ),
                          ),
                        );
                      }
                      return _AuditTile(
                        entry: _items[i],
                        branchNames: branchNames,
                        staffNames: staffNames,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({
    required this.entry,
    required this.branchNames,
    required this.staffNames,
  });

  final AuditEntry entry;
  final Map<String, String> branchNames;
  final Map<String, String> staffNames;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final who = entry.actorStaffId == null
        ? l10n.auditSystem
        : staffNames[entry.actorStaffId] ?? l10n.auditUnknownPerson;
    final parts = [
      who,
      if (entry.approverStaffId != null)
        l10n.auditApprovedBy(
          staffNames[entry.approverStaffId] ?? l10n.auditUnknownPerson,
        ),
      if (entry.branchId != null) branchNames[entry.branchId] ?? '—',
    ];
    final details =
        entry.data == null || (entry.data is Map && (entry.data as Map).isEmpty)
        ? null
        : const JsonEncoder.withIndent('  ').convert(entry.data);

    final title = Text(
      auditActionLabel(entry.action, l10n),
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
    final subtitle = Text(
      parts.join(' · '),
      style: const TextStyle(color: AppColors.textMuted),
    );
    final time = Text(formatAdminDateTime(entry.occurredAt));

    if (details == null) {
      return ListTile(title: title, subtitle: subtitle, trailing: time);
    }
    return ExpansionTile(
      key: Key('audit-entry-${entry.id}'),
      title: title,
      subtitle: subtitle,
      trailing: time,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        SelectableText(
          details,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
        ),
      ],
    );
  }
}
