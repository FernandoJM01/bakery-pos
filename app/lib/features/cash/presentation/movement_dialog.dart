import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/till_auth_service.dart';
import '../../auth/domain/approval_models.dart';
import '../../printing/domain/documents.dart';
import '../../sale/domain/ticket.dart';
import '../../sale/presentation/discount_dialog.dart';
import '../data/shift_repository.dart';
import '../domain/cash_totals.dart';

String? approverOf(ApprovalResult r) => switch (r) {
  OnlineApprovalResult x => x.approverStaffId,
  OfflineApprovalResult x => x.approverStaffId,
};

/// Cash in or out with a reason, and a manager's PIN for a cashier (M4.2).
class MovementDialog extends ConsumerStatefulWidget {
  const MovementDialog({super.key, required this.shift, required this.kind});

  final LocalShift shift;
  final CashKind kind;

  @override
  ConsumerState<MovementDialog> createState() => _MovementDialogState();
}

class _MovementDialogState extends ConsumerState<MovementDialog> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  CashReason? _reason;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = parseCents(_amount.text);
    if (amount == null || amount < 1) {
      setState(() => _error = l10n.cashAmountInvalid);
      return;
    }
    if (_reason == null) {
      setState(() => _error = l10n.cashReasonRequired);
      return;
    }
    final note = _note.text.trim();
    if (_reason == CashReason.other && note.isEmpty) {
      setState(() => _error = l10n.cashNoteRequired);
      return;
    }
    final session = ref.read(tillSessionProvider);
    if (session == null) return;
    setState(() => _busy = true);
    String? approver;
    if (!session.hasPermission('cash.movement')) {
      final result = await ref.read(approvalRequesterProvider)(
        context,
        action: 'cash.movement',
      );
      if (!mounted) return;
      if (result == null) {
        setState(() {
          _busy = false;
          _error = l10n.cashApprovalNeeded;
        });
        return;
      }
      approver = approverOf(result);
    }
    await ref
        .read(shiftRepositoryProvider)
        .addMovement(
          shiftId: widget.shift.id,
          kind: widget.kind,
          amountCents: amount,
          reason: _reason!,
          note: note.isEmpty ? null : note,
          staffId: session.staff.id,
          approverStaffId: approver,
          now: ref.read(saleClockProvider)(),
        );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.kind == CashKind.cashIn ? l10n.cashIn : l10n.cashOut),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('movement-amount'),
                controller: _amount,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l10n.cashAmount),
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              Wrap(
                spacing: AppDimensions.paddingSmall,
                runSpacing: AppDimensions.paddingSmall,
                children: [
                  for (final r in CashReason.values)
                    ChoiceChip(
                      key: Key('movement-reason-${r.json}'),
                      label: Text(cashReasonLabel(l10n, r.json)),
                      selected: _reason == r,
                      onSelected: (_) => setState(() {
                        _reason = r;
                        _error = null;
                      }),
                    ),
                ],
              ),
              if (_reason == CashReason.other) ...[
                const SizedBox(height: AppDimensions.paddingSmall),
                TextField(
                  key: const Key('movement-note'),
                  controller: _note,
                  maxLength: 120,
                  decoration: InputDecoration(labelText: l10n.cashNote),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  _error!,
                  key: const Key('movement-error'),
                  style: const TextStyle(color: AppColors.alertRed),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('movement-save'),
          onPressed: _busy ? null : _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
