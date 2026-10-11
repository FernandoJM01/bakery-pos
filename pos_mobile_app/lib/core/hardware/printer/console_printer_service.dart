import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'receipt_printer_service.dart';

class ConsolePrinterService implements ReceiptPrinterService {
  bool _connected = false;

  @override
  Future<bool> connect() async {
    _connected = true;
    debugPrint('[ConsolePrinter] Printer connected successfully');
    return true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    debugPrint('[ConsolePrinter] Printer disconnected');
  }

  @override
  Future<bool> isConnected() async => _connected;

  @override
  Future<bool> printReceipt({
    required String branchName,
    required String receiptNumber,
    required String cashierName,
    required DateTime timestamp,
    required List<ReceiptLineItem> items,
    required int subtotalCents,
    required int taxCents,
    required int totalCents,
    required String paymentMethod,
    int? cashTenderedCents,
    int? changeDueCents,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('========================================');
    buffer.writeln('          $branchName');
    buffer.writeln('       FRESH BAKERY & ARTISAN OVEN');
    buffer.writeln('----------------------------------------');
    buffer.writeln('Receipt #: $receiptNumber');
    buffer.writeln('Date:      ${timestamp.toIso8601String()}');
    buffer.writeln('Cashier:   $cashierName');
    buffer.writeln('----------------------------------------');
    for (final item in items) {
      final line = '${item.name} x${item.quantity}'.padRight(28) +
          '\$${(item.totalPriceCents / 100).toStringAsFixed(2)}'.padLeft(12);
      buffer.writeln(line);
    }
    buffer.writeln('----------------------------------------');
    buffer.writeln('Subtotal:       '.padRight(28) + '\$${(subtotalCents / 100).toStringAsFixed(2)}'.padLeft(12));
    buffer.writeln('Tax:            '.padRight(28) + '\$${(taxCents / 100).toStringAsFixed(2)}'.padLeft(12));
    buffer.writeln('TOTAL:          '.padRight(28) + '\$${(totalCents / 100).toStringAsFixed(2)}'.padLeft(12));
    buffer.writeln('Payment:        '.padRight(28) + paymentMethod.padLeft(12));
    if (cashTenderedCents != null) {
      buffer.writeln('Tendered:       '.padRight(28) + '\$${(cashTenderedCents / 100).toStringAsFixed(2)}'.padLeft(12));
      buffer.writeln('Change:         '.padRight(28) + '\$${((changeDueCents ?? 0) / 100).toStringAsFixed(2)}'.padLeft(12));
    }
    buffer.writeln('========================================');
    buffer.writeln('     Thank you for your visit!');
    buffer.writeln('========================================\n');

    debugPrint(buffer.toString());
    return true;
  }

  @override
  Future<void> sendRaw(List<int> bytes) async {
    debugPrint('[ConsolePrinter] Raw ESC/POS bytes: ${bytes.length} bytes -> ${utf8.decode(bytes, allowMalformed: true)}');
  }
}
