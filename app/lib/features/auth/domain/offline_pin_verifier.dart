import 'dart:convert';
import 'dart:typed_data';

import 'package:argon2/argon2.dart';

class OfflinePinVerifier {
  const OfflinePinVerifier();

  /// Verifies [pin] against the PHC format Argon2id [verifier].
  /// Format: `$argon2id$v=19$m=65536,t=3,p=1$<salt-b64>$<hash-b64>`
  Future<bool> verify(String pin, String verifier) async {
    try {
      final parts = verifier.split(r'$');
      if (parts.length < 6) return false;
      if (parts[1] != 'argon2id') return false;

      int iterations = 3;
      int memory = 65536;
      int parallelism = 1;

      for (final param in parts[3].split(',')) {
        final kv = param.split('=');
        if (kv.length == 2) {
          if (kv[0] == 'm') memory = int.tryParse(kv[1]) ?? memory;
          if (kv[0] == 't') iterations = int.tryParse(kv[1]) ?? iterations;
          if (kv[0] == 'p') parallelism = int.tryParse(kv[1]) ?? parallelism;
        }
      }

      final salt = _decodeBase64(parts[4]);
      final expectedHash = _decodeBase64(parts[5]);

      final params = Argon2Parameters(
        Argon2Parameters.ARGON2_id,
        salt,
        version: Argon2Parameters.ARGON2_VERSION_13,
        iterations: iterations,
        memory: memory,
        lanes: parallelism,
      );

      final generator = Argon2BytesGenerator()..init(params);
      final out = Uint8List(expectedHash.length);
      generator.generateBytesFromString(pin, out);

      if (out.length != expectedHash.length) return false;
      var diff = 0;
      for (var i = 0; i < out.length; i++) {
        diff |= out[i] ^ expectedHash[i];
      }
      return diff == 0;
    } catch (_) {
      return false;
    }
  }

  /// Encodes a PIN into a standard PHC Argon2id string.
  /// Useful for testing, fixtures, and local PIN generation.
  static String generatePhcVerifier(
    String pin, {
    required Uint8List salt,
    int iterations = 3,
    int memory = 65536,
    int parallelism = 1,
  }) {
    final params = Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      salt,
      version: Argon2Parameters.ARGON2_VERSION_13,
      iterations: iterations,
      memory: memory,
      lanes: parallelism,
    );
    final generator = Argon2BytesGenerator()..init(params);
    final hash = Uint8List(32);
    generator.generateBytesFromString(pin, hash);

    final saltB64 = base64Url.encode(salt).replaceAll('=', '');
    final hashB64 = base64Url.encode(hash).replaceAll('=', '');
    return '\$argon2id\$v=19\$m=$memory,t=$iterations,p=$parallelism\$$saltB64\$$hashB64';
  }

  static Uint8List _decodeBase64(String input) {
    var normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    final rem = normalized.length % 4;
    if (rem == 2) normalized += '==';
    if (rem == 3) normalized += '=';
    return base64Decode(normalized);
  }
}
