import 'dart:io';
import 'package:flutter/foundation.dart';
import 'receipt_printer_service.dart';

/// Network-connected thermal printer service via TCP/IP socket (ESC/POS protocol)
class EscPosPrinterService implements ReceiptPrinterService {
  final String ipAddress;
  final int port;
  Socket? _socket;

  EscPosPrinterService({
    required this.ipAddress,
    this.port = 9100, // Standard raw port for network receipt printers
  });

  @override
  Future<bool> connect() async {
    try {
      _socket = await Socket.connect(ipAddress, port, timeout: const Duration(seconds: 3));
      return true;
    } catch (e) {
      debugPrint('[EscPosPrinter] Connection error: $e');
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
  }

  @override
  Future<bool> isConnected() async => _socket != null;

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
    if (_socket == null) {
      final ok = await connect();
      if (!ok) return false;
    }

    final bytes = <int>[];
    // ESC @ - Initialize printer
    bytes.addAll([0x1B, 0x40]);
    // ESC a 1 - Center align
    bytes.addAll([0x1B, 0x61, 0x01]);
    // GS ! 17 - Double height & width for header
    bytes.addAll([0x1D, 0x21, 0x11]);
    bytes.addAll('$branchName\n'.codeUnits);
    // GS ! 0 - Normal size
    bytes.addAll([0x1D, 0x21, 0x00]);
    bytes.addAll('FRESH BAKERY & ARTISAN OVEN\n'.codeUnits);
    bytes.addAll('--------------------------------\n'.codeUnits);
    
    // ESC a 0 - Left align
    bytes.addAll([0x1B, 0x61, 0x00]);
    bytes.addAll('Receipt #: $receiptNumber\n'.codeUnits);
    bytes.addAll('Cashier:   $cashierName\n'.codeUnits);
    bytes.addAll('--------------------------------\n'.codeUnits);

    for (final item in items) {
      final name = item.name.length > 20 ? item.name.substring(0, 20) : item.name;
      final line = '${item.quantity}x $name'.padRight(22) +
          '\$${(item.totalPriceCents / 100).toStringAsFixed(2)}'.padLeft(10) +
          '\n';
      bytes.addAll(line.codeUnits);
    }
    bytes.addAll('--------------------------------\n'.codeUnits);
    bytes.addAll(('TOTAL: '.padRight(20) + '\$${(totalCents / 100).toStringAsFixed(2)}\n'.padLeft(12)).codeUnits);
    bytes.addAll('Payment: $paymentMethod\n'.codeUnits);
    bytes.addAll('\n\n\n'.codeUnits);

    // GS V 66 0 - Paper cut (full cut)
    bytes.addAll([0x1D, 0x56, 0x42, 0x00]);

    _socket?.add(bytes);
    await _socket?.flush();
    return true;
  }

  @override
  Future<void> sendRaw(List<int> bytes) async {
    _socket?.add(bytes);
    await _socket?.flush();
  }
}
