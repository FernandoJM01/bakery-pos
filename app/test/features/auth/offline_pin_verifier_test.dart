import 'dart:convert';
import 'dart:typed_data';

import 'package:bakery_pos/features/auth/domain/offline_pin_verifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfflinePinVerifier', () {
    const verifier = OfflinePinVerifier();

    // Committed fixtures generated with server's node argon2 package (m=65536, t=3, p=1, v=19)
    const nodeHash1234 =
        r'$argon2id$v=19$m=65536,p=1,t=3$p6+vhCNw8VlT1Bnq34jEeg$cZv+IP6sdJhBnTqEB3+SsD8svzrLHXPiPpDEWJPp/54';
    const nodeHash987654 =
        r'$argon2id$v=19$m=65536,p=1,t=3$EUUMDmioRym6pwiS4R/pWA$zGVfcdye2/3+eWU80oAhrtXAE4JoyvbQO+5rMCyYD3U';

    test('verifies 4-digit PIN against server node argon2 fixture', () async {
      expect(await verifier.verify('1234', nodeHash1234), isTrue);
      expect(await verifier.verify('9999', nodeHash1234), isFalse);
    });

    test('verifies 6-digit PIN against server node argon2 fixture', () async {
      expect(await verifier.verify('987654', nodeHash987654), isTrue);
      expect(await verifier.verify('123456', nodeHash987654), isFalse);
    });

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

    test('enforces strict verifier parameters and rejects deviations', () async {
      // Reject non-argon2id type
      const argon2dHash =
          r'$argon2d$v=19$m=65536,t=3,p=1$p6+vhCNw8VlT1Bnq34jEeg$cZv+IP6sdJhBnTqEB3+SsD8svzrLHXPiPpDEWJPp/54';
      expect(await verifier.verify('1234', argon2dHash), isFalse);

      // Reject non-v19 version
      const v16Hash =
          r'$argon2id$v=16$m=65536,t=3,p=1$p6+vhCNw8VlT1Bnq34jEeg$cZv+IP6sdJhBnTqEB3+SsD8svzrLHXPiPpDEWJPp/54';
      expect(await verifier.verify('1234', v16Hash), isFalse);

      // Reject memory != 65536 (huge m or small m)
      const hugeMHash =
          r'$argon2id$v=19$m=1048576,t=3,p=1$p6+vhCNw8VlT1Bnq34jEeg$cZv+IP6sdJhBnTqEB3+SsD8svzrLHXPiPpDEWJPp/54';
      expect(await verifier.verify('1234', hugeMHash), isFalse);

      const smallMHash =
          r'$argon2id$v=19$m=4096,t=3,p=1$p6+vhCNw8VlT1Bnq34jEeg$cZv+IP6sdJhBnTqEB3+SsD8svzrLHXPiPpDEWJPp/54';
      expect(await verifier.verify('1234', smallMHash), isFalse);

      // Reject iterations != 3
      const iter10Hash =
          r'$argon2id$v=19$m=65536,t=10,p=1$p6+vhCNw8VlT1Bnq34jEeg$cZv+IP6sdJhBnTqEB3+SsD8svzrLHXPiPpDEWJPp/54';
      expect(await verifier.verify('1234', iter10Hash), isFalse);

      // Reject parallelism != 1
      const p2Hash =
          r'$argon2id$v=19$m=65536,t=3,p=2$p6+vhCNw8VlT1Bnq34jEeg$cZv+IP6sdJhBnTqEB3+SsD8svzrLHXPiPpDEWJPp/54';
      expect(await verifier.verify('1234', p2Hash), isFalse);

      // Reject unknown parameters
      const extraParamHash =
          r'$argon2id$v=19$m=65536,t=3,p=1,extra=foo$p6+vhCNw8VlT1Bnq34jEeg$cZv+IP6sdJhBnTqEB3+SsD8svzrLHXPiPpDEWJPp/54';
      expect(await verifier.verify('1234', extraParamHash), isFalse);
    });

    test('returns false gracefully for malformed verifier strings', () async {
      expect(await verifier.verify('1234', 'not-a-phc-string'), isFalse);
      expect(await verifier.verify('1234', ''), isFalse);
      expect(
        await verifier.verify('1234', r'$argon2id$v=19$bad-params$salt$hash'),
        isFalse,
      );
    });
  });
}
