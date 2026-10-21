import 'dart:convert';
import 'dart:typed_data';

import 'package:bakery_pos/features/auth/domain/offline_pin_verifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfflinePinVerifier', () {
    const verifier = OfflinePinVerifier();

    test(
      'verifies correct PIN against generated Argon2id PHC verifier',
      () async {
        final salt = Uint8List.fromList(utf8.encode('testsalt1234'));
        final phc = OfflinePinVerifier.generatePhcVerifier(
          '1234',
          salt: salt,
          iterations: 3,
          memory: 65536,
          parallelism: 1,
        );

        final matches = await verifier.verify('1234', phc);
        expect(matches, isTrue);

        final wrongMatches = await verifier.verify('5678', phc);
        expect(wrongMatches, isFalse);
      },
    );

    test('verifies fixed fake API verifier matches PIN 1234', () async {
      const fixedPhc =
          r'$argon2id$v=19$m=65536,t=3,p=1$dGVzdHNhbHQxMjM0$a3eQTmzY2EF7EnnZVEMeIqJEhBxWE2OCvFk+kud2a/4';
      final matches = await verifier.verify('1234', fixedPhc);
      expect(matches, isTrue);

      final wrongMatches = await verifier.verify('9999', fixedPhc);
      expect(wrongMatches, isFalse);
    });

    test('returns false gracefully for malformed verifier strings', () async {
      expect(await verifier.verify('1234', 'not-a-phc-string'), isFalse);
      expect(
        await verifier.verify(
          '1234',
          r'$argon2d$v=19$m=65536,t=3,p=1$salt$hash',
        ),
        isFalse,
      );
      expect(
        await verifier.verify('1234', r'$argon2id$v=19$bad-params$salt$hash'),
        isFalse,
      );
    });

    test('measures Argon2id PIN verification execution speed', () async {
      const phc =
          r'$argon2id$v=19$m=65536,t=3,p=1$dGVzdHNhbHQxMjM0$a3eQTmzY2EF7EnnZVEMeIqJEhBxWE2OCvFk+kud2a/4';

      final stopwatch = Stopwatch()..start();
      final result = await verifier.verify('1234', phc);
      stopwatch.stop();

      expect(result, isTrue);
      final elapsedMs = stopwatch.elapsedMilliseconds;
      // print for benchmark logging
      // ignore: avoid_print
      print('Argon2id (m=65536, t=3, p=1) verification time: $elapsedMs ms');
      expect(elapsedMs, lessThan(1500));
    });
  });
}
