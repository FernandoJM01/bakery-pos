import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_database.dart';
import '../domain/escpos.dart';

const printerHostKey = 'printer.host';
const printerPortKey = 'printer.port';
const defaultPrinterPort = 9100;

/// Sends bytes to a printer; tests replace it.
typedef PrinterTransport = Future<void> Function(
  String host,
  int port,
  Uint8List bytes,
);

/// A plain TCP socket, as ESC/POS network printers take (M4 brief 2).
Future<void> sendOverTcp(String host, int port, Uint8List bytes) async {
  final socket = await Socket.connect(
    host,
    port,
    timeout: const Duration(seconds: 3),
  );
  try {
    socket.add(bytes);
    await socket.flush().timeout(const Duration(seconds: 5));
  } finally {
    socket.destroy();
  }
}

class PrinterConfig {
  const PrinterConfig(this.host, this.port);
  final String host;
  final int port;
}

/// Prints on this till's printer. A failed print never undoes anything: the
/// caller keeps the document on screen with a retry button (E11).
class PrinterService {
  PrinterService(this._db, [this._send = sendOverTcp]);

  final AppDatabase _db;
  final PrinterTransport _send;

  Future<PrinterConfig?> config() async {
    final host = await _db.getSessionValue(printerHostKey);
    if (host == null || host.isEmpty) return null;
    final port = int.tryParse(await _db.getSessionValue(printerPortKey) ?? '');
    return PrinterConfig(host, port ?? defaultPrinterPort);
  }

  Future<void> saveConfig(String host, int port) async {
    await _db.setSessionValue(printerHostKey, host.trim());
    await _db.setSessionValue(printerPortKey, '$port');
  }

  /// False when no printer is set or it could not be reached.
  Future<bool> print(List<PrintLine> doc, {bool openDrawer = false}) =>
      _sendBytes(EscPos.document(doc, openDrawer: openDrawer));

  /// Opens the drawer with nothing printed.
  Future<bool> kickDrawer() =>
      _sendBytes(Uint8List.fromList([...EscPos.init, ...EscPos.drawerKick]));

  Future<bool> _sendBytes(Uint8List bytes) async {
    final c = await config();
    if (c == null) return false;
    try {
      await _send(c.host, c.port, bytes);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final printerServiceProvider = Provider<PrinterService>(
  (ref) => PrinterService(ref.watch(tillDatabaseProvider)),
);
