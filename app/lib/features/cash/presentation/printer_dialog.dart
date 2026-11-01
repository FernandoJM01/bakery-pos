import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../printing/data/printer_service.dart';
import '../../printing/domain/escpos.dart';

/// This till's printer: address, port and a test print (M11.2).
class PrinterDialog extends ConsumerStatefulWidget {
  const PrinterDialog({super.key});

  @override
  ConsumerState<PrinterDialog> createState() => _PrinterDialogState();
}

class _PrinterDialogState extends ConsumerState<PrinterDialog> {
  final _host = TextEditingController();
  final _port = TextEditingController(text: '$defaultPrinterPort');
  String? _status;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    ref.read(printerServiceProvider).config().then((c) {
      if (c == null || !mounted) return;
      _host.text = c.host;
      _port.text = '${c.port}';
    });
  }

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    super.dispose();
  }

  int get _portValue => int.tryParse(_port.text) ?? defaultPrinterPort;

  Future<void> _test() async {
    final l10n = AppLocalizations.of(context)!;
    final printer = ref.read(printerServiceProvider);
    await printer.saveConfig(_host.text, _portValue);
    final ok = await printer.print([
      PrintLine(l10n.printerTestPage, bold: true, center: true),
    ]);
    if (!mounted) return;
    setState(() {
      _failed = !ok;
      _status = ok ? l10n.printerTestOk : l10n.printFailed;
    });
  }

  Future<void> _save() async {
    await ref.read(printerServiceProvider).saveConfig(_host.text, _portValue);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.printerTitle),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('printer-host'),
              controller: _host,
              decoration: InputDecoration(labelText: l10n.printerHost),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            TextField(
              key: const Key('printer-port'),
              controller: _port,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: l10n.printerPort),
            ),
            if (_status != null) ...[
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                _status!,
                key: const Key('printer-status'),
                style: TextStyle(color: _failed ? AppColors.alertRed : null),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('printer-test'),
          onPressed: _test,
          child: Text(l10n.printerTest),
        ),
        FilledButton(
          key: const Key('printer-save'),
          onPressed: _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
