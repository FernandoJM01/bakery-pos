import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/money/money.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/cash_totals.dart';

/// Counting a drawer by denomination, with the total as it adds up. It knows
/// nothing about what the drawer should hold, so a blind close stays blind.
class CountForm extends StatefulWidget {
  const CountForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.busy = false,
  });

  final String submitLabel;
  final ValueChanged<Map<int, int>> onSubmit;
  final bool busy;

  @override
  State<CountForm> createState() => _CountFormState();
}

class _CountFormState extends State<CountForm> {
  final _fields = {
    for (final d in denominationsCents) d: TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<int, int> get _count => {
    for (final e in _fields.entries)
      if ((int.tryParse(e.value.text) ?? 0) > 0) e.key: int.parse(e.value.text),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final count = _count;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: AppDimensions.paddingMedium,
          runSpacing: AppDimensions.paddingSmall,
          children: [
            for (final d in denominationsCents)
              SizedBox(
                width: 150,
                child: TextField(
                  key: Key('count-$d'),
                  controller: _fields[d],
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: InputDecoration(labelText: formatCents(d)),
                  onChanged: (_) => setState(() {}),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Text(
          l10n.cashCountTotal(formatCents(countTotal(count))),
          key: const Key('count-total'),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        SizedBox(
          height: AppDimensions.largeTouchTarget,
          child: FilledButton(
            key: const Key('count-submit'),
            onPressed: widget.busy || count.isEmpty
                ? null
                : () => widget.onSubmit(count),
            child: Text(widget.submitLabel),
          ),
        ),
      ],
    );
  }
}
