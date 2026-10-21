import { createHmac, randomBytes } from 'crypto';
import * as argon2 from 'argon2';

export const ARGON2_OPTIONS: argon2.HashOptions & { raw?: false } = {
  type: argon2.argon2id,
  memoryCost: 65536, // 64 MiB
  timeCost: 3,
  parallelism: 1,
  raw: false,
};

let cachedDummyArgon2Hash: string | null = null;

/**
 * Returns a precomputed valid argon2id hash for constant-time comparison on unknown users.
 */
export async function getDummyArgon2Hash(): Promise<string> {
  if (!cachedDummyArgon2Hash) {
    cachedDummyArgon2Hash = await argon2.hash(
      'dummy-secret-constant-time',
      ARGON2_OPTIONS,
    );
  }
  return cachedDummyArgon2Hash;
}

/**
 * Generates 32 random bytes as a hex string (opaque tokens).
 */
export function generateToken(): string {
  return randomBytes(32).toString('hex');
}

/**
 * Computes SHA-256 HMAC of a token using the server pepper.
 */
export function hashTokenWithPepper(token: string, pepper: string): string {
  return createHmac('sha256', pepper).update(token).digest('hex');
}

/**
 * Hashes a password using argon2id (m=65536, t=3, p=1).
 */
export async function hashPassword(password: string): Promise<string> {
  return argon2.hash(password, ARGON2_OPTIONS);
}

/**
 * Generates two independent argon2id hashes for a staff PIN:
 * - pinHash: used for online verification
 * - offlinePinVerifier: sent to till devices for local offline authentication
 */
export async function hashPin(pin: string): Promise<{
  pinHash: string;
  offlinePinVerifier: string;
}> {
  const [pinHash, offlinePinVerifier] = await Promise.all([
    argon2.hash(pin, ARGON2_OPTIONS),
    argon2.hash(pin, ARGON2_OPTIONS),
  ]);

  return { pinHash, offlinePinVerifier };
}

/**
 * Verifies a plaintext secret against an argon2id hash.
 */
export async function verifyHash(
  hash: string,
  plain: string,
): Promise<boolean> {
  return argon2.verify(hash, plain);
}
