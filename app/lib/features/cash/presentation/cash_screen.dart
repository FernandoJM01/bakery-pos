import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/till_auth_service.dart';
import '../../printing/data/printer_service.dart';
import '../../printing/domain/documents.dart';
import '../../sale/domain/ticket.dart';
import '../../sale/presentation/discount_dialog.dart';
import '../data/shift_repository.dart';
import '../domain/cash_totals.dart';
import 'count_form.dart';
import 'movement_dialog.dart';
import 'printer_dialog.dart';
import 'z_report_dialog.dart';

/// Caja (M4 brief 5): opens the shift, moves cash, closes blind, and keeps
/// the Z reports of the shifts this till holds.
class CashScreen extends ConsumerWidget {
  const CashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final shift = ref.watch(currentShiftProvider);
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.navCash,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            TextButton.icon(
              key: const Key('printer-open'),
              icon: const Icon(Icons.print_outlined),
              label: Text(l10n.printerTitle),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const PrinterDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        shift.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Text(l10n.cashLoadFailed),
          data: (s) {
            if (s == null) return const _OpenShift();
            if (s.status == 'COUNTED') return _NoteNeeded(shift: s);
            return _OpenPanel(shift: s);
          },
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        const _PastShifts(),
      ],
    );
  }
}

class _OpenShift extends ConsumerStatefulWidget {
  const _OpenShift();

  @override
  ConsumerState<_OpenShift> createState() => _OpenShiftState();
}

class _OpenShiftState extends ConsumerState<_OpenShift> {
  bool _busy = false;

  Future<void> _open(Map<int, int> count) async {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.read(tillSessionProvider);
    if (session == null) return;
    final repo = ref.read(shiftRepositoryProvider);
    setState(() => _busy = true);
    final last = await repo.lastCountedCents();
    final differs = last != null && last != countTotal(count);
    await repo.open(
      staff: session.staff,
      count: count,
      now: ref.read(saleClockProvider)(),
    );
    ref.invalidate(currentShiftProvider);
    if (!mounted) return;
    setState(() => _busy = false);
    if (differs) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cashFloatDiffers(formatCents(last)))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.cashOpenHint,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            CountForm(
              key: const Key('open-count'),
              submitLabel: l10n.cashOpen,
              busy: _busy,
              onSubmit: _open,
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenPanel extends ConsumerWidget {
  const _OpenPanel({required this.shift});

  final LocalShift shift;

  Future<void> _move(BuildContext context, CashKind kind) => showDialog<void>(
    context: context,
    builder: (_) => MovementDialog(shift: shift, kind: kind),
  );

  Future<void> _drawer(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final session = ref.read(tillSessionProvider);
    if (session == null) return;
    String? approver;
    if (!session.hasPermission('cash.open_drawer_no_sale')) {
      final result = await ref.read(approvalRequesterProvider)(
        context,
        action: 'cash.open_drawer_no_sale',
      );
      if (result == null) return;
      approver = approverOf(result);
    }
    await ref
        .read(tillDatabaseProvider)
        .recordDrawerOpened(
          staffId: session.staff.id,
          approverStaffId: approver,
          at: ref.read(saleClockProvider)().toUtc(),
        );
    final ok = await ref.read(printerServiceProvider).kickDrawer();
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.printFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.cashShiftOpen(
                formatPrintDate(shift.openedAt),
                shift.openedByName,
              ),
              key: const Key('shift-open'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(l10n.cashFloatLine(formatCents(shift.floatCents))),
            const SizedBox(height: AppDimensions.paddingMedium),
            Wrap(
              spacing: AppDimensions.paddingSmall,
              runSpacing: AppDimensions.paddingSmall,
              children: [
                OutlinedButton.icon(
                  key: const Key('cash-in'),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.cashIn),
                  onPressed: () => _move(context, CashKind.cashIn),
                ),
                OutlinedButton.icon(
                  key: const Key('cash-out'),
                  icon: const Icon(Icons.remove),
                  label: Text(l10n.cashOut),
                  onPressed: () => _move(context, CashKind.cashOut),
                ),
                OutlinedButton.icon(
                  key: const Key('cash-drawer'),
                  icon: const Icon(Icons.point_of_sale),
                  label: Text(l10n.cashOpenDrawer),
                  onPressed: () => _drawer(context, ref),
                ),
                FilledButton.icon(
                  key: const Key('cash-close'),
                  icon: const Icon(Icons.lock_outline),
                  label: Text(l10n.cashClose),
                  onPressed: () => showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => BlindCloseDialog(shift: shift),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The blind close (M4.3). The expected amount appears only after the count
/// is confirmed; nothing before that step reads it.
class BlindCloseDialog extends ConsumerStatefulWidget {
  const BlindCloseDialog({super.key, required this.shift});

  final LocalShift shift;

  @override
  ConsumerState<BlindCloseDialog> createState() => _BlindCloseDialogState();
}

class _BlindCloseDialogState extends ConsumerState<BlindCloseDialog> {
  bool _busy = false;
  LocalShift? _result;

  Future<void> _confirm(Map<int, int> count) async {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.read(tillSessionProvider);
    if (session == null) return;
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cashConfirmTitle),
        content: Text(l10n.cashConfirmBody(formatCents(countTotal(count)))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const Key('close-confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    setState(() => _busy = true);
    final done = await ref
        .read(shiftRepositoryProvider)
        .confirmCount(
          shift: widget.shift,
          staff: session.staff,
          count: count,
          now: ref.read(saleClockProvider)(),
        );
    ref
      ..invalidate(currentShiftProvider)
      ..invalidate(closedShiftsProvider);
    if (mounted) setState(() => _result = done);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = _result;
    return AlertDialog(
      title: Text(l10n.cashClose),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: result == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.cashBlindHint),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    CountForm(
                      key: const Key('close-count'),
                      submitLabel: l10n.cashConfirmCount,
                      busy: _busy,
                      onSubmit: _confirm,
                    ),
                  ],
                )
              : _CloseResult(shift: result),
        ),
      ),
      actions: [
        if (result == null)
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          )
        else if (result.status == 'CLOSED')
          FilledButton(
            key: const Key('close-see-z'),
            onPressed: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              showDialog<void>(
                context: navigator.context,
                builder: (_) => ZReportDialog(shift: result),
              );
            },
            child: Text(l10n.cashSeeZ),
          )
        else
          TextButton(
            key: const Key('close-to-note'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonClose),
          ),
      ],
    );
  }
}

class _CloseResult extends StatelessWidget {
  const _CloseResult({required this.shift});

  final LocalShift shift;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    Widget row(String label, int cents, Key key) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
          Text(
            formatCents(cents),
            key: key,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row(
          l10n.cashExpected,
          shift.expectedCents!,
          const Key('close-expected'),
        ),
        row(l10n.cashCounted, shift.countedCents!, const Key('close-counted')),
        row(
          l10n.cashDifference,
          shift.varianceCents!,
          const Key('close-difference'),
        ),
        if (shift.flagged) ...[
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            l10n.cashFlagged,
            key: const Key('close-flagged'),
            style: const TextStyle(color: AppColors.alertRed),
          ),
        ],
      ],
    );
  }
}

/// A flagged close waits here for its note, even after an app restart.
class _NoteNeeded extends ConsumerStatefulWidget {
  const _NoteNeeded({required this.shift});

  final LocalShift shift;

  @override
  ConsumerState<_NoteNeeded> createState() => _NoteNeededState();
}

class _NoteNeededState extends ConsumerState<_NoteNeeded> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final note = _note.text.trim();
    if (note.isEmpty) return;
    final repo = ref.read(shiftRepositoryProvider);
    await repo.finishClose(widget.shift.id, note);
    final closed = (await repo.closed(limit: 1)).single;
    if (!mounted) return;
    // Shown from the root: this panel leaves once the shift is closed.
    final navigator = Navigator.of(context, rootNavigator: true);
    ref
      ..invalidate(currentShiftProvider)
      ..invalidate(closedShiftsProvider);
    await showDialog<void>(
      context: navigator.context,
      builder: (_) => ZReportDialog(shift: closed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CloseResult(shift: widget.shift),
            const SizedBox(height: AppDimensions.paddingMedium),
            TextField(
              key: const Key('close-note'),
              controller: _note,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: l10n.cashNoteForDifference,
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(
              height: AppDimensions.preferredTouchTarget,
              child: FilledButton(
                key: const Key('close-note-save'),
                onPressed: _note.text.trim().isEmpty ? null : _save,
                child: Text(l10n.cashFinishClose),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PastShifts extends ConsumerWidget {
  const _PastShifts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final shifts = ref.watch(closedShiftsProvider).value ?? const [];
    if (shifts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.cashPastShifts,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final s in shifts)
          ListTile(
            key: Key('past-shift-${s.zNumber}'),
            title: Text(l10n.cashPastShift(s.zNumber ?? 0)),
            subtitle: Text(formatPrintDate(s.closedAt!)),
            trailing: Text(formatCents(s.varianceCents ?? 0)),
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => ZReportDialog(shift: s),
            ),
          ),
      ],
    );
  }
}
