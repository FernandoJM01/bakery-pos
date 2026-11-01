import 'package:flutter/material.dart';

import '../../../core/money/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/sale_repository.dart';

/// Bills on the quick buttons, in centavos.
const quickBills = [2000, 5000, 10000, 20000, 50000];

/// Cash payment (M3 brief 4.1): the total, what the customer gives, the
/// change in large type. [onFinish] stores the sale; the dialog closes with
/// its receipt.
class PaymentDialog extends StatefulWidget {
  const PaymentDialog({
    super.key,
    required this.totalCents,
    required this.onFinish,
  });

  final int totalCents;
  final Future<SaleReceipt> Function(int tenderedCents) onFinish;

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _amount = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  int? get _tendered => parseCents(_amount.text);

  void _set(int cents) => setState(() {
    _amount.text = centsToInput(cents);
    _error = null;
  });

  Future<void> _finish() async {
    final tendered = _tendered;
    if (tendered == null || tendered < widget.totalCents) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final receipt = await widget.onFinish(tendered);
      if (mounted) Navigator.of(context).pop(receipt);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = AppLocalizations.of(context)!.salePaymentFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tendered = _tendered;
    final enough = tendered != null && tendered >= widget.totalCents;
    final big = theme.textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return AlertDialog(
      title: Text(l10n.salePaymentTitle),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.salePaymentTotal, style: theme.textTheme.titleMedium),
            Text(
              formatCents(widget.totalCents),
              key: const Key('payment-total'),
              style: big,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            TextField(
              key: const Key('payment-amount'),
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: theme.textTheme.headlineSmall,
              decoration: InputDecoration(
                labelText: l10n.salePaymentReceived,
                prefixText: r'$ ',
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Wrap(
              spacing: AppDimensions.paddingSmall,
              runSpacing: AppDimensions.paddingSmall,
              children: [
                _QuickButton(
                  key: const Key('payment-exact'),
                  label: l10n.salePaymentExact,
                  onPressed: () => _set(widget.totalCents),
                ),
                for (final bill in quickBills)
                  _QuickButton(
                    key: Key('payment-bill-$bill'),
                    label: formatCents(bill).replaceAll('.00', ''),
                    onPressed: () => _set(bill),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            if (tendered != null && !enough)
              Text(
                l10n.salePaymentMissing(
                  formatCents(widget.totalCents - tendered),
                ),
                key: const Key('payment-missing'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.alertRed,
                ),
              )
            else ...[
              Text(l10n.salePaymentChange, style: theme.textTheme.titleMedium),
              Text(
                formatCents(enough ? tendered - widget.totalCents : 0),
                key: const Key('payment-change'),
                style: big?.copyWith(color: AppColors.successGreen),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(_error!, style: const TextStyle(color: AppColors.alertRed)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        SizedBox(
          height: AppDimensions.preferredTouchTarget,
          child: FilledButton(
            key: const Key('payment-finish'),
            onPressed: enough && !_busy ? _finish : null,
            child: Text(l10n.salePaymentFinish),
          ),
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: AppDimensions.preferredTouchTarget,
    child: OutlinedButton(onPressed: onPressed, child: Text(label)),
  );
}
