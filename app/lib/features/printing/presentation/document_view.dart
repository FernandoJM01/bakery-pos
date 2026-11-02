import 'package:flutter/material.dart';

import '../domain/escpos.dart';

/// Lines of a printed document, on screen (M11.2).
class DocumentView extends StatelessWidget {
  const DocumentView({super.key, required this.lines});

  final List<PrintLine> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final l in lines)
          if (l.isRule)
            const Divider()
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.left,
                      textAlign: l.center ? TextAlign.center : TextAlign.start,
                      style: l.bold ? theme.textTheme.titleSmall : null,
                    ),
                  ),
                  if (l.right != null)
                    Text(
                      l.right!,
                      style: l.bold ? theme.textTheme.titleSmall : null,
                    ),
                ],
              ),
            ),
      ],
    );
  }
}
