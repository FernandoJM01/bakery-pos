import 'dart:convert';
import 'dart:typed_data';

/// Characters on an 80 mm roll at the normal font.
const receiptColumns = 48;

/// One line of a printed document.
class PrintLine {
  const PrintLine(
    this.left, {
    this.right,
    this.bold = false,
    this.center = false,
    this.large = false,
  });

  /// A full-width dashed rule.
  const PrintLine.rule()
    : left = '',
      right = null,
      bold = false,
      center = false,
      large = false;

  final String left;
  final String? right;
  final bool bold;
  final bool center;
  final bool large;

  bool get isRule =>
      left.isEmpty && right == null && !bold && !center && !large;
}

/// ESC/POS commands for the 80 mm network printer (M4 brief 2).
class EscPos {
  EscPos._();

  static const init = [0x1B, 0x40];

  /// Code page WPC1252, for the Spanish letters.
  static const codePage = [0x1B, 0x74, 16];

  /// Pulse on the cash drawer's pin 2.
  static const drawerKick = [0x1B, 0x70, 0, 25, 250];

  /// Feed and a partial cut.
  static const feedAndCut = [0x1D, 0x56, 66, 0];

  static List<int> _align(bool center) => [0x1B, 0x61, center ? 1 : 0];
  static List<int> _bold(bool on) => [0x1B, 0x45, on ? 1 : 0];
  static List<int> _size(bool large) => [0x1D, 0x21, large ? 0x11 : 0];

  /// Latin-1 covers Spanish; anything else prints as `?`.
  static List<int> encode(String s) => latin1.encode(
    String.fromCharCodes(s.runes.map((c) => c < 256 ? c : 0x3F)),
  );

  /// [left] and [right] on one row of [columns], [right] flush right. A
  /// [left] too long for the row wraps onto its own lines first.
  static List<String> row(String left, String? right, int columns) {
    if (right == null) return _wrap(left, columns);
    final room = columns - right.length - 1;
    if (room < 1) return [..._wrap(left, columns), right.padLeft(columns)];
    final lines = _wrap(left, room);
    final last = lines.removeLast();
    return [...lines, '${last.padRight(room)} $right'];
  }

  static List<String> _wrap(String text, int columns) {
    final out = <String>[];
    var rest = text;
    while (rest.length > columns) {
      var cut = rest.lastIndexOf(' ', columns);
      if (cut <= 0) cut = columns;
      out.add(rest.substring(0, cut));
      rest = rest.substring(cut).trimLeft();
    }
    out.add(rest);
    return out;
  }

  /// The bytes of a document; [openDrawer] kicks the drawer before printing.
  static Uint8List document(List<PrintLine> lines, {bool openDrawer = false}) {
    final b = BytesBuilder()
      ..add(init)
      ..add(codePage);
    if (openDrawer) b.add(drawerKick);
    for (final l in lines) {
      b
        ..add(_align(l.center))
        ..add(_bold(l.bold))
        ..add(_size(l.large));
      final columns = l.large ? receiptColumns ~/ 2 : receiptColumns;
      final text = l.isRule
          ? ['-' * receiptColumns]
          : row(l.left, l.right, columns);
      for (final t in text) {
        b
          ..add(encode(t))
          ..addByte(0x0A);
      }
    }
    b
      ..add(_size(false))
      ..add(_bold(false))
      ..add(_align(false))
      ..add(feedAndCut);
    return b.toBytes();
  }
}
