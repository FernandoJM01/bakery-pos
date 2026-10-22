import {
  generateToken,
  getDummyArgon2Hash,
  hashPassword,
  hashPin,
  hashTokenWithPepper,
  verifyHash,
} from './crypto';

describe('Crypto & Argon2id Hashing', () => {
  it('hashes and verifies a password with argon2id', async () => {
    const password = 'SuperSecretPassword123!';
    const hash = await hashPassword(password);

    expect(hash).toMatch(/^\$argon2id\$/);
    expect(await verifyHash(hash, password)).toBe(true);
    expect(await verifyHash(hash, 'wrong-password')).toBe(false);
  });

  it('generates two distinct argon2id hashes for the same PIN', async () => {
    const pin = '4829';
    const { pinHash, offlinePinVerifier } = await hashPin(pin);

    expect(pinHash).toMatch(/^\$argon2id\$/);
    expect(offlinePinVerifier).toMatch(/^\$argon2id\$/);
    // Two independent salts
    expect(pinHash).not.toEqual(offlinePinVerifier);

    // Both independently verify the PIN
    expect(await verifyHash(pinHash, pin)).toBe(true);
    expect(await verifyHash(offlinePinVerifier, pin)).toBe(true);
    expect(await verifyHash(pinHash, '0000')).toBe(false);
    expect(await verifyHash(offlinePinVerifier, '0000')).toBe(false);
  });

  it('generates 32 random bytes token as 64-character hex string', () => {
    const token1 = generateToken();
    const token2 = generateToken();
    expect(token1).toHaveLength(64);
    expect(token2).toHaveLength(64);
    expect(token1).not.toEqual(token2);
  });

  it('hashes tokens consistently with SHA-256 pepper', () => {
    const token =
      '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
    const pepper = 'my-secret-pepper-for-tests';
    const hash1 = hashTokenWithPepper(token, pepper);
    const hash2 = hashTokenWithPepper(token, pepper);
    expect(hash1).toHaveLength(64);
    expect(hash1).toEqual(hash2);
    expect(hashTokenWithPepper(token, 'other-pepper')).not.toEqual(hash1);
  });

  it('provides a valid argon2id dummy hash for constant-time comparisons', async () => {
    const dummy = await getDummyArgon2Hash();
    expect(dummy).toMatch(/^\$argon2id\$/);
  });
});
