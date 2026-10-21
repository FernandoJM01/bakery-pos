import { validateEnv } from './env.validation';

describe('Environment validation', () => {
  const validBaseEnv = {
    DATABASE_URL: 'postgres://pos:pos_dev@localhost:5432/pos_dev',
    JWT_SECRET: 'test-jwt-secret-key-super-secure',
    DEVICE_TOKEN_PEPPER: 'test-device-pepper-super-secure',
  };

  it('A3: refuses to start when DATABASE_URL is missing', () => {
    const env = { ...validBaseEnv };
    delete (env as Record<string, unknown>).DATABASE_URL;

    expect(() => validateEnv(env)).toThrow(
      'Server refuses to start: required environment variable(s) missing or invalid: DATABASE_URL',
    );
  });

  it('A3: refuses to start when JWT_SECRET is missing', () => {
    const env = { ...validBaseEnv };
    delete (env as Record<string, unknown>).JWT_SECRET;

    expect(() => validateEnv(env)).toThrow(
      'Server refuses to start: required environment variable(s) missing or invalid: JWT_SECRET',
    );
  });

  it('A3: refuses to start when DEVICE_TOKEN_PEPPER is missing', () => {
    const env = { ...validBaseEnv };
    delete (env as Record<string, unknown>).DEVICE_TOKEN_PEPPER;

    expect(() => validateEnv(env)).toThrow(
      'Server refuses to start: required environment variable(s) missing or invalid: DEVICE_TOKEN_PEPPER',
    );
  });

  it('A3: refuses to start when multiple required secrets are missing', () => {
    expect(() => validateEnv({})).toThrow(/Server refuses to start/);
  });

  it('A3: accepts configuration when all required secrets are present', () => {
    const result = validateEnv(validBaseEnv);
    expect(result.DATABASE_URL).toBe(validBaseEnv.DATABASE_URL);
    expect(result.JWT_SECRET).toBe(validBaseEnv.JWT_SECRET);
    expect(result.DEVICE_TOKEN_PEPPER).toBe(validBaseEnv.DEVICE_TOKEN_PEPPER);
    expect(result.PORT).toBe(3000);
    expect(result.APP_VERSION).toBe('0.1.0-m1');
  });

  it('A3: refuses to start in production when JWT_SECRET or DEVICE_TOKEN_PEPPER is shorter than 32 characters', () => {
    const prodShortEnv = {
      ...validBaseEnv,
      NODE_ENV: 'production',
      JWT_SECRET: 'short-secret-less-than-32-chars',
      DEVICE_TOKEN_PEPPER: 'short-pepper',
    };

    expect(() => validateEnv(prodShortEnv)).toThrow(
      'Server refuses to start: required environment variable(s) missing or invalid: JWT_SECRET (min 32 chars in production), DEVICE_TOKEN_PEPPER (min 32 chars in production)',
    );
  });

  it('A3: accepts production secrets of 32+ characters and development accepts short secrets', () => {
    const devShortEnv = {
      ...validBaseEnv,
      NODE_ENV: 'development',
      JWT_SECRET: 'change-me-dev-only',
      DEVICE_TOKEN_PEPPER: 'change-me-dev-only',
    };
    const devResult = validateEnv(devShortEnv);
    expect(devResult.JWT_SECRET).toBe('change-me-dev-only');

    const prodValidEnv = {
      ...validBaseEnv,
      NODE_ENV: 'production',
      JWT_SECRET: 'a'.repeat(32),
      DEVICE_TOKEN_PEPPER: 'b'.repeat(32),
    };
    const prodResult = validateEnv(prodValidEnv);
    expect(prodResult.JWT_SECRET).toBe('a'.repeat(32));
    expect(prodResult.DEVICE_TOKEN_PEPPER).toBe('b'.repeat(32));
  });
});
