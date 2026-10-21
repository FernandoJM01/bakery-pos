import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Acceptance Test A18', () {
    test('A18: all till and back office text comes from app_es.arb', () {
      final arbFile = File('lib/l10n/app_es.arb');
      expect(arbFile.existsSync(), isTrue, reason: 'app_es.arb must exist');

      final arbContent = arbFile.readAsStringSync();
      final Map<String, dynamic> arbMap =
          jsonDecode(arbContent) as Map<String, dynamic>;

      expect(arbMap.containsKey('appTitle'), isTrue);
      expect(arbMap.containsKey('statusOnline'), isTrue);
      expect(arbMap.containsKey('statusOffline'), isTrue);
      expect(arbMap.containsKey('loginButton'), isTrue);

      // Scan dart files in lib/ for prohibited hardcoded user-facing strings in Text widgets
      final libDir = Directory('lib');
      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('.dart') &&
                !f.path.contains('.g.dart') &&
                !f.path.contains('app_localizations') &&
                !f.path.contains('generated/'),
          )
          .toList();

      final violations = <String>[];
      // Regex matching Text('...') where string contains user-facing Spanish letters/words
      // and isn't a key or identifier
      final hardcodedTextRegex = RegExp(
        r'''Text\(\s*['"]([A-ZÁÉÍÓÚÑa-záéíóúñ\s]{4,})['"]\s*[,)]''',
      );

      for (final file in dartFiles) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          final match = hardcodedTextRegex.firstMatch(line);
          if (match != null) {
            final literal = match.group(1);
            // Ignore debug labels, technical mode names or Keys
            if (literal != null &&
                literal != 'Bakery POS' &&
                !line.contains('Key(')) {
              violations.add(
                '${file.path}:${i + 1} hardcoded Text("$literal")',
              );
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'All user-facing strings in Text widgets must come from app_es.arb via AppLocalizations',
      );
    });
  });
}
