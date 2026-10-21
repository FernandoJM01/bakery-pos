import { hashPassword, hashPin, verifyHash } from './crypto';

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
});
