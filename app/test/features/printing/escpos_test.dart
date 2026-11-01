import 'package:bakery_pos/features/printing/data/printer_service.dart';
import 'package:bakery_pos/features/printing/domain/escpos.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

bool contains(List<int> bytes, List<int> part) {
  for (var i = 0; i + part.length <= bytes.length; i++) {
    if (listEquals(bytes.sublist(i, i + part.length), part)) return true;
  }
  return false;
}

void main() {
  group('EscPos', () {
    test('a row puts the amount flush right at 48 columns', () {
      final [line] = EscPos.row('Concha', r'$15.00', receiptColumns);
      expect(line.length, 48);
      expect(line, startsWith('Concha'));
      expect(line, endsWith(r'$15.00'));
    });

    test('a long name wraps and keeps the amount on its last line', () {
      final lines = EscPos.row(
        'Pastel de tres leches con fresa y crema batida de la casa',
        r'$450.00',
        receiptColumns,
      );
      expect(lines.length, greaterThan(1));
      expect(lines.last, endsWith(r'$450.00'));
      expect(lines.every((l) => l.length <= 48), isTrue);
    });

    test('Spanish letters use one byte and other characters print ?', () {
      expect(EscPos.encode('Piña'), [0x50, 0x69, 0xF1, 0x61]);
      expect(EscPos.encode('a€'), [0x61, 0x3F]);
    });

    test('a document starts clean and ends with a cut', () {
      final bytes = EscPos.document([const PrintLine('Hola')]);
      expect(bytes.sublist(0, 2), EscPos.init);
      expect(contains(bytes, EscPos.feedAndCut), isTrue);
      expect(contains(bytes, EscPos.drawerKick), isFalse);
    });

    test('openDrawer sends the kick', () {
      final bytes = EscPos.document([
        const PrintLine('Hola'),
      ], openDrawer: true);
      expect(contains(bytes, EscPos.drawerKick), isTrue);
    });
  });

  group('PrinterService', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('E11: with no printer set nothing is sent', () async {
      var sent = 0;
      final service = PrinterService(db, (_, _, _) async => sent++);
      expect(await service.print([const PrintLine('x')]), isFalse);
      expect(sent, 0);
    });

    test('E11: the bytes reach the saved address', () async {
      String? host;
      int? port;
      Uint8List? bytes;
      final service = PrinterService(db, (h, p, b) async {
        host = h;
        port = p;
        bytes = b;
      });
      await service.saveConfig(' 192.168.1.50 ', 9100);
      expect(
        await service.print([const PrintLine('x')], openDrawer: true),
        isTrue,
      );
      expect(host, '192.168.1.50');
      expect(port, 9100);
      expect(contains(bytes!, EscPos.drawerKick), isTrue);
    });

    test('E11: a dead printer answers false and never throws', () async {
      final service = PrinterService(
        db,
        (_, _, _) async => throw Exception('refused'),
      );
      await service.saveConfig('10.0.0.1', 9100);
      expect(await service.print([const PrintLine('x')]), isFalse);
      expect(await service.kickDrawer(), isFalse);
    });
  });
}
