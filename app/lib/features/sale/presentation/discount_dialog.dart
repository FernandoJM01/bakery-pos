import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/till_auth_service.dart';
import '../../auth/domain/approval_models.dart';
import '../../auth/presentation/approval_dialog.dart';
import '../data/sale_repository.dart';
import '../domain/sale_totals.dart';
import '../domain/ticket.dart';

/// Asks a manager to approve an action; tests replace it.
typedef ApprovalRequester = Future<ApprovalResult?> Function(
  BuildContext context, {
  required String action,
  String? reference,
});

final approvalRequesterProvider = Provider<ApprovalRequester>(
  (_) => requestApproval,
);

/// What the discount dialog decided: a discount, or none (removed).
class DiscountChoice {
  const DiscountChoice(this.discount);
  final TicketDiscount? discount;
}

/// `10%` from basis points; `12.5%` when it has decimals.
String formatPercentBp(int bp) {
  final whole = bp ~/ 100;
  final rest = bp % 100;
  if (rest == 0) return '$whole%';
  final dec = rest.toString().padLeft(2, '0').replaceFirst(RegExp(r'0$'), '');
  return '$whole.$dec%';
}

/// Line or ticket discount, as a percentage or an amount, with a reason
/// (M3 brief 2 and 4.2). Above the cashier limit it asks a manager's PIN
/// unless the person selling may give it.
Future<DiscountChoice?> showDiscountDialog(
  BuildContext context, {
  required String title,
  required int baseCents,
  TicketDiscount? current,
}) => showDialog<DiscountChoice>(
  context: context,
  builder: (_) =>
      DiscountDialog(title: title, baseCents: baseCents, current: current),
);

class DiscountDialog extends ConsumerStatefulWidget {
  const DiscountDialog({
    super.key,
    required this.title,
    required this.baseCents,
    this.current,
  });

  final String title;

  /// What the discount applies to: the line's gross, or the ticket after
  /// line discounts.
  final int baseCents;
  final TicketDiscount? current;

  @override
  ConsumerState<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends ConsumerState<DiscountDialog> {
  late DiscountKind _kind = widget.current?.kind ?? DiscountKind.percent;
  late DiscountReason? _reason = widget.current?.reason;
  late final _value = TextEditingController(
    text: widget.current == null ? '' : centsToInput(widget.current!.value),
  );
  late final _note = TextEditingController(text: widget.current?.note ?? '');
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _value.dispose();
    _note.dispose();
    super.dispose();
  }

  /// The value typed: basis points for percent (`10` → 1000), centavos for
  /// amount. Null when it is not a valid discount for this base.
  int? get _parsed {
    final v = parseCents(_value.text);
    if (v == null || v < 1) return null;
    if (_kind == DiscountKind.percent) return v <= 10000 ? v : null;
    return v <= widget.baseCents ? v : null;
  }

  int _cents(int value) => _kind == DiscountKind.percent
      ? (2 * widget.baseCents * value + 10000) ~/ 20000
      : value;

  Future<void> _apply() async {
    final l10n = AppLocalizations.of(context)!;
    final value = _parsed;
    if (value == null) {
      setState(() => _error = l10n.saleDiscountInvalid);
      return;
    }
    if (_reason == null) {
      setState(() => _error = l10n.saleDiscountReasonRequired);
      return;
    }
    final note = _note.text.trim();
    if (_reason == DiscountReason.other && note.isEmpty) {
      setState(() => _error = l10n.saleDiscountNoteRequired);
      return;
    }
    final limit = await ref.read(discountLimitProvider.future);
    final session = ref.read(tillSessionProvider);
    String? approver;
    final over = overLimit(_cents(value), widget.baseCents, limit);
    if (over && session?.hasPermission('sale.discount_over_limit') != true) {
      if (!mounted) return;
      setState(() => _busy = true);
      final result = await ref.read(approvalRequesterProvider)(
        context,
        action: 'sale.discount_over_limit',
      );
      if (!mounted) return;
      setState(() => _busy = false);
      if (result == null) {
        setState(() => _error = l10n.saleDiscountApprovalNeeded);
        return;
      }
      approver = switch (result) {
        OnlineApprovalResult r => r.approverStaffId,
        OfflineApprovalResult r => r.approverStaffId,
      };
    }
    if (!mounted) return;
    Navigator.of(context).pop(
      DiscountChoice(
        TicketDiscount(
          kind: _kind,
          value: value,
          reason: _reason!,
          note: note.isEmpty ? null : note,
          approverStaffId: approver,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final limit =
        ref.watch(discountLimitProvider).value ?? defaultDiscountLimitBp;
    final value = _parsed;
    final cents = value == null ? null : _cents(value);
    final over = cents != null && overLimit(cents, widget.baseCents, limit);
    final reasons = {
      DiscountReason.frequentCustomer: l10n.saleReasonFrequent,
      DiscountReason.damaged: l10n.saleReasonDamaged,
      DiscountReason.promotion: l10n.saleReasonPromotion,
      DiscountReason.other: l10n.saleReasonOther,
    };

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<DiscountKind>(
                key: const Key('discount-kind'),
                segments: [
                  ButtonSegment(
                    value: DiscountKind.percent,
                    label: Text(l10n.saleDiscountPercent),
                  ),
                  ButtonSegment(
                    value: DiscountKind.amount,
                    label: Text(l10n.saleDiscountAmount),
                  ),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => setState(() {
                  _kind = s.first;
                  _error = null;
                }),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              TextField(
                key: const Key('discount-value'),
                controller: _value,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: _kind == DiscountKind.percent
                      ? l10n.saleDiscountValuePercent
                      : l10n.saleDiscountValueAmount,
                ),
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              if (cents != null)
                Text(
                  l10n.saleDiscountPreview(formatCents(cents)),
                  key: const Key('discount-preview'),
                ),
              if (over)
                Text(
                  l10n.saleDiscountOverLimit(formatPercentBp(limit)),
                  key: const Key('discount-over-limit'),
                  style: const TextStyle(color: AppColors.warningOrange),
                ),
              const SizedBox(height: AppDimensions.paddingMedium),
              Text(l10n.saleDiscountReason),
              const SizedBox(height: AppDimensions.paddingSmall),
              Wrap(
                spacing: AppDimensions.paddingSmall,
                runSpacing: AppDimensions.paddingSmall,
                children: [
                  for (final e in reasons.entries)
                    ChoiceChip(
                      key: Key('discount-reason-${e.key.json}'),
                      label: Text(e.value),
                      selected: _reason == e.key,
                      onSelected: (_) => setState(() {
                        _reason = e.key;
                        _error = null;
                      }),
                    ),
                ],
              ),
              if (_reason == DiscountReason.other) ...[
                const SizedBox(height: AppDimensions.paddingSmall),
                TextField(
                  key: const Key('discount-note'),
                  controller: _note,
                  maxLength: 120,
                  decoration: InputDecoration(labelText: l10n.saleDiscountNote),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  _error!,
                  key: const Key('discount-error'),
                  style: const TextStyle(color: AppColors.alertRed),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (widget.current != null)
          TextButton(
            key: const Key('discount-remove'),
            onPressed: _busy
                ? null
                : () => Navigator.of(context).pop(const DiscountChoice(null)),
            child: Text(l10n.saleDiscountRemove),
          ),
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('discount-apply'),
          onPressed: _busy ? null : _apply,
          child: Text(l10n.saleDiscountApply),
        ),
      ],
    );
  }
}
