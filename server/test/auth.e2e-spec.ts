import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient, Role } from '@prisma/client';
import type { Server } from 'http';
import request from 'supertest';
import { v7 as uuidv7 } from 'uuid';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import { ClockService } from '../src/common/clock.service';
import { hashPassword, hashPin } from '../src/common/crypto';
import { validateResponseAgainstContract } from './contract-validator';

interface AuthResponse {
  code?: string;
  message?: string;
  details?: { lockedUntil?: string };
  accessToken?: string;
  accessTokenExpiresAt?: string;
  refreshToken?: string;
  refreshTokenExpiresAt?: string;
  me?: {
    staff?: { email?: string; passwordHash?: string; pinHash?: string };
    permissions?: string[];
  };
  staff?: { email?: string };
  permissions?: string[];
  deviceId?: string | null;
}

function getBody(res: request.Response): AuthResponse {
  return res.body as AuthResponse;
}

describe('Auth & Session Management (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  let prisma: PrismaClient;
  let clock: ClockService;
  let actualBranchId: string;

  const testBranchId = uuidv7();
  const testStaffId = uuidv7();
  const testPassword = 'PasswordE2E123!';
  const testEmail = 'auth-e2e-owner@bakery.local';

  beforeAll(async () => {
    process.env.DATABASE_URL =
      process.env.DATABASE_URL ??
      'postgres://pos:pos_dev_only@127.0.0.1:5432/pos_dev';
    process.env.MIGRATION_DATABASE_URL =
      process.env.MIGRATION_DATABASE_URL ?? process.env.DATABASE_URL;
    process.env.JWT_SECRET =
      process.env.JWT_SECRET ?? 'ci-only-jwt-secret-not-for-production-min-32';
    process.env.DEVICE_TOKEN_PEPPER =
      process.env.DEVICE_TOKEN_PEPPER ??
      'ci-only-pepper-not-for-production-min-32';

    prisma = new PrismaClient({
      datasources: { db: { url: process.env.DATABASE_URL } },
    });
    await prisma.$connect();

    // Setup test branch and staff
    const branch = await prisma.branch.upsert({
      where: { code: 'SUCE2E' },
      update: {},
      create: {
        id: testBranchId,
        code: 'SUCE2E',
        name: 'Sucursal E2E',
        isActive: true,
      },
    });
    actualBranchId = branch.id;

    const passwordHash = await hashPassword(testPassword);
    const { pinHash, offlinePinVerifier } = await hashPin('4829');

    await prisma.staff.upsert({
      where: { email: testEmail },
      update: {
        passwordHash,
        failedPasswordAttempts: 0,
        passwordFailureWindowStart: null,
        passwordLockedUntil: null,
        failedPinAttempts: 0,
        lockedUntil: null,
        isActive: true,
      },
      create: {
        id: testStaffId,
        fullName: 'E2E Owner Tester',
        displayName: 'E2E Owner',
        role: Role.OWNER,
        email: testEmail,
        passwordHash,
        pinHash,
        offlinePinVerifier,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: {
          create: [{ branchId: actualBranchId }],
        },
      },
    });

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    configureApp(app);
    await app.init();
    server = app.getHttpServer() as Server;
    clock = app.get(ClockService);
  });

  beforeEach(() => {
    clock.setNow(null);
  });

  afterAll(async () => {
    if (app) {
      await app.close();
    }
    await prisma.$disconnect();
  });

  it('rejects login with unknown email (401 AUTH_INVALID_CREDENTIALS)', async () => {
    const res = await request(server).post('/v1/auth/password-login').send({
      email: 'nonexistent@bakery.local',
      password: 'SomePassword123!',
    });

    expect(res.status).toBe(401);
    const body = getBody(res);
    expect(body.code).toBe('AUTH_INVALID_CREDENTIALS');

    const validation = validateResponseAgainstContract({
      path: '/v1/auth/password-login',
      method: 'post',
      status: 401,
      body: res.body,
    });
    expect(validation.valid).toBe(true);
  });

  it('rejects login with wrong password (401 AUTH_INVALID_CREDENTIALS)', async () => {
    const res = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: testEmail, password: 'WrongPassword999!' });

    expect(res.status).toBe(401);
    const body = getBody(res);
    expect(body.code).toBe('AUTH_INVALID_CREDENTIALS');

    const validation = validateResponseAgainstContract({
      path: '/v1/auth/password-login',
      method: 'post',
      status: 401,
      body: res.body,
    });
    expect(validation.valid).toBe(true);
  });

  it('locks account after 10 failed login attempts (423 AUTH_LOCKED)', async () => {
    const lockoutEmail = 'lockout-test@bakery.local';
    const passwordHash = await hashPassword('ValidPass123!');
    const { pinHash, offlinePinVerifier } = await hashPin('1234');

    await prisma.staff.upsert({
      where: { email: lockoutEmail },
      update: {
        failedPasswordAttempts: 9,
        passwordFailureWindowStart: new Date(),
        passwordLockedUntil: null,
      },
      create: {
        id: uuidv7(),
        fullName: 'Lockout Tester',
        displayName: 'Lockout',
        role: Role.OWNER,
        email: lockoutEmail,
        passwordHash,
        pinHash,
        offlinePinVerifier,
        pinUpdatedAt: new Date(),
        failedPasswordAttempts: 9,
        passwordFailureWindowStart: new Date(),
        staffBranches: { create: [{ branchId: actualBranchId }] },
      },
    });

    // 10th failure -> locks account
    const fail10 = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: lockoutEmail, password: 'WrongPassword!' });
    expect(fail10.status).toBe(423);
    const body10 = getBody(fail10);
    expect(body10.code).toBe('AUTH_LOCKED');
    expect(body10.details?.lockedUntil).toBeDefined();

    // Next attempt during lockout -> 423 AUTH_LOCKED
    const lockedRes = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: lockoutEmail, password: 'ValidPass123!' });
    expect(lockedRes.status).toBe(423);
    const lockedBody = getBody(lockedRes);
    expect(lockedBody.code).toBe('AUTH_LOCKED');

    const validation = validateResponseAgainstContract({
      path: '/v1/auth/password-login',
      method: 'post',
      status: 423,
      body: lockedRes.body,
    });
    expect(validation.valid).toBe(true);

    // The back office lockout must not lock the till PIN.
    const locked = await prisma.staff.findUniqueOrThrow({
      where: { email: lockoutEmail },
    });
    expect(locked.passwordLockedUntil).not.toBeNull();
    expect(locked.lockedUntil).toBeNull();
    expect(locked.failedPinAttempts).toBe(0);
  });

  it('lock expires, then one wrong password does not re-lock (controllable clock)', async () => {
    const expireEmail = 'lock-expire-test@bakery.local';
    const passwordHash = await hashPassword('ValidPass123!');
    const { pinHash, offlinePinVerifier } = await hashPin('1234');
    const baseTime = new Date('2026-10-21T10:00:00Z');
    clock.setNow(baseTime);

    await prisma.staff.upsert({
      where: { email: expireEmail },
      update: {
        failedPasswordAttempts: 9,
        passwordFailureWindowStart: baseTime,
        passwordLockedUntil: null,
      },
      create: {
        id: uuidv7(),
        fullName: 'Expire Lock Tester',
        displayName: 'ExpireLock',
        role: Role.OWNER,
        email: expireEmail,
        passwordHash,
        pinHash,
        offlinePinVerifier,
        pinUpdatedAt: baseTime,
        failedPasswordAttempts: 9,
        passwordFailureWindowStart: baseTime,
        staffBranches: { create: [{ branchId: actualBranchId }] },
      },
    });

    // 10th wrong password locks account until baseTime + 15m
    const lockRes = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: expireEmail, password: 'WrongPassword!' });
    expect(lockRes.status).toBe(423);

    // Fast-forward 16 minutes: lock has expired
    clock.advance(16 * 60 * 1000);

    // One wrong password after lock expired must NOT re-lock; it should be attempt 1 (401 AUTH_INVALID_CREDENTIALS)
    const afterExpireRes = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: expireEmail, password: 'WrongPasswordAgain!' });
    expect(afterExpireRes.status).toBe(401);
    expect(getBody(afterExpireRes).code).toBe('AUTH_INVALID_CREDENTIALS');

    // Confirm in DB that counter is 1 and lockedUntil is null
    const staff = await prisma.staff.findUnique({
      where: { email: expireEmail },
    });
    expect(staff?.failedPasswordAttempts).toBe(1);
    expect(staff?.passwordLockedUntil).toBeNull();
  });

  it('9 failures, wait 15 minutes, 1 failure does not lock (controllable clock)', async () => {
    const windowEmail = 'window-test@bakery.local';
    const passwordHash = await hashPassword('ValidPass123!');
    const { pinHash, offlinePinVerifier } = await hashPin('1234');
    const baseTime = new Date('2026-10-21T10:00:00Z');
    clock.setNow(baseTime);

    await prisma.staff.upsert({
      where: { email: windowEmail },
      update: {
        failedPasswordAttempts: 9,
        passwordFailureWindowStart: baseTime,
        passwordLockedUntil: null,
      },
      create: {
        id: uuidv7(),
        fullName: 'Window Tester',
        displayName: 'WindowTest',
        role: Role.OWNER,
        email: windowEmail,
        passwordHash,
        pinHash,
        offlinePinVerifier,
        pinUpdatedAt: baseTime,
        failedPasswordAttempts: 9,
        passwordFailureWindowStart: baseTime,
        staffBranches: { create: [{ branchId: actualBranchId }] },
      },
    });

    // Advance clock past the 15-minute failure window (16 minutes)
    clock.advance(16 * 60 * 1000);

    // 1 more wrong password after window expired resets the window; does NOT lock!
    const res = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: windowEmail, password: 'WrongPassword!' });

    expect(res.status).toBe(401);
    expect(getBody(res).code).toBe('AUTH_INVALID_CREDENTIALS');

    const staff = await prisma.staff.findUnique({
      where: { email: windowEmail },
    });
    expect(staff?.failedPasswordAttempts).toBe(1);
    expect(staff?.passwordLockedUntil).toBeNull();
  });

  it('inactive account returns AUTH_INVALID_CREDENTIALS for both right and wrong passwords', async () => {
    const inactiveEmail = 'inactive-check@bakery.local';
    const rightPassword = 'RightPassword123!';
    const passwordHash = await hashPassword(rightPassword);
    const { pinHash, offlinePinVerifier } = await hashPin('1234');

    await prisma.staff.upsert({
      where: { email: inactiveEmail },
      update: { isActive: false, passwordHash },
      create: {
        id: uuidv7(),
        fullName: 'Inactive Checker',
        displayName: 'InactiveCheck',
        role: Role.CASHIER,
        email: inactiveEmail,
        passwordHash,
        pinHash,
        offlinePinVerifier,
        pinUpdatedAt: new Date(),
        isActive: false,
        staffBranches: { create: [{ branchId: actualBranchId }] },
      },
    });

    // Right password on inactive account -> 401 AUTH_INVALID_CREDENTIALS
    const rightRes = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: inactiveEmail, password: rightPassword });
    expect(rightRes.status).toBe(401);
    expect(getBody(rightRes).code).toBe('AUTH_INVALID_CREDENTIALS');

    // Wrong password on inactive account -> 401 AUTH_INVALID_CREDENTIALS
    const wrongRes = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: inactiveEmail, password: 'WrongPassword999!' });
    expect(wrongRes.status).toBe(401);
    expect(getBody(wrongRes).code).toBe('AUTH_INVALID_CREDENTIALS');
  });

  it('logs in successfully, satisfies contract, and does not leak hashes (A11)', async () => {
    const res = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: testEmail, password: testPassword });

    expect(res.status).toBe(200);
    const body = getBody(res);
    expect(body.accessToken).toBeDefined();
    expect(body.refreshToken).toBeDefined();
    expect(body.me?.staff?.email).toBe(testEmail);
    expect(body.me?.permissions?.length).toBe(26);

    // Contract validation
    const validation = validateResponseAgainstContract({
      path: '/v1/auth/password-login',
      method: 'post',
      status: 200,
      body: res.body,
    });
    expect(validation.valid).toBe(true);

    // A11: No response body contains pinHash, passwordHash, or offlinePinVerifier
    const jsonString = JSON.stringify(res.body);
    expect(jsonString).not.toContain('pinHash');
    expect(jsonString).not.toContain('passwordHash');
    expect(jsonString).not.toContain('offlinePinVerifier');
    expect(jsonString).not.toContain('pin_hash');
    expect(jsonString).not.toContain('password_hash');
  });

  it('retrieves current user with GET /v1/me', async () => {
    const loginRes = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: testEmail, password: testPassword });

    const loginBody = getBody(loginRes);
    const accessToken = loginBody.accessToken;
    expect(accessToken).toBeDefined();

    const meRes = await request(server)
      .get('/v1/me')
      .set('Authorization', `Bearer ${accessToken!}`);

    expect(meRes.status).toBe(200);
    const meBody = getBody(meRes);
    expect(meBody.staff?.email).toBe(testEmail);
    expect(meBody.permissions).toBeDefined();
    expect(meBody.deviceId).toBeNull();

    const validation = validateResponseAgainstContract({
      path: '/v1/me',
      method: 'get',
      status: 200,
      body: meRes.body,
    });
    expect(validation.valid).toBe(true);

    // A11 check on /v1/me
    const jsonString = JSON.stringify(meRes.body);
    expect(jsonString).not.toContain('pinHash');
    expect(jsonString).not.toContain('passwordHash');
    expect(jsonString).not.toContain('offlinePinVerifier');
  });

  it('rotates refresh token and detects reuse', async () => {
    const loginRes = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: testEmail, password: testPassword });

    const loginBody = getBody(loginRes);
    const oldRefreshToken = loginBody.refreshToken;
    expect(oldRefreshToken).toBeDefined();

    // First refresh: rotates tokens successfully
    const refreshRes = await request(server)
      .post('/v1/auth/refresh')
      .send({ refreshToken: oldRefreshToken! });

    expect(refreshRes.status).toBe(200);
    const refreshBody = getBody(refreshRes);
    expect(refreshBody.accessToken).toBeDefined();
    expect(refreshBody.refreshToken).toBeDefined();
    expect(refreshBody.refreshToken).not.toBe(oldRefreshToken);

    const validation = validateResponseAgainstContract({
      path: '/v1/auth/refresh',
      method: 'post',
      status: 200,
      body: refreshRes.body,
    });
    expect(validation.valid).toBe(true);

    const newRefreshToken = refreshBody.refreshToken;
    expect(newRefreshToken).toBeDefined();

    // Reuse detection: call refresh again with the already-rotated oldRefreshToken
    const reuseRes = await request(server)
      .post('/v1/auth/refresh')
      .send({ refreshToken: oldRefreshToken! });

    expect(reuseRes.status).toBe(401);
    const reuseBody = getBody(reuseRes);
    expect(reuseBody.code).toBe('AUTH_REFRESH_INVALID');

    // The whole session was revoked upon reuse; the new refresh token is now also refused
    const newRefreshAfterRevoke = await request(server)
      .post('/v1/auth/refresh')
      .send({ refreshToken: newRefreshToken! });

    expect(newRefreshAfterRevoke.status).toBe(401);
    const newRefreshBody = getBody(newRefreshAfterRevoke);
    expect(newRefreshBody.code).toBe('AUTH_REFRESH_INVALID');
  });

  it('fires two refreshes with the same token in parallel and expects exactly one success', async () => {
    const loginRes = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: testEmail, password: testPassword });

    const loginBody = getBody(loginRes);
    const refreshToken = loginBody.refreshToken;
    expect(refreshToken).toBeDefined();

    // Fire two refreshes in parallel with the exact same refresh token
    const [res1, res2] = await Promise.all([
      request(server)
        .post('/v1/auth/refresh')
        .send({ refreshToken: refreshToken! }),
      request(server)
        .post('/v1/auth/refresh')
        .send({ refreshToken: refreshToken! }),
    ]);

    const statuses = [res1.status, res2.status].sort();
    expect(statuses).toEqual([200, 401]);

    const failed = res1.status === 401 ? res1 : res2;
    const failedBody = getBody(failed);
    expect(failedBody.code).toBe('AUTH_REFRESH_INVALID');
  });

  it('refuses access token for a deactivated staff member', async () => {
    const deactivatedEmail = 'deactivated-staff@bakery.local';
    const passwordHash = await hashPassword('ValidPass123!');
    const { pinHash, offlinePinVerifier } = await hashPin('1234');
    const staffId = uuidv7();

    await prisma.staff.upsert({
      where: { email: deactivatedEmail },
      update: { isActive: true },
      create: {
        id: staffId,
        fullName: 'Deactivated Tester',
        displayName: 'Deactivated',
        role: Role.CASHIER,
        email: deactivatedEmail,
        passwordHash,
        pinHash,
        offlinePinVerifier,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: { create: [{ branchId: actualBranchId }] },
      },
    });

    const loginRes = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: deactivatedEmail, password: 'ValidPass123!' });

    expect(loginRes.status).toBe(200);
    const loginBody = getBody(loginRes);
    const token = loginBody.accessToken;
    expect(token).toBeDefined();

    // Deactivate staff in database
    await prisma.staff.update({
      where: { email: deactivatedEmail },
      data: { isActive: false },
    });

    // Request with token should now be refused with 401 AUTH_REQUIRED
    const meRes = await request(server)
      .get('/v1/me')
      .set('Authorization', `Bearer ${token!}`);

    expect(meRes.status).toBe(401);
    const meBody = getBody(meRes);
    expect(meBody.code).toBe('AUTH_REQUIRED');
  });

  it('revokes session on logout (204 No Content)', async () => {
    const loginRes = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: testEmail, password: testPassword });

    const loginBody = getBody(loginRes);
    const token = loginBody.accessToken;
    expect(token).toBeDefined();

    const logoutRes = await request(server)
      .post('/v1/auth/logout')
      .set('Authorization', `Bearer ${token!}`);

    expect(logoutRes.status).toBe(204);

    // After logout, token is no longer accepted
    const meRes = await request(server)
      .get('/v1/me')
      .set('Authorization', `Bearer ${token!}`);

    expect(meRes.status).toBe(401);
    const meBody = getBody(meRes);
    expect(meBody.code).toBe('AUTH_REQUIRED');
  });

  it('the auth guard follows the app clock: a back office session ends after 12 hours', async () => {
    const loginRes = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: testEmail, password: testPassword });
    const accessToken = getBody(loginRes).accessToken;
    expect(accessToken).toBeDefined();

    clock.setNow(new Date(Date.now() + 12 * 60 * 60 * 1000 + 60_000));
    const meRes = await request(server)
      .get('/v1/me')
      .set('Authorization', `Bearer ${accessToken!}`);

    expect(meRes.status).toBe(401);
    expect(getBody(meRes).code).toBe('AUTH_REQUIRED');
  });
});
