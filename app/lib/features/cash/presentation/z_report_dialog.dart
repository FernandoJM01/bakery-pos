import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_database.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../printing/data/printer_service.dart';
import '../../printing/domain/documents.dart';
import '../../printing/domain/escpos.dart';
import '../../sale/data/sale_repository.dart';
import '../data/shift_repository.dart';

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

/// The Z report of a closed shift on this till. Prints when a printer is set
/// and can be opened again later (M4.4).
class ZReportDialog extends ConsumerStatefulWidget {
  const ZReportDialog({super.key, required this.shift});

  final LocalShift shift;

  @override
  ConsumerState<ZReportDialog> createState() => _ZReportDialogState();
}

class _ZReportDialogState extends ConsumerState<ZReportDialog> {
  List<PrintLine>? _lines;
  bool _printFailed = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = widget.shift;
    final repo = ref.read(shiftRepositoryProvider);
    final z = await repo.zReport(s.id);
    final prefix = await ref.read(saleRepositoryProvider).folioPrefix();
    final branch = await ref.read(enrolledBranchNameProvider.future);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _lines = zDocument(
        l10n,
        ZHeader(
          zLabel: formatZLabel(prefix ?? '', s.zNumber ?? 0),
          branch: branch,
          openedAt: s.openedAt,
          openedBy: s.openedByName,
          closedAt: s.closedAt!,
          closedBy: s.closedByName ?? '',
          floatCents: s.floatCents,
          expectedCents: s.expectedCents ?? 0,
          countedCents: s.countedCents ?? 0,
          varianceCents: s.varianceCents ?? 0,
          note: s.note,
        ),
        z,
      );
    });
  }

  Future<void> _print() async {
    final lines = _lines;
    if (lines == null) return;
    setState(() {
      _busy = true;
      _printFailed = false;
    });
    final ok = await ref.read(printerServiceProvider).print(lines);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _printFailed = !ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lines = _lines;
    return AlertDialog(
      content: SizedBox(
        width: 460,
        child: lines == null
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  key: const Key('z-report'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DocumentView(lines: lines),
                    if (_printFailed) ...[
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Text(
                        l10n.printFailed,
                        key: const Key('z-print-failed'),
                        style: const TextStyle(color: AppColors.alertRed),
                      ),
                    ],
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          key: const Key('z-print'),
          onPressed: _busy ? null : _print,
          child: Text(l10n.printAction),
        ),
        FilledButton(
          key: const Key('z-close'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}
