import * as argon2 from 'argon2';

export const ARGON2_OPTIONS: argon2.HashOptions & { raw?: false } = {
  type: argon2.argon2id,
  memoryCost: 65536, // 64 MiB
  timeCost: 3,
  parallelism: 1,
  raw: false,
};

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
