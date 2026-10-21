import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import type { Server } from 'http';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import {
  getContractAjv,
  validateResponseAgainstContract,
} from './contract-validator';

describe('Health & Foundation (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    process.env.DATABASE_URL =
      process.env.DATABASE_URL ??
      'postgres://pos:pos_dev_only@127.0.0.1:5432/pos_dev';
    process.env.MIGRATION_DATABASE_URL =
      process.env.MIGRATION_DATABASE_URL ??
      process.env.DATABASE_URL ??
      'postgres://pos:pos_dev_only@127.0.0.1:5432/pos_dev';
    process.env.JWT_SECRET =
      process.env.JWT_SECRET ?? 'ci-only-jwt-secret-not-for-production';
    process.env.DEVICE_TOKEN_PEPPER =
      process.env.DEVICE_TOKEN_PEPPER ?? 'ci-only-pepper-not-for-production';

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    configureApp(app);
    await app.init();
  });

  afterAll(async () => {
    if (app) {
      await app.close();
    }
  });

  it('/health (GET) satisfies OpenAPI contract', async () => {
    const server = app.getHttpServer() as Server;
    const response = await request(server).get('/health');

    // Health returns 200 when database is healthy
    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      status: 'ok',
      database: 'ok',
    });

    const validation = validateResponseAgainstContract({
      path: '/health',
      method: 'get',
      status: response.status,
      body: response.body,
    });

    expect(validation.errors).toBeUndefined();
    expect(validation.valid).toBe(true);
    expect(response.body).toHaveProperty('version');
    expect(response.body).toHaveProperty('status');
    expect(response.body).toHaveProperty('database');
  });

  it('serves API routes under /v1 and keeps /health unprefixed', async () => {
    const server = app.getHttpServer() as Server;

    const prefixed = await request(server).get('/v1/health');
    expect(prefixed.status).toBe(404);

    const { ajv } = getContractAjv();
    const validateError = ajv.getSchema('#/components/schemas/Error');
    expect(validateError).toBeDefined();
    expect(validateError!(prefixed.body)).toBe(true);
    expect(prefixed.body).toMatchObject({ code: 'NOT_FOUND' });
  });
});
