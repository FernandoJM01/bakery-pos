import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Finds user-facing string literals: the first argument of text widgets and
/// the usual text-carrying named arguments. Literals without letters (such as
/// separators) are allowed. Spans lines, so `Text(\n  'Hola',\n)` is caught.
final _userFacingLiteral = RegExp(
  r'''(?:\b(?:Text|SelectableText|Tooltip)\(\s*|\b(?:labelText|hintText|helperText|errorText|counterText|prefixText|suffixText|tooltip|semanticsLabel|semanticLabel|message|title|label)\s*:\s*)(['"])((?:(?!\1)[^\\\n]|\\.)*)\1''',
);

final _letter = RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]');

List<String> findLiteralStrings(String source) => [
  for (final match in _userFacingLiteral.allMatches(source))
    if (_letter.hasMatch(match.group(2)!)) match.group(2)!,
];

void main() {
  group('Acceptance Test A18', () {
    test('the scanner catches literals in widgets and text arguments', () {
      const sample = '''
        Text('Hola');
        Text(
          "Cobrar 2 piezas",
        );
        InputDecoration(labelText: 'Correo', hintText: 'ej. ana@x.mx');
        IconButton(tooltip: 'Cerrar', onPressed: null);
        Text(l10n.appTitle);
        Text(' · ');
        Key('mode-label');
      ''';

      expect(findLiteralStrings(sample), [
        'Hola',
        'Cobrar 2 piezas',
        'Correo',
        'ej. ana@x.mx',
        'Cerrar',
      ]);
    });

    test('A18: all till and back office text comes from app_es.arb', () {
      final arbFile = File('lib/l10n/app_es.arb');
      expect(arbFile.existsSync(), isTrue, reason: 'app_es.arb must exist');
      final arbMap =
          jsonDecode(arbFile.readAsStringSync()) as Map<String, dynamic>;
      expect(arbMap['@@locale'], 'es');

      final dartFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('.dart') &&
                !f.path.endsWith('.g.dart') &&
                !f.path.contains('${Platform.pathSeparator}l10n') &&
                !f.path.contains('${Platform.pathSeparator}generated'),
          );

      final violations = [
        for (final file in dartFiles)
          for (final literal in findLiteralStrings(file.readAsStringSync()))
            '${file.path}: "$literal"',
      ];

      expect(
        violations,
        isEmpty,
        reason:
            'User-facing text must come from app_es.arb via AppLocalizations',
      );
    });
  });
}
