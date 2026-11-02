import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/generated/models/cash_movement.dart';
import 'package:bakery_pos/core/api/generated/models/shift_detail.dart';
import 'package:bakery_pos/core/api/generated/models/shift_summary.dart';
import 'package:bakery_pos/core/api/generated/models/v1_shifts_shift_id_notes_request_body.dart';
import 'package:bakery_pos/core/api/generated/models/z_report.dart' as api;
import 'package:bakery_pos/core/money/money.dart';
import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/features/branches/data/branches_service.dart';
import 'package:bakery_pos/features/cash/domain/z_report.dart';
import 'package:bakery_pos/features/printing/domain/z_document.dart';
import 'package:bakery_pos/features/printing/presentation/document_view.dart';
import 'package:bakery_pos/features/sale/domain/sale_totals.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

ZReport _domainZ(api.ZReport z) => ZReport(
  saleCount: z.saleCount,
  grossCents: z.grossCents,
  discountCents: z.discountCents,
  netCents: z.netCents,
  taxes: [
    for (final t in z.taxes)
      TaxByRate(t.kind.json ?? t.kind.name, t.rateBp)
        ..baseCents = t.baseCents
        ..taxCents = t.taxCents,
  ],
  refundCount: z.refundCount,
  refundCents: z.refundCents,
  voidCount: z.voidCount,
  voidCents: z.voidCents,
  prepaidCollectedCents: z.prepaidCollectedCents,
  cashInCents: z.cashInCents,
  cashOutCents: z.cashOutCents,
  movements: [
    for (final m in z.movements)
      ZMovement(
        kind: m.kind.json ?? m.kind.name,
        reason: m.reason.json ?? m.reason.name,
        amountCents: m.amountCents,
      ),
  ],
);

/// Back office Turnos (M4 brief 5, E13): shifts with expected, counted and
/// the difference, and each shift's counts, movements and Z report. The
/// owner sees every branch; a manager only their own, enforced by the server.
class ShiftsAdminScreen extends ConsumerStatefulWidget {
  const ShiftsAdminScreen({super.key});

  @override
  ConsumerState<ShiftsAdminScreen> createState() => _ShiftsAdminScreenState();
}

class _ShiftsAdminScreenState extends ConsumerState<ShiftsAdminScreen> {
  static const _pageSize = 50;

  String? _branchId;
  DateTimeRange? _range;
  bool _flaggedOnly = false;

  final List<ShiftSummary> _items = [];
  String? _nextCursor;
  bool _loading = true;
  String? _error;

  /// A response for an older filter is dropped, not mixed in.
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
          .shifts
          .listShifts(
            limit: _pageSize,
            branchId: _branchId,
            flagged: _flaggedOnly ? true : null,
            from: _range?.start.toUtc(),
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
        setState(() {
          if (reset) _items.clear();
          _nextCursor = null;
          _error = apiErrorCode(e) == 'PERMISSION_DENIED'
              ? l10n.shiftsForbidden
              : commonAdminError(l10n, e);
        });
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

  String _money(int? cents) => cents == null ? '—' : formatCents(cents);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branches = ref.watch(branchesServiceProvider).value ?? const [];
    final branchNames = {for (final b in branches) b.id: b.name};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navShifts),
        actions: [
          IconButton(
            key: const Key('refresh-shifts-button'),
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
                OutlinedButton.icon(
                  key: const Key('shifts-date-filter'),
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _range == null
                        ? l10n.shiftsAllDates
                        : '${formatAdminDateTime(_range!.start).split(' ').first}'
                              ' – '
                              '${formatAdminDateTime(_range!.end).split(' ').first}',
                  ),
                  onPressed: _pickRange,
                ),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String?>(
                    key: const Key('shifts-branch-filter'),
                    isExpanded: true,
                    initialValue: _branchId,
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
                FilterChip(
                  key: const Key('shifts-flagged-filter'),
                  label: Text(l10n.shiftsFlaggedOnly),
                  selected: _flaggedOnly,
                  onSelected: (v) => _setFilter(() => _flaggedOnly = v),
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
                        : Text(
                            l10n.shiftsEmpty,
                            key: const Key('shifts-empty'),
                          ),
                  )
                : ListView(
                    key: const Key('shifts-list'),
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    children: [
                      Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            showCheckboxColumn: false,
                            columns: [
                              DataColumn(label: Text(l10n.shiftsColZ)),
                              DataColumn(label: Text(l10n.shiftsColOpened)),
                              DataColumn(label: Text(l10n.staffBranch)),
                              DataColumn(label: Text(l10n.shiftsColCashier)),
                              DataColumn(
                                label: Text(l10n.cashExpected),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text(l10n.cashCounted),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text(l10n.cashDifference),
                                numeric: true,
                              ),
                            ],
                            rows: [
                              for (final s in _items)
                                DataRow(
                                  key: ValueKey('shift-${s.id}'),
                                  onSelectChanged: (_) => showDialog<void>(
                                    context: context,
                                    builder: (_) => ShiftDetailDialog(
                                      shiftId: s.id,
                                      branch: branchNames[s.branchId],
                                    ),
                                  ),
                                  cells: [
                                    DataCell(
                                      Text(s.zLabel ?? l10n.shiftsOpenStatus),
                                    ),
                                    DataCell(
                                      Text(formatAdminDateTime(s.openedAt)),
                                    ),
                                    DataCell(
                                      Text(branchNames[s.branchId] ?? '—'),
                                    ),
                                    DataCell(Text(s.openedByName)),
                                    DataCell(Text(_money(s.expectedCents))),
                                    DataCell(Text(_money(s.countedCents))),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (s.flagged)
                                            Icon(
                                              Icons.flag,
                                              key: Key('shift-flag-${s.id}'),
                                              size: 18,
                                              color: AppColors.alertRed,
                                              semanticLabel: l10n.shiftsFlagged,
                                            ),
                                          Text(_money(s.varianceCents)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (_nextCursor != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppDimensions.paddingMedium,
                          ),
                          child: Center(
                            child: TextButton(
                              key: const Key('shifts-load-more'),
                              onPressed: _loading
                                  ? null
                                  : () => _load(reset: false),
                              child: Text(l10n.shiftsLoadMore),
                            ),
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

/// One shift: Z report, movements and notes. Counts never change here; a
/// correction is a note beside them (M4 brief 2).
class ShiftDetailDialog extends ConsumerStatefulWidget {
  const ShiftDetailDialog({super.key, required this.shiftId, this.branch});

  final String shiftId;
  final String? branch;

  @override
  ConsumerState<ShiftDetailDialog> createState() => _ShiftDetailDialogState();
}

class _ShiftDetailDialogState extends ConsumerState<ShiftDetailDialog> {
  late Future<ShiftDetail> _shift = ref
      .read(restClientProvider)
      .shifts
      .getShift(shiftId: widget.shiftId);
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final note = _note.text.trim();
    if (note.isEmpty) return;
    setState(() {
      _shift = ref
          .read(restClientProvider)
          .shifts
          .addShiftNote(
            shiftId: widget.shiftId,
            body: V1ShiftsShiftIdNotesRequestBody(note: note),
          );
      _note.clear();
    });
  }

  Widget _movement(CashMovement m, AppLocalizations l10n) => ListTile(
    dense: true,
    title: Text(cashReasonLabel(l10n, m.reason.json ?? m.reason.name)),
    subtitle: Text(formatAdminDateTime(m.occurredAt)),
    trailing: Text(
      formatCents(m.kind.json == 'OUT' ? -m.amountCents : m.amountCents),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      content: SizedBox(
        width: 560,
        child: FutureBuilder<ShiftDetail>(
          future: _shift,
          builder: (context, snap) {
            if (snap.hasError) {
              return AdminErrorBanner(
                message: commonAdminError(l10n, snap.error!),
              );
            }
            if (!snap.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final s = snap.data!;
            final z = s.zReport;
            return SingleChildScrollView(
              child: Column(
                key: const Key('shift-detail'),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (z != null)
                    DocumentView(
                      lines: zDocument(
                        l10n,
                        ZHeader(
                          zLabel: s.zLabel ?? '',
                          branch: widget.branch,
                          openedAt: s.openedAt,
                          openedBy: s.openedByName,
                          closedAt: s.closedAt ?? s.openedAt,
                          closedBy: s.closedByName ?? '',
                          floatCents: s.floatCents,
                          expectedCents: s.expectedCents ?? 0,
                          countedCents: s.countedCents ?? 0,
                          varianceCents: s.varianceCents ?? 0,
                        ),
                        _domainZ(z),
                      ),
                    ),
                  if (s.movements.isNotEmpty) ...[
                    const Divider(),
                    Text(
                      l10n.shiftsMovements,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    for (final m in s.movements) _movement(m, l10n),
                  ],
                  const Divider(),
                  Text(
                    l10n.shiftsNotes,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  for (final n in s.notes)
                    ListTile(
                      dense: true,
                      title: Text(n.note),
                      subtitle: Text(formatAdminDateTime(n.createdAt)),
                    ),
                  TextField(
                    key: const Key('shift-note'),
                    controller: _note,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: l10n.shiftsAddNote,
                      helperText: l10n.shiftsNoteHint,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          key: const Key('shift-note-save'),
          onPressed: _save,
          child: Text(l10n.shiftsAddNote),
        ),
        TextButton(
          key: const Key('shift-detail-close'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}
