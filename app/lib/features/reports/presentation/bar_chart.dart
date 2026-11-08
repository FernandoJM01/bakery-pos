import 'package:flutter/material.dart';

/// One bar: its label under it and its value, already formatted, on top.
class Bar {
  const Bar(this.label, this.value, this.valueText, {this.highlight = false});

  final String label;
  final int value;
  final String valueText;
  final bool highlight;
}

/// A plain bar chart with no library: bars share one scale from zero, the
/// value sits on each bar and the label under it.
class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.bars, this.height = 180});

  final List<Bar> bars;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = bars.fold(0, (a, b) => b.value > a ? b.value : a);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final b in bars)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FittedBox(
                      child: Text(
                        b.valueText,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: top == 0
                          ? 0
                          : (height - 40) * (b.value < 0 ? 0 : b.value) / top,
                      decoration: BoxDecoration(
                        color: b.highlight
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withValues(alpha: 0.45),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      child: Text(b.label, style: theme.textTheme.labelSmall),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
