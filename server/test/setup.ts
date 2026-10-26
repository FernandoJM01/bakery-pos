import 'reflect-metadata';
import 'dotenv/config';

process.env.NODE_ENV = 'test';
process.env.DATABASE_URL =
  process.env.DATABASE_URL ??
  'postgres://pos_app:pos_app_dev_only@127.0.0.1:5432/pos_dev';
process.env.MIGRATION_DATABASE_URL =
  process.env.MIGRATION_DATABASE_URL ??
  process.env.DATABASE_URL ??
  'postgres://pos:pos_dev_only@127.0.0.1:5432/pos_dev';
process.env.JWT_SECRET =
  process.env.JWT_SECRET ?? 'ci-only-jwt-secret-not-for-production';
process.env.DEVICE_TOKEN_PEPPER =
  process.env.DEVICE_TOKEN_PEPPER ?? 'ci-only-pepper-not-for-production';
