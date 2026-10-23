import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient, Role } from '@prisma/client';
import { randomBytes } from 'crypto';
import type { Server } from 'http';
import request from 'supertest';
import { v7 as uuidv7 } from 'uuid';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import { PrismaService } from '../src/prisma/prisma.service';
import {
  hashPassword,
  hashPin,
  hashTokenWithPepper,
} from '../src/common/crypto';
import { validateResponseAgainstContract } from './contract-validator';

describe('Admin Endpoints: Branches, Staff & Audit Log (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  let prisma: PrismaClient;

  let branch1Id: string;
  let branch2Id: string;
  let ownerToken: string;
  let ownerId: string;
  let cashierToken: string;
  let cashierId: string;
  let managerToken: string;
  let deviceTokenHex: string;

  const ownerEmail = 'admin-e2e-owner@bakery.local';
  const ownerPassword = 'OwnerAdminPass123!';
  const managerEmail = 'admin-e2e-manager@bakery.local';
  const managerPassword = 'ManagerAdminPass123!';

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

    // 1. Create 2 branches
    const b1 = await prisma.branch.upsert({
      where: { code: 'ADMB1' },
      update: {},
      create: {
        id: uuidv7(),
        code: 'ADMB1',
        name: 'Admin Branch 1',
        isActive: true,
      },
    });
    branch1Id = b1.id;

    const b2 = await prisma.branch.upsert({
      where: { code: 'ADMB2' },
      update: {},
      create: {
        id: uuidv7(),
        code: 'ADMB2',
        name: 'Admin Branch 2',
        isActive: true,
      },
    });
    branch2Id = b2.id;

    // 2. Create Owner
    const ownerPassHash = await hashPassword(ownerPassword);
    const { pinHash: oPin, offlinePinVerifier: oVer } = await hashPin('1111');
    const owner = await prisma.staff.upsert({
      where: { email: ownerEmail },
      update: {
        isActive: true,
        passwordHash: ownerPassHash,
        failedPasswordAttempts: 0,
        passwordLockedUntil: null,
      },
      create: {
        id: uuidv7(),
        fullName: 'Admin Owner',
        displayName: 'Owner',
        role: Role.OWNER,
        email: ownerEmail,
        passwordHash: ownerPassHash,
        pinHash: oPin,
        offlinePinVerifier: oVer,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: {
          create: [{ branchId: branch1Id }, { branchId: branch2Id }],
        },
      },
    });
    ownerId = owner.id;

    // 3. Create Manager (assigned only to branch1)
    const mgrPassHash = await hashPassword(managerPassword);
    const { pinHash: mPin, offlinePinVerifier: mVer } = await hashPin('2222');
    await prisma.staff.upsert({
      where: { email: managerEmail },
      update: {
        isActive: true,
        passwordHash: mgrPassHash,
      },
      create: {
        id: uuidv7(),
        fullName: 'Admin Manager',
        displayName: 'Manager',
        role: Role.BRANCH_MANAGER,
        email: managerEmail,
        passwordHash: mgrPassHash,
        pinHash: mPin,
        offlinePinVerifier: mVer,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: { create: [{ branchId: branch1Id }] },
      },
    });

    // 4. Create Cashier (assigned only to branch1)
    const { pinHash: cPin, offlinePinVerifier: cVer } = await hashPin('3333');
    const cashierEmail = 'admin-e2e-cashier@bakery.local';
    const cashier = await prisma.staff.upsert({
      where: { email: cashierEmail },
      update: { isActive: true },
      create: {
        id: uuidv7(),
        fullName: 'Admin Cashier',
        displayName: 'Cashier',
        role: Role.CASHIER,
        email: cashierEmail,
        pinHash: cPin,
        offlinePinVerifier: cVer,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: { create: [{ branchId: branch1Id }] },
      },
    });
    cashierId = cashier.id;

    // 5. Create device in branch 1
    deviceTokenHex = randomBytes(32).toString('hex');
    const pepper = process.env.DEVICE_TOKEN_PEPPER;
    const devTokenHash = hashTokenWithPepper(deviceTokenHex, pepper);
    await prisma.device.create({
      data: {
        id: uuidv7(),
        branchId: branch1Id,
        name: 'Admin Till 1',
        type: 'TILL',
        status: 'ACTIVE',
        tokenHash: devTokenHash,
      },
    });

    // Start Nest App
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    configureApp(app);
    await app.init();
    server = app.getHttpServer() as Server;

    // Login Owner to get access token
    const ownerLoginRes = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: ownerEmail, password: ownerPassword });
    ownerToken = (ownerLoginRes.body as { accessToken: string }).accessToken;

    // Login Manager to get access token
    const mgrLoginRes = await request(server)
      .post('/v1/auth/password-login')
      .send({ email: managerEmail, password: managerPassword });
    managerToken = (mgrLoginRes.body as { accessToken: string }).accessToken;

    // Login Cashier on till to get access token
    const cashierLoginRes = await request(server)
      .post('/v1/auth/pin-login')
      .set('X-Device-Token', deviceTokenHex)
      .send({ staffId: cashierId, pin: '3333' });
    cashierToken = (cashierLoginRes.body as { accessToken: string })
      .accessToken;
  });

  afterAll(async () => {
    if (app) await app.close();
    if (prisma) await prisma.$disconnect();
  });

  describe('Branches (GET, POST, PATCH /v1/branches)', () => {
    it('owner sees all branches; non-owner sees only assigned branches', async () => {
      const ownerRes = await request(server)
        .get('/v1/branches')
        .set('Authorization', `Bearer ${ownerToken}`);
      expect(ownerRes.status).toBe(200);
      const ownerBranches = ownerRes.body as Array<{
        id: string;
        code: string;
      }>;
      expect(ownerBranches.length).toBeGreaterThanOrEqual(2);
      expect(
        validateResponseAgainstContract({
          path: '/v1/branches',
          method: 'GET',
          status: 200,
          body: ownerRes.body,
        }).valid,
      ).toBe(true);

      const cashierRes = await request(server)
        .get('/v1/branches')
        .set('Authorization', `Bearer ${cashierToken}`);
      expect(cashierRes.status).toBe(200);
      const cashierBranches = cashierRes.body as Array<{
        id: string;
        code: string;
      }>;
      expect(cashierBranches.some((b) => b.id === branch1Id)).toBe(true);
      expect(cashierBranches.some((b) => b.id === branch2Id)).toBe(false);
    });

    it('creates a new branch (POST /v1/branches) and audits branch.created', async () => {
      const newCode = `B${Date.now().toString().slice(-6)}`;
      const res = await request(server)
        .post('/v1/branches')
        .set('Authorization', `Bearer ${ownerToken}`)
        .send({
          code: newCode,
          name: 'Sucursal Test Nueva',
          address: 'Calle 100 #200',
        });

      expect(res.status).toBe(201);
      const created = res.body as { id: string; code: string; name: string };
      expect(created.code).toBe(newCode);
      expect(
        validateResponseAgainstContract({
          path: '/v1/branches',
          method: 'POST',
          status: 201,
          body: res.body,
        }).valid,
      ).toBe(true);

      // Verify audit row
      const audit = await prisma.auditLog.findFirst({
        where: { action: 'branch.created', entityId: created.id },
      });
      expect(audit).not.toBeNull();
      expect(audit?.actorStaffId).toBe(ownerId);
      expect(audit?.branchId).toBe(created.id);
    });

    it('returns 409 CONFLICT on duplicate branch code', async () => {
      const res = await request(server)
        .post('/v1/branches')
        .set('Authorization', `Bearer ${ownerToken}`)
        .send({
          code: 'ADMB1',
          name: 'Duplicate Branch',
        });

      expect(res.status).toBe(409);
      expect((res.body as { code: string }).code).toBe('CONFLICT');
    });

    it('updates branch (PATCH /v1/branches/{id}) and audits branch.updated', async () => {
      const res = await request(server)
        .patch(`/v1/branches/${branch1Id}`)
        .set('Authorization', `Bearer ${ownerToken}`)
        .send({
          name: 'Admin Branch 1 Renamed',
          address: 'Updated Address 123',
        });

      expect(res.status).toBe(200);
      expect((res.body as { name: string }).name).toBe(
        'Admin Branch 1 Renamed',
      );
      expect(
        validateResponseAgainstContract({
          path: '/v1/branches/{branchId}',
          method: 'PATCH',
          status: 200,
          body: res.body,
        }).valid,
      ).toBe(true);

      const audit = await prisma.auditLog.findFirst({
        where: { action: 'branch.updated', entityId: branch1Id },
      });
      expect(audit).not.toBeNull();
      expect(audit?.actorStaffId).toBe(ownerId);
    });
  });

  describe('Staff Management & Acceptance Tests A5, A10', () => {
    let createdStaffId: string;
    const testCashierPin = '5555';

    it('A5: cashier calling POST /v1/staff gets 403 PERMISSION_DENIED; owner gets 201', async () => {
      // Cashier attempt
      const cashierDenyRes = await request(server)
        .post('/v1/staff')
        .set('Authorization', `Bearer ${cashierToken}`)
        .send({
          fullName: 'Rogue Cashier Attempt',
          displayName: 'Rogue',
          role: Role.CASHIER,
          branchIds: [branch1Id],
          pin: '9999',
        });

      expect(cashierDenyRes.status).toBe(403);
      expect((cashierDenyRes.body as { code: string }).code).toBe(
        'PERMISSION_DENIED',
      );

      // Owner attempt
      const ownerSuccessRes = await request(server)
        .post('/v1/staff')
        .set('Authorization', `Bearer ${ownerToken}`)
        .send({
          fullName: 'Maria Panadera',
          displayName: 'Maria',
          role: Role.BAKER,
          branchIds: [branch1Id],
          pin: testCashierPin,
        });

      expect(ownerSuccessRes.status).toBe(201);
      const createdStaff = ownerSuccessRes.body as {
        id: string;
        fullName: string;
        role: string;
        hasPassword: boolean;
        pinHash?: unknown;
        passwordHash?: unknown;
        offlinePinVerifier?: unknown;
      };
      createdStaffId = createdStaff.id;
      expect(createdStaff.fullName).toBe('Maria Panadera');
      expect(createdStaff.role).toBe('BAKER');
      expect(createdStaff.hasPassword).toBe(false);

      // Verify no sensitive hashes in response body
      expect(createdStaff.pinHash).toBeUndefined();
      expect(createdStaff.passwordHash).toBeUndefined();
      expect(createdStaff.offlinePinVerifier).toBeUndefined();

      expect(
        validateResponseAgainstContract({
          path: '/v1/staff',
          method: 'POST',
          status: 201,
          body: ownerSuccessRes.body,
        }).valid,
      ).toBe(true);

      // Verify staff.created audit
      const audit = await prisma.auditLog.findFirst({
        where: { action: 'staff.created', entityId: createdStaffId },
      });
      expect(audit).not.toBeNull();
      expect(audit?.actorStaffId).toBe(ownerId);
      const auditData = audit?.data as Record<string, unknown>;
      expect(auditData.pin).toBeUndefined();
      expect(auditData.pinHash).toBeUndefined();
    });

    it('returns 409 CONFLICT on duplicate staff email', async () => {
      const res = await request(server)
        .post('/v1/staff')
        .set('Authorization', `Bearer ${ownerToken}`)
        .send({
          fullName: 'Duplicate Email Owner',
          displayName: 'Dup',
          role: Role.OWNER,
          email: ownerEmail,
          password: 'AnotherValidPass123!',
          branchIds: [branch1Id],
          pin: '8888',
        });

      expect(res.status).toBe(409);
      expect((res.body as { code: string }).code).toBe('CONFLICT');
    });

    it('guard rail: nobody can deactivate or demote the last active owner (409 CONFLICT)', async () => {
      const appPrisma = app.get(PrismaService);
      const countSpy = jest
        .spyOn(appPrisma.staff, 'count')
        .mockResolvedValue(1);

      // 1. Attempt deactivation of the owner
      const deactRes = await request(server)
        .patch(`/v1/staff/${ownerId}`)
        .set('Authorization', `Bearer ${ownerToken}`)
        .send({ isActive: false });

      expect(deactRes.status).toBe(409);
      expect((deactRes.body as { code: string }).code).toBe('CONFLICT');

      // 2. Attempt demotion of the owner
      const demoteRes = await request(server)
        .patch(`/v1/staff/${ownerId}`)
        .set('Authorization', `Bearer ${ownerToken}`)
        .send({ role: Role.CASHIER });

      expect(demoteRes.status).toBe(409);
      expect((demoteRes.body as { code: string }).code).toBe('CONFLICT');

      countSpy.mockRestore();
    });

    it('guard rail: manager can never create or promote an OWNER (403 PERMISSION_DENIED)', async () => {
      // Manager creating an owner
      const createRes = await request(server)
        .post('/v1/staff')
        .set('Authorization', `Bearer ${managerToken}`)
        .send({
          fullName: 'Unauthorized Owner',
          displayName: 'BadOwner',
          role: Role.OWNER,
          email: 'bad-owner@bakery.local',
          password: 'Password123456!',
          branchIds: [branch1Id],
          pin: '7777',
        });
      expect(createRes.status).toBe(403);
      expect((createRes.body as { code: string }).code).toBe(
        'PERMISSION_DENIED',
      );

      // Manager promoting cashier to owner
      const promoteRes = await request(server)
        .patch(`/v1/staff/${cashierId}`)
        .set('Authorization', `Bearer ${managerToken}`)
        .send({ role: Role.OWNER });
      expect(promoteRes.status).toBe(403);
      expect((promoteRes.body as { code: string }).code).toBe(
        'PERMISSION_DENIED',
      );
    });

    it('lists staff with filters and gets single staff member', async () => {
      const listRes = await request(server)
        .get(`/v1/staff?branchId=${branch1Id}&role=BAKER`)
        .set('Authorization', `Bearer ${ownerToken}`);
      expect(listRes.status).toBe(200);
      const list = listRes.body as Array<{ id: string; role: string }>;
      expect(list.some((s) => s.id === createdStaffId)).toBe(true);

      const getRes = await request(server)
        .get(`/v1/staff/${createdStaffId}`)
        .set('Authorization', `Bearer ${ownerToken}`);
      expect(getRes.status).toBe(200);
      expect((getRes.body as { id: string }).id).toBe(createdStaffId);
      expect(
        validateResponseAgainstContract({
          path: '/v1/staff/{staffId}',
          method: 'GET',
          status: 200,
          body: getRes.body,
        }).valid,
      ).toBe(true);
    });

    it('changes PIN (PUT /v1/staff/{id}/pin), clears lockout, revokes sessions, and audits staff.pin_changed', async () => {
      // Login Maria to create an active session
      const mariaLoginRes = await request(server)
        .post('/v1/auth/pin-login')
        .set('X-Device-Token', deviceTokenHex)
        .send({ staffId: createdStaffId, pin: testCashierPin });
      expect(mariaLoginRes.status).toBe(200);
      const mariaToken = (mariaLoginRes.body as { accessToken: string })
        .accessToken;

      // Lock Maria with 5 wrong attempts
      for (let i = 0; i < 5; i++) {
        await request(server)
          .post('/v1/auth/pin-login')
          .set('X-Device-Token', deviceTokenHex)
          .send({ staffId: createdStaffId, pin: '0000' });
      }

      const lockedStaff = await prisma.staff.findUnique({
        where: { id: createdStaffId },
      });
      expect(lockedStaff?.lockedUntil).not.toBeNull();

      // Change PIN via admin
      const newPin = '7890';
      const pinRes = await request(server)
        .put(`/v1/staff/${createdStaffId}/pin`)
        .set('Authorization', `Bearer ${ownerToken}`)
        .send({ pin: newPin });
      expect(pinRes.status).toBe(204);

      // Verify lockout cleared
      const resetStaff = await prisma.staff.findUnique({
        where: { id: createdStaffId },
      });
      expect(resetStaff?.lockedUntil).toBeNull();
      expect(resetStaff?.failedPinAttempts).toBe(0);

      // Old session was revoked -> token refused
      const testOldSessionRes = await request(server)
        .get('/v1/branches')
        .set('Authorization', `Bearer ${mariaToken}`);
      expect(testOldSessionRes.status).toBe(401);

      // Can login with new PIN
      const newLoginRes = await request(server)
        .post('/v1/auth/pin-login')
        .set('X-Device-Token', deviceTokenHex)
        .send({ staffId: createdStaffId, pin: newPin });
      expect(newLoginRes.status).toBe(200);

      // Verify audit row
      const audit = await prisma.auditLog.findFirst({
        where: { action: 'staff.pin_changed', entityId: createdStaffId },
      });
      expect(audit).not.toBeNull();
      expect(audit?.actorStaffId).toBe(ownerId);
    });

    it('A10: deactivated staff member cannot use existing token, and disappears from GET /v1/devices/me/staff', async () => {
      // 1. Create a staff member, login on till
      const tempRes = await request(server)
        .post('/v1/staff')
        .set('Authorization', `Bearer ${ownerToken}`)
        .send({
          fullName: 'Deactivation Target',
          displayName: 'DeactTarget',
          role: Role.CASHIER,
          branchIds: [branch1Id],
          pin: '4444',
        });
      const targetId = (tempRes.body as { id: string }).id;

      const loginRes = await request(server)
        .post('/v1/auth/pin-login')
        .set('X-Device-Token', deviceTokenHex)
        .send({ staffId: targetId, pin: '4444' });
      const targetToken = (loginRes.body as { accessToken: string })
        .accessToken;

      // Verify target is present in GET /v1/devices/me/staff
      const staffListBefore = await request(server)
        .get('/v1/devices/me/staff')
        .set('X-Device-Token', deviceTokenHex);
      expect(staffListBefore.status).toBe(200);
      const staffBundleBefore = staffListBefore.body as {
        staff: Array<{ id: string }>;
      };
      expect(staffBundleBefore.staff.some((s) => s.id === targetId)).toBe(true);

      // 2. Deactivate target
      const deactRes = await request(server)
        .patch(`/v1/staff/${targetId}`)
        .set('Authorization', `Bearer ${ownerToken}`)
        .send({ isActive: false });
      expect(deactRes.status).toBe(200);
      expect((deactRes.body as { isActive: boolean }).isActive).toBe(false);

      // Verify staff.deactivated audit row
      const deactAudit = await prisma.auditLog.findFirst({
        where: { action: 'staff.deactivated', entityId: targetId },
      });
      expect(deactAudit).not.toBeNull();
      expect(deactAudit?.actorStaffId).toBe(ownerId);

      // 3. Existing token is refused (401 AUTH_REQUIRED)
      const callWithOldToken = await request(server)
        .get('/v1/branches')
        .set('Authorization', `Bearer ${targetToken}`);
      expect(callWithOldToken.status).toBe(401);
      expect((callWithOldToken.body as { code: string }).code).toBe(
        'AUTH_REQUIRED',
      );

      // 4. Target disappears from GET /v1/devices/me/staff
      const staffListAfter = await request(server)
        .get('/v1/devices/me/staff')
        .set('X-Device-Token', deviceTokenHex);
      expect(staffListAfter.status).toBe(200);
      const staffBundleAfter = staffListAfter.body as {
        staff: Array<{ id: string }>;
      };
      expect(staffBundleAfter.staff.some((s) => s.id === targetId)).toBe(false);
    });
  });

  describe('Audit Log (GET /v1/audit-log) & Cursor Pagination', () => {
    it('requires audit.view permission (cashier gets 403, owner gets 200)', async () => {
      const cashierRes = await request(server)
        .get('/v1/audit-log')
        .set('Authorization', `Bearer ${cashierToken}`);
      expect(cashierRes.status).toBe(403);
      expect((cashierRes.body as { code: string }).code).toBe(
        'PERMISSION_DENIED',
      );

      const ownerRes = await request(server)
        .get('/v1/audit-log')
        .set('Authorization', `Bearer ${ownerToken}`);
      expect(ownerRes.status).toBe(200);
      expect(
        validateResponseAgainstContract({
          path: '/v1/audit-log',
          method: 'GET',
          status: 200,
          body: ownerRes.body,
        }).valid,
      ).toBe(true);
    });

    it('pages across two pages with cursor and no duplicate IDs', async () => {
      // Fetch page 1 with limit=2
      const page1Res = await request(server)
        .get('/v1/audit-log?limit=2')
        .set('Authorization', `Bearer ${ownerToken}`);

      expect(page1Res.status).toBe(200);
      const page1 = page1Res.body as {
        items: Array<{ id: string }>;
        nextCursor: string | null;
      };
      expect(page1.items.length).toBe(2);
      expect(page1.nextCursor).not.toBeNull();

      // Fetch page 2 with cursor
      const page2Res = await request(server)
        .get(
          `/v1/audit-log?limit=2&cursor=${encodeURIComponent(page1.nextCursor!)}`,
        )
        .set('Authorization', `Bearer ${ownerToken}`);

      expect(page2Res.status).toBe(200);
      const page2 = page2Res.body as {
        items: Array<{ id: string }>;
        nextCursor: string | null;
      };
      expect(page2.items.length).toBeGreaterThan(0);

      // Verify no duplicates between page 1 and page 2
      const page1Ids = new Set(page1.items.map((i) => i.id));
      for (const item of page2.items) {
        expect(page1Ids.has(item.id)).toBe(false);
      }
    });

    it('filters by action and staffId (actor or approver)', async () => {
      const filteredRes = await request(server)
        .get(`/v1/audit-log?action=branch.created&staffId=${ownerId}`)
        .set('Authorization', `Bearer ${ownerToken}`);

      expect(filteredRes.status).toBe(200);
      const body = filteredRes.body as {
        items: Array<{ action: string; actorStaffId: string }>;
      };
      expect(body.items.length).toBeGreaterThan(0);
      for (const item of body.items) {
        expect(item.action).toBe('branch.created');
        expect(item.actorStaffId).toBe(ownerId);
      }
    });

    it('never contains passwords, PINs, or hashes in audit log data', async () => {
      const res = await request(server)
        .get('/v1/audit-log?limit=50')
        .set('Authorization', `Bearer ${ownerToken}`);

      expect(res.status).toBe(200);
      const body = res.body as {
        items: Array<{ data?: Record<string, unknown> }>;
      };
      for (const item of body.items) {
        if (!item.data) continue;
        expect(item.data.pin).toBeUndefined();
        expect(item.data.password).toBeUndefined();
        expect(item.data.pinHash).toBeUndefined();
        expect(item.data.passwordHash).toBeUndefined();
        expect(item.data.offlinePinVerifier).toBeUndefined();
      }
    });
  });
});
