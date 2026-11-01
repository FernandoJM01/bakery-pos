import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/till_auth_service.dart';
import '../../auth/domain/approval_models.dart';
import '../data/refund_repository.dart';
import '../domain/ticket.dart';
import 'discount_dialog.dart';

/// **Devolución** or **Cancelar venta** (M3 brief 4.3): find the sale by
/// folio, pick units (a cancel takes every unit left), a reason, then a
/// manager's PIN when the person lacks the permission. Closes with the
/// amount to give back.
Future<RefundResult?> showRefundFlow(BuildContext context, RefundKind kind) =>
    showDialog<RefundResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RefundFlowDialog(kind: kind),
    );

class RefundFlowDialog extends ConsumerStatefulWidget {
  const RefundFlowDialog({super.key, required this.kind});

  final RefundKind kind;

  @override
  ConsumerState<RefundFlowDialog> createState() => _RefundFlowDialogState();
}

class _RefundFlowDialogState extends ConsumerState<RefundFlowDialog> {
  final _folio = TextEditingController();
  final _note = TextEditingController();
  RefundableSale? _sale;
  final _units = <int, int>{};
  final _restock = <int>{};
  RefundReason? _reason;
  String? _error;
  bool _busy = false;

  bool get _isVoid => widget.kind == RefundKind.voidSale;

  @override
  void dispose() {
    _folio.dispose();
    _note.dispose();
    super.dispose();
  }

  String _problem(AppLocalizations l10n, Object e) => switch (e) {
    SaleNotFound() => l10n.refundNotFound,
    TooManyUnits(:final lineNo, :final left) => l10n.refundTooMany(
      lineNo,
      left,
    ),
    VoidNotAllowed(reason: VoidRule.otherTill) => l10n.voidOtherTill,
    VoidNotAllowed(reason: VoidRule.otherDay) => l10n.voidOtherDay,
    VoidNotAllowed(reason: VoidRule.alreadyReturned) =>
      l10n.voidAlreadyReturned,
    VoidNotAllowed(reason: VoidRule.notAllUnits) => l10n.voidAlreadyReturned,
    NothingToRefund() => l10n.refundNothing,
    _ => l10n.salePaymentFailed,
  };

  Future<void> _search() async {
    final l10n = AppLocalizations.of(context)!;
    final folio = _folio.text.trim();
    if (folio.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = ref.read(tillSessionProvider);
      final sale = await ref
          .read(refundRepositoryProvider)
          .find(folio, online: session?.isOffline == false);
      if (!mounted) return;
      String? error;
      if (sale.fullyReturned) {
        error = _isVoid ? l10n.voidAlreadyReturned : l10n.refundAlreadyReturned;
      } else if (_isVoid && !sale.madeHere) {
        error = l10n.voidOtherTill;
      } else if (_isVoid) {
        final day = sale.occurredAt.toLocal();
        final today = ref.read(saleClockProvider)().toLocal();
        if (day.year != today.year ||
            day.month != today.month ||
            day.day != today.day) {
          error = l10n.voidOtherDay;
        }
      }
      setState(() {
        _busy = false;
        _error = error;
        if (error == null) {
          _sale = sale;
          _units.clear();
          if (_isVoid) {
            for (final l in sale.lines) {
              if (l.left > 0) _units[l.lineNo] = l.left;
            }
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _problem(l10n, e);
      });
    }
  }

  int get _amount {
    final sale = _sale;
    if (sale == null) return 0;
    return sale.lines.fold(
      0,
      (a, l) =>
          a +
          ((_units[l.lineNo] ?? 0) > 0 ? l.amountFor(_units[l.lineNo]!) : 0),
    );
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context)!;
    final sale = _sale!;
    if (_units.values.every((u) => u == 0)) {
      setState(() => _error = l10n.refundNothing);
      return;
    }
    if (_reason == null) {
      setState(() => _error = l10n.refundReasonRequired);
      return;
    }
    final note = _note.text.trim();
    if (_reason == RefundReason.other && note.isEmpty) {
      setState(() => _error = l10n.refundNoteRequired);
      return;
    }
    final session = ref.read(tillSessionProvider);
    if (session == null) return;
    String? approver;
    if (!session.hasPermission(widget.kind.permission)) {
      setState(() => _busy = true);
      final result = await ref.read(approvalRequesterProvider)(
        context,
        action: widget.kind.permission,
        reference: sale.folio,
      );
      if (!mounted) return;
      if (result == null) {
        setState(() {
          _busy = false;
          _error = l10n.refundApprovalNeeded;
        });
        return;
      }
      approver = switch (result) {
        OnlineApprovalResult r => r.approverStaffId,
        OfflineApprovalResult r => r.approverStaffId,
      };
    }
    setState(() => _busy = true);
    try {
      final done = await ref
          .read(refundRepositoryProvider)
          .record(
            sale: sale,
            units: Map.of(_units),
            restock: Set.of(_restock),
            kind: widget.kind,
            reason: _reason!,
            note: note.isEmpty ? null : note,
            staffId: session.staff.id,
            approverStaffId: approver,
            now: ref.read(saleClockProvider)(),
          );
      if (mounted) Navigator.of(context).pop(done);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _problem(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sale = _sale;
    final title = _isVoid ? l10n.saleMenuVoid : l10n.saleMenuRefund;
    final reasons = {
      RefundReason.customerReturn: l10n.refundReasonCustomerReturn,
      RefundReason.wrongItem: l10n.refundReasonWrongItem,
      RefundReason.quality: l10n.refundReasonQuality,
      RefundReason.cashierError: l10n.refundReasonCashierError,
      RefundReason.other: l10n.refundReasonOther,
    };

    final error = _error == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
            child: Text(
              _error!,
              key: const Key('refund-error'),
              style: const TextStyle(color: AppColors.alertRed),
            ),
          );

    if (sale == null) {
      return AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('refund-folio'),
                controller: _folio,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.refundFolio,
                  hintText: l10n.refundFolioHint,
                ),
                onSubmitted: (_) => _search(),
              ),
              error,
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const Key('refund-search'),
            onPressed: _busy ? null : _search,
            child: Text(l10n.refundSearch),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(l10n.refundSaleTitle(sale.folio)),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final l in sale.lines)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.paddingSmall,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.name, style: theme.textTheme.titleSmall),
                            Text(
                              l10n.refundLineUnits(l.left, l.quantity),
                              style: theme.textTheme.bodySmall,
                            ),
                            if (l.left > 0)
                              Row(
                                children: [
                                  Checkbox(
                                    key: Key('refund-restock-${l.lineNo}'),
                                    value: _restock.contains(l.lineNo),
                                    onChanged: (v) => setState(() {
                                      v == true
                                          ? _restock.add(l.lineNo)
                                          : _restock.remove(l.lineNo);
                                    }),
                                  ),
                                  Text(l10n.refundRestock),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (!_isVoid && l.left > 0) ...[
                        IconButton(
                          key: Key('refund-minus-${l.lineNo}'),
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: (_units[l.lineNo] ?? 0) == 0
                              ? null
                              : () => setState(
                                  () =>
                                      _units[l.lineNo] = _units[l.lineNo]! - 1,
                                ),
                        ),
                        Text(
                          (_units[l.lineNo] ?? 0).toString(),
                          key: Key('refund-units-${l.lineNo}'),
                          style: theme.textTheme.titleLarge,
                        ),
                        IconButton(
                          key: Key('refund-plus-${l.lineNo}'),
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: (_units[l.lineNo] ?? 0) >= l.left
                              ? null
                              : () => setState(
                                  () => _units[l.lineNo] =
                                      (_units[l.lineNo] ?? 0) + 1,
                                ),
                        ),
                      ] else
                        Text(
                          (_units[l.lineNo] ?? 0).toString(),
                          key: Key('refund-units-${l.lineNo}'),
                          style: theme.textTheme.titleLarge,
                        ),
                    ],
                  ),
                ),
              const Divider(),
              Text(l10n.refundReason),
              const SizedBox(height: AppDimensions.paddingSmall),
              Wrap(
                spacing: AppDimensions.paddingSmall,
                runSpacing: AppDimensions.paddingSmall,
                children: [
                  for (final e in reasons.entries)
                    ChoiceChip(
                      key: Key('refund-reason-${e.key.json}'),
                      label: Text(e.value),
                      selected: _reason == e.key,
                      onSelected: (_) => setState(() {
                        _reason = e.key;
                        _error = null;
                      }),
                    ),
                ],
              ),
              if (_reason == RefundReason.other)
                TextField(
                  key: const Key('refund-note'),
                  controller: _note,
                  maxLength: 120,
                  decoration: InputDecoration(labelText: l10n.refundNote),
                ),
              const SizedBox(height: AppDimensions.paddingMedium),
              Text(
                l10n.refundGiveBack(formatCents(_amount)),
                key: const Key('refund-amount'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              error,
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
          key: const Key('refund-confirm'),
          style: FilledButton.styleFrom(
            backgroundColor: _isVoid ? AppColors.alertRed : null,
          ),
          onPressed: _busy ? null : _confirm,
          child: Text(_isVoid ? l10n.voidConfirm : l10n.refundConfirm),
        ),
      ],
    );
  }
}

/// After a refund: the amount to hand back, in large type.
Future<void> showRefundDone(
  BuildContext context,
  RefundKind kind,
  RefundResult result,
) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      key: const Key('refund-done'),
      title: Text(
        kind == RefundKind.voidSale ? l10n.voidDoneTitle : l10n.refundDoneTitle,
      ),
      content: Text(
        l10n.refundGiveBack(formatCents(result.totalCents)),
        key: const Key('refund-done-amount'),
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonAccept),
        ),
      ],
    ),
  );
}
