import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, Role } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { AuditService } from '../audit/audit.service';
import { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { ClockService } from '../common/clock.service';
import { PrismaService } from '../prisma/prisma.service';
import { StaffService } from './staff.service';

describe('StaffService', () => {
  let service: StaffService;
  let findManyMock: jest.Mock<Promise<unknown>, [unknown]>;
  let findUniqueMock: jest.Mock<Promise<unknown>, [unknown]>;
  let countStaffMock: jest.Mock<Promise<unknown>, [unknown]>;
  let countBranchMock: jest.Mock<Promise<unknown>, [unknown]>;
  let createStaffMock: jest.Mock<Promise<unknown>, [unknown]>;
  let updateStaffMock: jest.Mock<Promise<unknown>, [unknown]>;
  let deleteManyStaffBranchMock: jest.Mock<Promise<unknown>, [unknown]>;
  let createManyStaffBranchMock: jest.Mock<Promise<unknown>, [unknown]>;
  let updateManySessionsMock: jest.Mock<Promise<unknown>, [unknown]>;
  let createAuditMock: jest.Mock<Promise<unknown>, [unknown]>;
  let auditLogMock: jest.Mock<Promise<unknown>, [unknown]>;
  let transactionMock: jest.Mock<Promise<unknown>, [unknown]>;
  let clock: ClockService;

  const ownerUser: AuthenticatedUser = {
    staffId: uuidv7(),
    sessionId: uuidv7(),
    deviceId: null,
    role: Role.OWNER,
    branchIds: [uuidv7()],
    permissions: ['staff.manage'],
  };

  const managerUser: AuthenticatedUser = {
    staffId: uuidv7(),
    sessionId: uuidv7(),
    deviceId: null,
    role: Role.BRANCH_MANAGER,
    branchIds: [uuidv7()],
    permissions: ['staff.manage'],
  };

  beforeEach(() => {
    findManyMock = jest.fn<Promise<unknown>, [unknown]>();
    findUniqueMock = jest.fn<Promise<unknown>, [unknown]>();
    countStaffMock = jest.fn<Promise<unknown>, [unknown]>();
    countBranchMock = jest.fn<Promise<unknown>, [unknown]>();
    createStaffMock = jest.fn<Promise<unknown>, [unknown]>();
    updateStaffMock = jest.fn<Promise<unknown>, [unknown]>();
    deleteManyStaffBranchMock = jest.fn<Promise<unknown>, [unknown]>();
    createManyStaffBranchMock = jest.fn<Promise<unknown>, [unknown]>();
    updateManySessionsMock = jest.fn<Promise<unknown>, [unknown]>();
    createAuditMock = jest.fn<Promise<unknown>, [unknown]>();
    auditLogMock = jest.fn<Promise<unknown>, [unknown]>();
    clock = new ClockService();

    transactionMock = jest
      .fn<Promise<unknown>, [unknown]>()
      .mockImplementation(async (callback) => {
        if (typeof callback === 'function') {
          return (callback as (tx: unknown) => Promise<unknown>)({
            staff: {
              update: updateStaffMock,
            },
            staffBranch: {
              deleteMany: deleteManyStaffBranchMock,
              createMany: createManyStaffBranchMock,
            },
            authSession: {
              updateMany: updateManySessionsMock,
            },
            auditLog: {
              create: createAuditMock,
            },
          });
        }
        return Promise.resolve();
      });

    const prismaMock = {
      staff: {
        findMany: findManyMock,
        findUnique: findUniqueMock,
        count: countStaffMock,
        create: createStaffMock,
        update: updateStaffMock,
      },
      branch: {
        count: countBranchMock,
      },
      $transaction: transactionMock,
    } as unknown as PrismaService;

    const auditMock = {
      log: auditLogMock,
    } as unknown as AuditService;

    service = new StaffService(prismaMock, auditMock, clock);
  });

  describe('list', () => {
    it('filters by isActive: true by default', async () => {
      findManyMock.mockResolvedValue([]);

      await service.list({});
      expect(findManyMock).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { isActive: true },
        }),
      );
    });

    it('includes inactive when includeInactive is true', async () => {
      findManyMock.mockResolvedValue([]);

      await service.list({ includeInactive: true });
      expect(findManyMock).toHaveBeenCalledWith(
        expect.objectContaining({
          where: {},
        }),
      );
    });
  });

  describe('get', () => {
    it('returns staff without sensitive hashes', async () => {
      const staffId = uuidv7();
      findUniqueMock.mockResolvedValue({
        id: staffId,
        fullName: 'Juan Perez',
        displayName: 'Juan',
        role: Role.CASHIER,
        email: 'juan@bakery.local',
        passwordHash: null,
        pinHash: 'secret-hash',
        offlinePinVerifier: 'secret-verifier',
        pinUpdatedAt: new Date(),
        isActive: true,
        lockedUntil: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        staffBranches: [{ branchId: 'b-1' }],
      });

      const res = await service.get(staffId);
      expect(res.id).toBe(staffId);
      expect(res.hasPassword).toBe(false);
      expect(res.branchIds).toEqual(['b-1']);
      expect((res as Record<string, unknown>).pinHash).toBeUndefined();
      expect(
        (res as Record<string, unknown>).offlinePinVerifier,
      ).toBeUndefined();
    });

    it('throws NotFoundException when staff not found', async () => {
      findUniqueMock.mockResolvedValue(null);

      await expect(service.get(uuidv7())).rejects.toThrow(NotFoundException);
    });
  });

  describe('create', () => {
    it('refuses manager creating an OWNER (403 PERMISSION_DENIED)', async () => {
      await expect(
        service.create(managerUser, {
          fullName: 'New Owner',
          displayName: 'Owner',
          role: Role.OWNER,
          branchIds: [uuidv7()],
          pin: '1234',
        }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('requires email and password >= 10 chars for OWNER', async () => {
      await expect(
        service.create(ownerUser, {
          fullName: 'New Owner',
          displayName: 'Owner',
          role: Role.OWNER,
          branchIds: [uuidv7()],
          pin: '1234',
        }),
      ).rejects.toThrow(BadRequestException);

      await expect(
        service.create(ownerUser, {
          fullName: 'New Owner',
          displayName: 'Owner',
          role: Role.OWNER,
          email: 'owner@bakery.local',
          password: 'short',
          branchIds: [uuidv7()],
          pin: '1234',
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('throws ConflictException on duplicate email', async () => {
      findUniqueMock.mockResolvedValue({ id: uuidv7() });

      await expect(
        service.create(ownerUser, {
          fullName: 'Cashier',
          displayName: 'Cashier',
          role: Role.CASHIER,
          email: 'cashier@bakery.local',
          branchIds: [uuidv7()],
          pin: '1234',
        }),
      ).rejects.toThrow(ConflictException);
    });

    it('creates staff, hashes PIN, and audits staff.created', async () => {
      findUniqueMock.mockResolvedValue(null);
      countBranchMock.mockResolvedValue(1);
      const staffId = uuidv7();
      createStaffMock.mockResolvedValue({
        id: staffId,
        fullName: 'Carlos Cajero',
        displayName: 'Carlos',
        role: Role.CASHIER,
        email: null,
        passwordHash: null,
        pinHash: 'hashed',
        offlinePinVerifier: 'verifier',
        pinUpdatedAt: new Date(),
        isActive: true,
        lockedUntil: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        staffBranches: [{ branchId: 'b-1' }],
      });

      const res = await service.create(ownerUser, {
        fullName: 'Carlos Cajero',
        displayName: 'Carlos',
        role: Role.CASHIER,
        branchIds: ['b-1'],
        pin: '1234',
      });

      expect(res.id).toBe(staffId);
      expect(auditLogMock).toHaveBeenCalledWith(
        expect.objectContaining({
          action: 'staff.created',
          actorStaffId: ownerUser.staffId,
          entityType: 'staff',
        }),
      );
    });
  });

  describe('update', () => {
    it('refuses deactivating the last active owner (409 CONFLICT)', async () => {
      findUniqueMock.mockResolvedValue({
        id: ownerUser.staffId,
        role: Role.OWNER,
        isActive: true,
        staffBranches: [],
      });
      countStaffMock.mockResolvedValue(1);

      await expect(
        service.update(ownerUser, ownerUser.staffId, { isActive: false }),
      ).rejects.toThrow(ConflictException);
    });

    it('refuses demoting the last active owner (409 CONFLICT)', async () => {
      findUniqueMock.mockResolvedValue({
        id: ownerUser.staffId,
        role: Role.OWNER,
        isActive: true,
        staffBranches: [],
      });
      countStaffMock.mockResolvedValue(1);

      await expect(
        service.update(ownerUser, ownerUser.staffId, { role: Role.CASHIER }),
      ).rejects.toThrow(ConflictException);
    });

    it("refuses removing an owner's email (they could not log in)", async () => {
      findUniqueMock.mockResolvedValue({
        id: ownerUser.staffId,
        role: Role.OWNER,
        isActive: true,
        email: 'owner@bakery.local',
        passwordHash: 'hash',
        staffBranches: [],
      });

      await expect(
        service.update(ownerUser, ownerUser.staffId, { email: null }),
      ).rejects.toThrow(BadRequestException);
      expect(transactionMock).not.toHaveBeenCalled();
    });

    it('maps a concurrent duplicate email (P2002) to 409 CONFLICT', async () => {
      findUniqueMock.mockResolvedValue(null);
      countBranchMock.mockResolvedValue(1);
      createStaffMock.mockRejectedValue(
        new Prisma.PrismaClientKnownRequestError('Unique constraint failed', {
          code: 'P2002',
          clientVersion: 'test',
        }),
      );

      await expect(
        service.create(ownerUser, {
          fullName: 'Ana López',
          displayName: 'Ana',
          role: Role.CASHIER,
          email: 'ana@bakery.local',
          branchIds: [uuidv7()],
          pin: '1234',
        }),
      ).rejects.toThrow(ConflictException);
    });

    it('refuses manager promoting staff to OWNER (403 PERMISSION_DENIED)', async () => {
      findUniqueMock.mockResolvedValue({
        id: uuidv7(),
        role: Role.CASHIER,
        isActive: true,
        staffBranches: [],
      });

      await expect(
        service.update(managerUser, uuidv7(), { role: Role.OWNER }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('updates branchIds and personal details', async () => {
      const targetId = uuidv7();
      findUniqueMock.mockImplementation(
        (args: { where: { id?: string; email?: string } }) => {
          if (args.where.id === targetId) {
            return Promise.resolve({
              id: targetId,
              fullName: 'Original Name',
              displayName: 'Original',
              role: Role.CASHIER,
              email: 'original@bakery.local',
              passwordHash: null,
              pinHash: 'hash',
              offlinePinVerifier: 'verifier',
              pinUpdatedAt: new Date(),
              isActive: true,
              lockedUntil: null,
              createdAt: new Date(),
              updatedAt: new Date(),
              staffBranches: [],
            });
          }
          return Promise.resolve(null);
        },
      );
      countBranchMock.mockResolvedValue(1);
      updateStaffMock.mockResolvedValue({
        id: targetId,
        fullName: 'New Name',
        displayName: 'New',
        role: Role.CASHIER,
        email: 'new@bakery.local',
        passwordHash: null,
        pinHash: 'hash',
        offlinePinVerifier: 'verifier',
        pinUpdatedAt: new Date(),
        isActive: true,
        lockedUntil: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        staffBranches: [{ branchId: 'new-b' }],
      });

      const res = await service.update(ownerUser, targetId, {
        fullName: 'New Name',
        displayName: 'New',
        email: 'new@bakery.local',
        branchIds: ['new-b'],
        password: 'AValidPassword123!',
      });

      expect(res.fullName).toBe('New Name');
      expect(deleteManyStaffBranchMock).toHaveBeenCalledWith({
        where: { staffId: targetId },
      });
      expect(createManyStaffBranchMock).toHaveBeenCalledWith({
        data: [{ staffId: targetId, branchId: 'new-b' }],
      });
    });

    it('throws BadRequestException if updating branchIds with invalid branchId', async () => {
      const targetId = uuidv7();
      findUniqueMock.mockResolvedValue({
        id: targetId,
        role: Role.CASHIER,
        isActive: true,
        staffBranches: [],
      });
      countBranchMock.mockResolvedValue(0);

      await expect(
        service.update(ownerUser, targetId, { branchIds: [uuidv7()] }),
      ).rejects.toThrow(BadRequestException);
    });

    it('deactivating staff revokes sessions and writes staff.deactivated audit', async () => {
      const targetId = uuidv7();
      findUniqueMock.mockResolvedValue({
        id: targetId,
        role: Role.CASHIER,
        isActive: true,
        staffBranches: [],
      });
      updateStaffMock.mockResolvedValue({
        id: targetId,
        fullName: 'Test',
        displayName: 'T',
        role: Role.CASHIER,
        email: null,
        passwordHash: null,
        pinHash: 'hash',
        offlinePinVerifier: 'verifier',
        pinUpdatedAt: new Date(),
        isActive: false,
        lockedUntil: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        staffBranches: [],
      });

      await service.update(ownerUser, targetId, { isActive: false });

      expect(updateManySessionsMock).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { staffId: targetId, revokedAt: null },
        }),
      );
      expect(createAuditMock).toHaveBeenCalled();
      const auditArg = createAuditMock.mock.calls[0][0] as {
        data: { action: string; actorStaffId: string };
      };
      expect(auditArg.data.action).toBe('staff.deactivated');
      expect(auditArg.data.actorStaffId).toBe(ownerUser.staffId);
    });
  });

  describe('setPin', () => {
    it('throws NotFoundException when staff not found', async () => {
      findUniqueMock.mockResolvedValue(null);

      await expect(
        service.setPin(ownerUser, uuidv7(), { pin: '1234' }),
      ).rejects.toThrow(NotFoundException);
    });

    it('sets new PIN, resets lockout, revokes sessions, and audits staff.pin_changed', async () => {
      const targetId = uuidv7();
      findUniqueMock.mockResolvedValue({ id: targetId });

      await service.setPin(ownerUser, targetId, { pin: '4321' });

      expect(updateStaffMock).toHaveBeenCalled();
      const staffUpdateArg = updateStaffMock.mock.calls[0][0] as {
        where: { id: string };
        data: { failedPinAttempts: number; lockedUntil: Date | null };
      };
      expect(staffUpdateArg.where.id).toBe(targetId);
      expect(staffUpdateArg.data.failedPinAttempts).toBe(0);
      expect(staffUpdateArg.data.lockedUntil).toBeNull();

      expect(updateManySessionsMock).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { staffId: targetId, revokedAt: null },
        }),
      );
      expect(createAuditMock).toHaveBeenCalled();
      const auditArg = createAuditMock.mock.calls[0][0] as {
        data: { action: string; actorStaffId: string };
      };
      expect(auditArg.data.action).toBe('staff.pin_changed');
      expect(auditArg.data.actorStaffId).toBe(ownerUser.staffId);
    });
  });
});
