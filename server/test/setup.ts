import 'reflect-metadata';

process.env.NODE_ENV = 'test';
process.env.DATABASE_URL =
  process.env.DATABASE_URL ??
  'postgres://pos:pos_dev_only@127.0.0.1:5432/pos_dev';
process.env.JWT_SECRET =
  process.env.JWT_SECRET ?? 'ci-only-jwt-secret-not-for-production';
process.env.DEVICE_TOKEN_PEPPER =
  process.env.DEVICE_TOKEN_PEPPER ?? 'ci-only-pepper-not-for-production';
