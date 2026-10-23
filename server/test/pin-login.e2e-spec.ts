import {
  ConflictException,
  HttpException,
  INestApplication,
} from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { DeviceStatus, DeviceType, PrismaClient, Role } from '@prisma/client';
import type { Server } from 'http';
import request from 'supertest';
import { v7 as uuidv7 } from 'uuid';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import { ApprovalService } from '../src/auth/approval.service';
import { ClockService } from '../src/common/clock.service';
import { hashPin, hashTokenWithPepper } from '../src/common/crypto';
import { validateResponseAgainstContract } from './contract-validator';

interface ApiResponse {
  code?: string;
  message?: string;
  details?: { lockedUntil?: string };
  accessToken?: string;
  accessTokenExpiresAt?: string;
  refreshToken?: string;
  refreshTokenExpiresAt?: string;
  approvalToken?: string;
  expiresAt?: string;
  approverStaffId?: string;
  action?: string;
  me?: {
    staff?: { id?: string; displayName?: string; pinHash?: string };
    permissions?: string[];
    deviceId?: string | null;
  };
}

function getBody(res: request.Response): ApiResponse {
  return res.body as ApiResponse;
}

describe('PIN Login & Manager Approvals (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  let prisma: PrismaClient;
  let clock: ClockService;
  let approvalService: ApprovalService;

  const pepper =
    process.env.DEVICE_TOKEN_PEPPER ||
    'ci-only-pepper-not-for-production-min-32';

  // Branches
  let branch1Id: string;
  let branch2Id: string;

  // Devices
  const device1Token = 'device-token-suc1-32-chars-long!!';
  let device1Id: string;

  const device2Token = 'device-token-suc2-32-chars-long!!';
  let device2Id: string;

  // Staff
  let cashier1Id: string;
  const cashier1Pin = '1111';

  let cashier2Id: string;
  const cashier2Pin = '2222';

  let cashierNoPermId: string;
  const cashierNoPermPin = '4444';

  let managerId: string;
  const managerPin = '3333';

  let ownerId: string;
  const ownerPin = '9999';

  beforeAll(async () => {
    process.env.DATABASE_URL =
      process.env.DATABASE_URL ??
      'postgres://pos:pos_dev_only@127.0.0.1:5432/pos_dev';
    process.env.MIGRATION_DATABASE_URL =
      process.env.MIGRATION_DATABASE_URL ?? process.env.DATABASE_URL;
    process.env.JWT_SECRET =
      process.env.JWT_SECRET ?? 'ci-only-jwt-secret-not-for-production-min-32';
    process.env.DEVICE_TOKEN_PEPPER = pepper;

    prisma = new PrismaClient({
      datasources: { db: { url: process.env.DATABASE_URL } },
    });
    await prisma.$connect();

    // 1. Create 2 branches
    const b1 = await prisma.branch.upsert({
      where: { code: 'PINSUC1' },
      update: {},
      create: {
        id: uuidv7(),
        code: 'PINSUC1',
        name: 'Sucursal PIN 1',
        timezone: 'America/Mexico_City',
        isActive: true,
      },
    });
    branch1Id = b1.id;

    const b2 = await prisma.branch.upsert({
      where: { code: 'PINSUC2' },
      update: {},
      create: {
        id: uuidv7(),
        code: 'PINSUC2',
        name: 'Sucursal PIN 2',
        timezone: 'America/Mexico_City',
        isActive: true,
      },
    });
    branch2Id = b2.id;

    // 2. Create enrolled devices
    const d1Hash = hashTokenWithPepper(device1Token, pepper);
    const d1 = await prisma.device.upsert({
      where: { tokenHash: d1Hash },
      update: { status: DeviceStatus.ACTIVE },
      create: {
        id: uuidv7(),
        branchId: branch1Id,
        name: 'Caja SUC1',
        type: DeviceType.TILL,
        status: DeviceStatus.ACTIVE,
        tokenHash: d1Hash,
      },
    });
    device1Id = d1.id;

    const d2Hash = hashTokenWithPepper(device2Token, pepper);
    const d2 = await prisma.device.upsert({
      where: { tokenHash: d2Hash },
      update: { status: DeviceStatus.ACTIVE },
      create: {
        id: uuidv7(),
        branchId: branch2Id,
        name: 'Caja SUC2',
        type: DeviceType.TILL,
        status: DeviceStatus.ACTIVE,
        tokenHash: d2Hash,
      },
    });
    device2Id = d2.id;

    // 3. Create staff members
    // Cashier 1 on Branch 1
    const c1Pin = await hashPin(cashier1Pin);
    const c1 = await prisma.staff.upsert({
      where: { email: 'cashier1@pin-test.local' },
      update: {
        pinHash: c1Pin.pinHash,
        offlinePinVerifier: c1Pin.offlinePinVerifier,
        isActive: true,
        failedPinAttempts: 0,
        lockedUntil: null,
      },
      create: {
        id: uuidv7(),
        fullName: 'Cashier One',
        displayName: 'Cashier 1',
        role: Role.CASHIER,
        email: 'cashier1@pin-test.local',
        pinHash: c1Pin.pinHash,
        offlinePinVerifier: c1Pin.offlinePinVerifier,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: { create: [{ branchId: branch1Id }] },
      },
    });
    cashier1Id = c1.id;

    // Cashier 2 on Branch 2
    const c2Pin = await hashPin(cashier2Pin);
    const c2 = await prisma.staff.upsert({
      where: { email: 'cashier2@pin-test.local' },
      update: {
        pinHash: c2Pin.pinHash,
        offlinePinVerifier: c2Pin.offlinePinVerifier,
        isActive: true,
        failedPinAttempts: 0,
        lockedUntil: null,
      },
      create: {
        id: uuidv7(),
        fullName: 'Cashier Two',
        displayName: 'Cashier 2',
        role: Role.CASHIER,
        email: 'cashier2@pin-test.local',
        pinHash: c2Pin.pinHash,
        offlinePinVerifier: c2Pin.offlinePinVerifier,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: { create: [{ branchId: branch2Id }] },
      },
    });
    cashier2Id = c2.id;

    // Cashier without permissions on Branch 1
    const cNoPerm = await hashPin(cashierNoPermPin);
    const cnp = await prisma.staff.upsert({
      where: { email: 'cashier-noperm@pin-test.local' },
      update: {
        pinHash: cNoPerm.pinHash,
        offlinePinVerifier: cNoPerm.offlinePinVerifier,
        isActive: true,
        failedPinAttempts: 0,
        lockedUntil: null,
      },
      create: {
        id: uuidv7(),
        fullName: 'Cashier No Perm',
        displayName: 'Cashier NP',
        role: Role.CASHIER,
        email: 'cashier-noperm@pin-test.local',
        pinHash: cNoPerm.pinHash,
        offlinePinVerifier: cNoPerm.offlinePinVerifier,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: { create: [{ branchId: branch1Id }] },
      },
    });
    cashierNoPermId = cnp.id;

    // Manager on Branch 1
    const mPin = await hashPin(managerPin);
    const m = await prisma.staff.upsert({
      where: { email: 'manager@pin-test.local' },
      update: {
        pinHash: mPin.pinHash,
        offlinePinVerifier: mPin.offlinePinVerifier,
        isActive: true,
        failedPinAttempts: 0,
        lockedUntil: null,
      },
      create: {
        id: uuidv7(),
        fullName: 'Branch Manager',
        displayName: 'Manager',
        role: Role.BRANCH_MANAGER,
        email: 'manager@pin-test.local',
        pinHash: mPin.pinHash,
        offlinePinVerifier: mPin.offlinePinVerifier,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: { create: [{ branchId: branch1Id }] },
      },
    });
    managerId = m.id;

    // Owner
    const oPin = await hashPin(ownerPin);
    const o = await prisma.staff.upsert({
      where: { email: 'owner@pin-test.local' },
      update: {
        pinHash: oPin.pinHash,
        offlinePinVerifier: oPin.offlinePinVerifier,
        isActive: true,
        failedPinAttempts: 0,
        lockedUntil: null,
      },
      create: {
        id: uuidv7(),
        fullName: 'Bakery Owner',
        displayName: 'Owner',
        role: Role.OWNER,
        email: 'owner@pin-test.local',
        pinHash: oPin.pinHash,
        offlinePinVerifier: oPin.offlinePinVerifier,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: { create: [{ branchId: branch1Id }] },
      },
    });
    ownerId = o.id;

    // Nest application
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    configureApp(app);
    await app.init();
    server = app.getHttpServer() as Server;
    server.setMaxListeners(30);
    clock = app.get(ClockService);
    approvalService = app.get(ApprovalService);
  });

  beforeEach(async () => {
    clock.setNow(null);
    // Reset any lockout state on test users
    await prisma.staff.updateMany({
      where: {
        id: {
          in: [cashier1Id, cashier2Id, cashierNoPermId, managerId, ownerId],
        },
      },
      data: {
        failedPinAttempts: 0,
        lockedUntil: null,
      },
    });
  });

  afterAll(async () => {
    if (app) {
      await app.close();
    }
    await prisma.$disconnect();
  });

  describe('POST /v1/auth/pin-login', () => {
    it('rejects cashier from SUC2 attempting to login on SUC1 till (A9: AUTH_NOT_ALLOWED)', async () => {
      const res = await request(server)
        .post('/v1/auth/pin-login')
        .set('X-Device-Token', device1Token)
        .send({
          staffId: cashier2Id,
          pin: cashier2Pin,
        });

      expect(res.status).toBe(401);
      const body = getBody(res);
      expect(body.code).toBe('AUTH_NOT_ALLOWED');

      const validation = validateResponseAgainstContract({
        path: '/v1/auth/pin-login',
        method: 'post',
        status: 401,
        body: res.body,
      });
      expect(validation.valid).toBe(true);

      // Verify audit log recorded login_failure
      const audit = await prisma.auditLog.findFirst({
        where: {
          action: 'auth.login_failure',
          deviceId: device1Id,
          actorStaffId: cashier2Id,
        },
      });
      expect(audit).not.toBeNull();
    });

    it('A8: 5 wrong PINs lock the staff member; 6th attempt returns 423; unlocks after 5 minutes', async () => {
      const baseTime = new Date('2026-10-23T12:00:00.000Z');
      clock.setNow(baseTime);

      // Attempts 1 to 4: 401 AUTH_INVALID_PIN
      for (let i = 1; i <= 4; i++) {
        const res = await request(server)
          .post('/v1/auth/pin-login')
          .set('X-Device-Token', device1Token)
          .send({
            staffId: cashier1Id,
            pin: '9999',
          });

        expect(res.status).toBe(401);
        expect(getBody(res).code).toBe('AUTH_INVALID_PIN');
      }

      // Attempt 5: triggers lockout and returns 423 AUTH_LOCKED with details.lockedUntil
      const fifthRes = await request(server)
        .post('/v1/auth/pin-login')
        .set('X-Device-Token', device1Token)
        .send({
          staffId: cashier1Id,
          pin: '9999',
        });

      expect(fifthRes.status).toBe(423);
      const fifthBody = getBody(fifthRes);
      expect(fifthBody.code).toBe('AUTH_LOCKED');
      expect(fifthBody.details?.lockedUntil).toBeDefined();

      const expectedLock = new Date(
        baseTime.getTime() + 5 * 60 * 1000,
      ).toISOString();
      expect(fifthBody.details?.lockedUntil).toBe(expectedLock);

      // Contract validation for 423
      const val423 = validateResponseAgainstContract({
        path: '/v1/auth/pin-login',
        method: 'post',
        status: 423,
        body: fifthRes.body,
      });
      expect(val423.valid).toBe(true);

      // Attempt 6 (still locked): immediately 423
      const sixthRes = await request(server)
        .post('/v1/auth/pin-login')
        .set('X-Device-Token', device1Token)
        .send({
          staffId: cashier1Id,
          pin: cashier1Pin, // even with correct PIN
        });

      expect(sixthRes.status).toBe(423);
      expect(getBody(sixthRes).code).toBe('AUTH_LOCKED');

      // Verify audit rows: auth.locked was recorded
      const lockAudit = await prisma.auditLog.findFirst({
        where: {
          action: 'auth.locked',
          actorStaffId: cashier1Id,
          deviceId: device1Id,
        },
      });
      expect(lockAudit).not.toBeNull();

      // Advance clock by 5 minutes and 1 second: lock expires!
      clock.advance(5 * 60 * 1000 + 1000);

      const unlockRes = await request(server)
        .post('/v1/auth/pin-login')
        .set('X-Device-Token', device1Token)
        .send({
          staffId: cashier1Id,
          pin: cashier1Pin,
        });

      expect(unlockRes.status).toBe(200);
      expect(getBody(unlockRes).accessToken).toBeDefined();
    });

    it('parallel wrong PINs cannot bypass lockout; locks account with failed_pin_attempts >= 5', async () => {
      const promises = Array.from({ length: 10 }).map(() =>
        request(server)
          .post('/v1/auth/pin-login')
          .set('X-Device-Token', device1Token)
          .send({
            staffId: cashier1Id,
            pin: '9999',
          }),
      );

      const responses = await Promise.all(promises);
      for (const res of responses) {
        expect([401, 423]).toContain(res.status);
      }

      const staff = await prisma.staff.findUnique({
        where: { id: cashier1Id },
      });
      expect(staff?.lockedUntil).not.toBeNull();
      expect(staff?.failedPinAttempts).toBeGreaterThanOrEqual(5);

      const nextRes = await request(server)
        .post('/v1/auth/pin-login')
        .set('X-Device-Token', device1Token)
        .send({
          staffId: cashier1Id,
          pin: cashier1Pin,
        });
      expect(nextRes.status).toBe(423);
      expect(getBody(nextRes).code).toBe('AUTH_LOCKED');
    });

    it('session expires at 04:00 local time: tests login at 23:00 and at 03:00', async () => {
      // Test 1: Login at 23:00 local (Oct 23 23:00 CST -> Oct 24 05:00 UTC)
      const lateTime = new Date('2026-10-24T05:00:00.000Z');
      clock.setNow(lateTime);

      const res23 = await request(server)
        .post('/v1/auth/pin-login')
        .set('X-Device-Token', device1Token)
        .send({
          staffId: cashier1Id,
          pin: cashier1Pin,
        });

      expect(res23.status).toBe(200);
      const body23 = getBody(res23);
      // Next 04:00 CST is Oct 24 10:00 UTC
      expect(body23.refreshTokenExpiresAt).toBe('2026-10-24T10:00:00.000Z');
      expect(body23.me?.deviceId).toBe(device1Id);

      // Verify A11: no hashes in response
      const jsonStr = JSON.stringify(res23.body);
      expect(jsonStr).not.toContain('pinHash');
      expect(jsonStr).not.toContain('passwordHash');

      const val200 = validateResponseAgainstContract({
        path: '/v1/auth/pin-login',
        method: 'post',
        status: 200,
        body: res23.body,
      });
      expect(val200.valid).toBe(true);

      // Test 2: Login at 03:00 local (Oct 24 03:00 CST -> Oct 24 09:00 UTC)
      const earlyTime = new Date('2026-10-24T09:00:00.000Z');
      clock.setNow(earlyTime);

      const res3 = await request(server)
        .post('/v1/auth/pin-login')
        .set('X-Device-Token', device1Token)
        .send({
          staffId: cashier1Id,
          pin: cashier1Pin,
        });

      expect(res3.status).toBe(200);
      const body3 = getBody(res3);
      // Next 04:00 CST is same day Oct 24 10:00 UTC
      expect(body3.refreshTokenExpiresAt).toBe('2026-10-24T10:00:00.000Z');

      // Verify audit log has actor
      const successAudit = await prisma.auditLog.findFirst({
        where: {
          action: 'auth.login_success',
          actorStaffId: cashier1Id,
          deviceId: device1Id,
        },
      });
      expect(successAudit?.actorStaffId).toBe(cashier1Id);
    });

    it('owner can log in on any branch device', async () => {
      const res = await request(server)
        .post('/v1/auth/pin-login')
        .set('X-Device-Token', device2Token) // SUC2 till
        .send({
          staffId: ownerId,
          pin: ownerPin,
        });

      expect(res.status).toBe(200);
      expect(getBody(res).accessToken).toBeDefined();
      expect(getBody(res).me?.deviceId).toBe(device2Id);
    });
  });

  describe('POST /v1/auth/approvals', () => {
    let cashier1Token: string;

    beforeEach(async () => {
      const loginRes = await request(server)
        .post('/v1/auth/pin-login')
        .set('X-Device-Token', device1Token)
        .send({
          staffId: cashier1Id,
          pin: cashier1Pin,
        });
      cashier1Token = getBody(loginRes).accessToken!;
    });

    it('refuses an approval request when session does not belong to the sending device (403 PERMISSION_DENIED)', async () => {
      // cashier1Token belongs to device1Id. Send it with device2Token.
      const res = await request(server)
        .post('/v1/auth/approvals')
        .set('Authorization', `Bearer ${cashier1Token}`)
        .set('X-Device-Token', device2Token)
        .send({
          approverStaffId: managerId,
          pin: managerPin,
          action: 'sale.discount_over_limit',
        });

      expect(res.status).toBe(403);
      expect(getBody(res).code).toBe('PERMISSION_DENIED');

      // Assert it added no strike to the manager's PIN
      const dbManager = await prisma.staff.findUnique({
        where: { id: managerId },
      });
      expect(dbManager?.failedPinAttempts).toBe(0);
    });

    it('rejects self-approval (403 PERMISSION_DENIED)', async () => {
      const res = await request(server)
        .post('/v1/auth/approvals')
        .set('Authorization', `Bearer ${cashier1Token}`)
        .set('X-Device-Token', device1Token)
        .send({
          approverStaffId: cashier1Id,
          pin: cashier1Pin,
          action: 'sale.discount_over_limit',
        });

      expect(res.status).toBe(403);
      expect(getBody(res).code).toBe('PERMISSION_DENIED');

      const deniedAudit = await prisma.auditLog.findFirst({
        where: {
          action: 'auth.approval_denied',
          actorStaffId: cashier1Id,
          approverStaffId: cashier1Id,
          deviceId: device1Id,
        },
      });
      expect(deniedAudit).not.toBeNull();
    });

    it('rejects cashier attempting to approve without permission (403 PERMISSION_DENIED)', async () => {
      const res = await request(server)
        .post('/v1/auth/approvals')
        .set('Authorization', `Bearer ${cashier1Token}`)
        .set('X-Device-Token', device1Token)
        .send({
          approverStaffId: cashierNoPermId,
          pin: cashierNoPermPin,
          action: 'sale.discount_over_limit',
        });

      expect(res.status).toBe(403);
      expect(getBody(res).code).toBe('PERMISSION_DENIED');
    });

    it('rejects approver from another branch (403 PERMISSION_DENIED)', async () => {
      const res = await request(server)
        .post('/v1/auth/approvals')
        .set('Authorization', `Bearer ${cashier1Token}`)
        .set('X-Device-Token', device1Token)
        .send({
          approverStaffId: cashier2Id, // on SUC2
          pin: cashier2Pin,
          action: 'sale.discount_over_limit',
        });

      expect(res.status).toBe(403);
      expect(getBody(res).code).toBe('PERMISSION_DENIED');
    });

    it('A12: manager approves; token works once; fails second time and after 2 minutes', async () => {
      const baseTime = new Date('2026-10-23T14:00:00.000Z');
      clock.setNow(baseTime);

      const res = await request(server)
        .post('/v1/auth/approvals')
        .set('Authorization', `Bearer ${cashier1Token}`)
        .set('X-Device-Token', device1Token)
        .send({
          approverStaffId: managerId,
          pin: managerPin,
          action: 'sale.discount_over_limit',
          reference: 'FOLIO-12345',
        });

      expect(res.status).toBe(201);
      const body = getBody(res);
      expect(body.approvalToken).toBeDefined();
      expect(body.approverStaffId).toBe(managerId);
      expect(body.action).toBe('sale.discount_over_limit');

      const expectedExpiry = new Date(
        baseTime.getTime() + 2 * 60 * 1000,
      ).toISOString();
      expect(body.expiresAt).toBe(expectedExpiry);

      // Contract validation for 201
      const val201 = validateResponseAgainstContract({
        path: '/v1/auth/approvals',
        method: 'post',
        status: 201,
        body: res.body,
      });
      expect(val201.valid).toBe(true);

      // Verify audit row for approval granted
      const grantedAudit = await prisma.auditLog.findFirst({
        where: {
          action: 'auth.approval_granted',
          actorStaffId: cashier1Id,
          approverStaffId: managerId,
          deviceId: device1Id,
        },
      });
      expect(grantedAudit).not.toBeNull();
      const auditData = grantedAudit?.data as Record<string, unknown>;
      expect(auditData.action).toBe('sale.discount_over_limit');
      expect(auditData.reference).toBe('FOLIO-12345');

      // Test ApprovalService.consume:
      // First consume succeeds
      const token = body.approvalToken!;
      const consumed = await approvalService.consume(
        token,
        'sale.discount_over_limit',
        cashier1Id,
      );
      expect(consumed.usedAt).not.toBeNull();

      // Second consume fails (single-use: 409 APPROVAL_ALREADY_USED)
      await expect(
        approvalService.consume(token, 'sale.discount_over_limit', cashier1Id),
      ).rejects.toThrow(ConflictException);

      // Test expiry: create second approval
      const res2 = await request(server)
        .post('/v1/auth/approvals')
        .set('Authorization', `Bearer ${cashier1Token}`)
        .set('X-Device-Token', device1Token)
        .send({
          approverStaffId: managerId,
          pin: managerPin,
          action: 'sale.discount_over_limit',
        });
      expect(res2.status).toBe(201);
      const token2 = getBody(res2).approvalToken!;

      // Advance clock past 2 minutes
      clock.advance(2 * 60 * 1000 + 1000);

      // Consuming after 2 minutes fails with 410 APPROVAL_EXPIRED
      await expect(
        approvalService.consume(token2, 'sale.discount_over_limit', cashier1Id),
      ).rejects.toThrow(HttpException);
    });

    it('approver entering 5 wrong PINs in approval triggers lockout', async () => {
      for (let i = 1; i <= 4; i++) {
        const res = await request(server)
          .post('/v1/auth/approvals')
          .set('Authorization', `Bearer ${cashier1Token}`)
          .set('X-Device-Token', device1Token)
          .send({
            approverStaffId: managerId,
            pin: '9999',
            action: 'sale.discount_over_limit',
          });
        expect(res.status).toBe(401);
        expect(getBody(res).code).toBe('AUTH_INVALID_PIN');
      }

      // 5th attempt: 423 AUTH_LOCKED
      const fifthRes = await request(server)
        .post('/v1/auth/approvals')
        .set('Authorization', `Bearer ${cashier1Token}`)
        .set('X-Device-Token', device1Token)
        .send({
          approverStaffId: managerId,
          pin: '9999',
          action: 'sale.discount_over_limit',
        });
      expect(fifthRes.status).toBe(423);
      expect(getBody(fifthRes).code).toBe('AUTH_LOCKED');

      // Verify manager is locked in database
      const dbManager = await prisma.staff.findUnique({
        where: { id: managerId },
      });
      expect(dbManager?.lockedUntil).not.toBeNull();
    });
  });
});
