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
  });
}
