import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { DeviceType, PrismaClient, Role } from '@prisma/client';
import type { Server } from 'http';
import request from 'supertest';
import { v7 as uuidv7 } from 'uuid';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import { ClockService } from '../src/common/clock.service';
import { hashPassword, hashPin } from '../src/common/crypto';
import { validateResponseAgainstContract } from './contract-validator';

interface BodyWithCode {
  code?: string;
  message?: string;
  status?: string;
  branchId?: string;
  device?: {
    id: string;
    branchId: string;
    name: string;
    type: string;
    status: string;
    lastSeenAt: string | null;
    appVersion: string | null;
    createdAt: string;
    revokedAt: string | null;
  };
  enrollmentCode?: string;
  expiresAt?: string;
  deviceToken?: string;
  branch?: { id: string; code: string; name: string };
  staff?: Array<{
    id: string;
    displayName: string;
    role: string;
    offlinePinVerifier: string;
    pinUpdatedAt: string;
  }>;
  roles?: Record<string, string[]>;
}

function getBody(res: request.Response): BodyWithCode {
  return res.body as BodyWithCode;
}

describe('Devices & Enrollment (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  let prisma: PrismaClient;
  let clock: ClockService;

  let branchId: string;
  let ownerToken: string;
  let cashierToken: string;

  const ownerEmail = 'devices-owner@bakery.local';
  const ownerPassword = 'OwnerPass123!';
  const cashierEmail = 'devices-cashier@bakery.local';
  const cashierPassword = 'CashierPass123!';

  beforeAll(async () => {
    prisma = new PrismaClient({
      datasources: { db: { url: process.env.DATABASE_URL } },
    });
    await prisma.$connect();

    // Create test branch
    const branch = await prisma.branch.upsert({
      where: { code: 'SUCDEV' },
      update: {},
      create: {
        id: uuidv7(),
        code: 'SUCDEV',
        name: 'Sucursal Devices',
        timezone: 'America/Mexico_City',
        isActive: true,
      },
    });
    branchId = branch.id;

    // Create owner staff
    const ownerPassHash = await hashPassword(ownerPassword);
    const ownerPinHashes = await hashPin('1111');
    await prisma.staff.upsert({
      where: { email: ownerEmail },
      update: {
        passwordHash: ownerPassHash,
        isActive: true,
        failedPasswordAttempts: 0,
        passwordLockedUntil: null,
      },
      create: {
        id: uuidv7(),
        fullName: 'Devices Owner',
        displayName: 'DevOwner',
        role: Role.OWNER,
        email: ownerEmail,
        passwordHash: ownerPassHash,
        pinHash: ownerPinHashes.pinHash,
        offlinePinVerifier: ownerPinHashes.offlinePinVerifier,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: { create: [{ branchId }] },
      },
    });

    // Create cashier staff
    const cashierPassHash = await hashPassword(cashierPassword);
    const cashierPinHashes = await hashPin('2222');
    await prisma.staff.upsert({
      where: { email: cashierEmail },
      update: {
        passwordHash: cashierPassHash,
        isActive: true,
        failedPasswordAttempts: 0,
        passwordLockedUntil: null,
      },
      create: {
        id: uuidv7(),
        fullName: 'Devices Cashier',
        displayName: 'DevCashier',
        role: Role.CASHIER,
        email: cashierEmail,
        passwordHash: cashierPassHash,
        pinHash: cashierPinHashes.pinHash,
        offlinePinVerifier: cashierPinHashes.offlinePinVerifier,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: { create: [{ branchId }] },
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

    // Obtain owner token
    const ownerLogin = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: ownerEmail, password: ownerPassword });
    ownerToken = (ownerLogin.body as { accessToken: string }).accessToken;

    // Obtain cashier token
    const cashierLogin = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: cashierEmail, password: cashierPassword });
    cashierToken = (cashierLogin.body as { accessToken: string }).accessToken;
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

  it('cashier calling POST /v1/devices gets 403 PERMISSION_DENIED', async () => {
    const res = await request(server)
      .post('/v1/devices')
      .set('Authorization', `Bearer ${cashierToken}`)
      .send({
        branchId,
        name: 'Caja 1',
        type: DeviceType.TILL,
      });

    expect(res.status).toBe(403);
    const body = getBody(res);
    expect(body.code).toBe('PERMISSION_DENIED');
  });

  it('POST /v1/devices creates a PENDING device, returns enrollment code, and satisfies contract (A11)', async () => {
    const res = await request(server)
      .post('/v1/devices')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        branchId,
        name: 'Caja Principal',
        type: DeviceType.TILL,
      });

    expect(res.status).toBe(201);
    const body = getBody(res);
    expect(body.device?.status).toBe('PENDING');
    expect(body.device?.name).toBe('Caja Principal');
    expect(body.enrollmentCode).toMatch(/^[A-HJ-NP-Z2-9]{8}$/);
    expect(body.expiresAt).toBeDefined();

    // Contract validation
    const validation = validateResponseAgainstContract({
      path: '/v1/devices',
      method: 'post',
      status: 201,
      body: res.body,
    });
    expect(validation.valid).toBe(true);

    // A11 check: no hashes anywhere in response
    const jsonStr = JSON.stringify(res.body);
    expect(jsonStr).not.toContain('Hash');
    expect(jsonStr).not.toContain('pinHash');
    expect(jsonStr).not.toContain('passwordHash');
  });

  it('GET /v1/devices lists devices and supports branchId filtering', async () => {
    const res = await request(server)
      .get(`/v1/devices?branchId=${branchId}`)
      .set('Authorization', `Bearer ${ownerToken}`);

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect((res.body as unknown[]).length).toBeGreaterThan(0);

    const validation = validateResponseAgainstContract({
      path: '/v1/devices',
      method: 'get',
      status: 200,
      body: res.body,
    });
    expect(validation.valid).toBe(true);
  });

  it('A7: code works once, fails the second time, and fails after 30 minutes (controllable clock)', async () => {
    const baseTime = new Date('2026-10-21T12:00:00Z');
    clock.setNow(baseTime);

    // Create device
    const createRes = await request(server)
      .post('/v1/devices')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        branchId,
        name: 'Till A7',
        type: DeviceType.TILL,
      });
    expect(createRes.status).toBe(201);
    const code = getBody(createRes).enrollmentCode!;

    // 1. Activate device for the first time -> 200 OK
    const activateRes = await request(server)
      .post('/v1/devices/activate')
      .send({
        enrollmentCode: code,
        appVersion: '1.0.0',
      });
    expect(activateRes.status).toBe(200);
    const activateBody = getBody(activateRes);
    expect(activateBody.deviceToken).toBeDefined();
    expect(activateBody.device?.status).toBe('ACTIVE');

    const activateValidation = validateResponseAgainstContract({
      path: '/v1/devices/activate',
      method: 'post',
      status: 200,
      body: activateRes.body,
    });
    expect(activateValidation.valid).toBe(true);

    // 2. Code used a second time -> 410 DEVICE_CODE_INVALID
    const secondUseRes = await request(server)
      .post('/v1/devices/activate')
      .send({
        enrollmentCode: code,
        appVersion: '1.0.0',
      });
    expect(secondUseRes.status).toBe(410);
    expect(getBody(secondUseRes).code).toBe('DEVICE_CODE_INVALID');

    // 3. Create another device and test expiry after 30 minutes
    const createRes2 = await request(server)
      .post('/v1/devices')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        branchId,
        name: 'Till A7 Expire',
        type: DeviceType.TILL,
      });
    expect(createRes2.status).toBe(201);
    const code2 = getBody(createRes2).enrollmentCode!;
    const device2Id = getBody(createRes2).device!.id;

    // Advance clock past 30 minutes (31 minutes)
    clock.advance(31 * 60 * 1000);

    const expiredRes = await request(server).post('/v1/devices/activate').send({
      enrollmentCode: code2,
      appVersion: '1.0.0',
    });
    expect(expiredRes.status).toBe(410);
    expect(getBody(expiredRes).code).toBe('DEVICE_CODE_INVALID');

    // Regenerating enrollment code issues a fresh code
    const regenRes = await request(server)
      .post(`/v1/devices/${device2Id}/enrollment-code`)
      .set('Authorization', `Bearer ${ownerToken}`);
    expect(regenRes.status).toBe(201);
    const newCode = getBody(regenRes).enrollmentCode!;
    expect(newCode).not.toBe(code2);

    // New code activates successfully
    const activateNewRes = await request(server)
      .post('/v1/devices/activate')
      .send({
        enrollmentCode: newCode,
        appVersion: '1.0.0',
      });
    expect(activateNewRes.status).toBe(200);
    expect(getBody(activateNewRes).device?.status).toBe('ACTIVE');

    // Calling regenerateEnrollmentCode on an ACTIVE device returns 409 CONFLICT
    const conflictRes = await request(server)
      .post(`/v1/devices/${device2Id}/enrollment-code`)
      .set('Authorization', `Bearer ${ownerToken}`);
    expect(conflictRes.status).toBe(409);
    expect(getBody(conflictRes).code).toBe('CONFLICT');
  });

  it('A6: unknown token and revoked token are rejected on routes marked x-device: required', async () => {
    // 1. Missing token -> 401 DEVICE_UNKNOWN
    const missingRes = await request(server).get('/v1/devices/me/staff');
    expect(missingRes.status).toBe(401);
    expect(getBody(missingRes).code).toBe('DEVICE_UNKNOWN');

    // 2. Unknown token -> 401 DEVICE_UNKNOWN
    const unknownRes = await request(server)
      .get('/v1/devices/me/staff')
      .set(
        'X-Device-Token',
        '0000000000000000000000000000000000000000000000000000000000000000',
      );
    expect(unknownRes.status).toBe(401);
    expect(getBody(unknownRes).code).toBe('DEVICE_UNKNOWN');

    // 3. Create and activate a device
    const createRes = await request(server)
      .post('/v1/devices')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        branchId,
        name: 'Till A6',
        type: DeviceType.TILL,
      });
    const deviceId = getBody(createRes).device!.id;
    const code = getBody(createRes).enrollmentCode!;

    const activateRes = await request(server)
      .post('/v1/devices/activate')
      .send({ enrollmentCode: code, appVersion: '1.0.0' });
    const deviceToken = getBody(activateRes).deviceToken!;

    // 4. Valid token -> 200 OK with StaffBundle
    const staffRes = await request(server)
      .get('/v1/devices/me/staff')
      .set('X-Device-Token', deviceToken);
    expect(staffRes.status).toBe(200);
    const bundle = getBody(staffRes);
    expect(bundle.branchId).toBe(branchId);
    expect(Array.isArray(bundle.staff)).toBe(true);
    expect(bundle.roles?.OWNER).toBeDefined();

    const staffValidation = validateResponseAgainstContract({
      path: '/v1/devices/me/staff',
      method: 'get',
      status: 200,
      body: staffRes.body,
    });
    expect(staffValidation.valid).toBe(true);

    // A11 check on staff bundle
    const staffJson = JSON.stringify(staffRes.body);
    expect(staffJson).not.toContain('pinHash');
    expect(staffJson).not.toContain('passwordHash');

    // 5. Revoke the device
    const revokeRes = await request(server)
      .post(`/v1/devices/${deviceId}/revoke`)
      .set('Authorization', `Bearer ${ownerToken}`);
    expect(revokeRes.status).toBe(200);
    expect(getBody(revokeRes).status).toBe('REVOKED');

    // 6. Calling with revoked token -> 401 DEVICE_REVOKED
    const revokedRes = await request(server)
      .get('/v1/devices/me/staff')
      .set('X-Device-Token', deviceToken);
    expect(revokedRes.status).toBe(401);
    expect(getBody(revokedRes).code).toBe('DEVICE_REVOKED');
  });

  it('revoke device kills the device sessions in the same transaction', async () => {
    // 1. Create and activate a device
    const createRes = await request(server)
      .post('/v1/devices')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        branchId,
        name: 'Till Revoke Session',
        type: DeviceType.TILL,
      });
    const deviceId = getBody(createRes).device!.id;
    const code = getBody(createRes).enrollmentCode!;

    await request(server)
      .post('/v1/devices/activate')
      .send({ enrollmentCode: code, appVersion: '1.0.0' });

    // Create an auth_session tied to this device
    const sessionId = uuidv7();
    const tokenHash = uuidv7();
    await prisma.authSession.create({
      data: {
        id: sessionId,
        staffId: (await prisma.staff.findFirst({
          where: { email: ownerEmail },
        }))!.id,
        deviceId,
        refreshTokenHash: tokenHash,
        expiresAt: new Date(Date.now() + 12 * 60 * 60 * 1000),
      },
    });

    // Revoke device
    const revokeRes = await request(server)
      .post(`/v1/devices/${deviceId}/revoke`)
      .set('Authorization', `Bearer ${ownerToken}`);
    expect(revokeRes.status).toBe(200);

    // Verify session revokedAt is now populated
    const session = await prisma.authSession.findUnique({
      where: { id: sessionId },
    });
    expect(session?.revokedAt).not.toBeNull();
  });

  it('records audit rows for device.created, device.activated, and device.revoked', async () => {
    const auditRows = await prisma.auditLog.findMany({
      where: {
        action: {
          in: ['device.created', 'device.activated', 'device.revoked'],
        },
      },
    });

    const actions = auditRows.map((r) => r.action);
    expect(actions).toContain('device.created');
    expect(actions).toContain('device.activated');
    expect(actions).toContain('device.revoked');
  });

  it('A7: two simultaneous activations with one code: exactly one succeeds', async () => {
    clock.setNow(null);
    const createRes = await request(server)
      .post('/v1/devices')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ branchId, name: 'Till race', type: DeviceType.TILL });
    expect(createRes.status).toBe(201);
    const code = getBody(createRes).enrollmentCode!;

    const results = await Promise.all(
      [1, 2].map(() =>
        request(server)
          .post('/v1/devices/activate')
          .send({ enrollmentCode: code, appVersion: '1.0.0' }),
      ),
    );

    expect(results.map((r) => r.status).sort()).toEqual([200, 410]);
    const winner = results.find((r) => r.status === 200)!;
    const token = getBody(winner).deviceToken!;

    // The winner's token is the one stored, so it works.
    const bundleRes = await request(server)
      .get('/v1/devices/me/staff')
      .set('X-Device-Token', token);
    expect(bundleRes.status).toBe(200);
  });
});
