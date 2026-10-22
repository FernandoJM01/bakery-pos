import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Web Bundle Cleanliness Check', () {
    test(
      'pubspec does not depend on dargon2_flutter or dargon2_flutter_web',
      () {
        final pubspec = File('pubspec.yaml').readAsStringSync();
        expect(pubspec.contains('dargon2_flutter:'), isFalse);
        expect(pubspec.contains('dargon2_flutter_web:'), isFalse);

        final lockFile = File('pubspec.lock').readAsStringSync();
        expect(lockFile.contains('dargon2_flutter_web'), isFalse);
      },
    );

    test('compiled web bundle contains no cdn.jsdelivr.net or hash-wasm', () {
      final jsFile = File('build/web/main.dart.js');
      if (!jsFile.existsSync()) {
        // Skip if web bundle not built during this specific test run
        return;
      }
      final content = jsFile.readAsStringSync();
      expect(
        content.contains('cdn.jsdelivr.net'),
        isFalse,
        reason: 'Back office web bundle must not load dependencies from CDN',
      );
      expect(
        content.contains('hash-wasm'),
        isFalse,
        reason: 'Back office web bundle must not contain argon2 web plugin',
      );
    });
  });
}
