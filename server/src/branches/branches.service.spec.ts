import {
  BadRequestException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { Role } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { AuditService } from '../audit/audit.service';
import { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { ClockService } from '../common/clock.service';
import { PrismaService } from '../prisma/prisma.service';
import { BranchesService } from './branches.service';

describe('BranchesService', () => {
  let service: BranchesService;
  let findManyMock: jest.Mock<Promise<unknown>, [unknown]>;
  let findUniqueMock: jest.Mock<Promise<unknown>, [unknown]>;
  let createMock: jest.Mock<Promise<unknown>, [unknown]>;
  let updateMock: jest.Mock<Promise<unknown>, [unknown]>;
  let updateManySessionsMock: jest.Mock<Promise<unknown>, [unknown]>;
  let createAuditMock: jest.Mock<Promise<unknown>, [unknown]>;
  let auditLogMock: jest.Mock<Promise<unknown>, [unknown]>;
  let clock: ClockService;

  const ownerUser: AuthenticatedUser = {
    staffId: uuidv7(),
    sessionId: uuidv7(),
    deviceId: null,
    role: Role.OWNER,
    branchIds: [],
    permissions: ['branches.manage'],
  };

  const managerUser: AuthenticatedUser = {
    staffId: uuidv7(),
    sessionId: uuidv7(),
    deviceId: null,
    role: Role.BRANCH_MANAGER,
    branchIds: [uuidv7()],
    permissions: ['branches.manage'],
  };

  beforeEach(() => {
    findManyMock = jest.fn<Promise<unknown>, [unknown]>();
    findUniqueMock = jest.fn<Promise<unknown>, [unknown]>();
    createMock = jest.fn<Promise<unknown>, [unknown]>();
    updateMock = jest.fn<Promise<unknown>, [unknown]>();
    updateManySessionsMock = jest.fn<Promise<unknown>, [unknown]>();
    createAuditMock = jest.fn<Promise<unknown>, [unknown]>();
    auditLogMock = jest.fn<Promise<unknown>, [unknown]>();
    clock = new ClockService();

    const prismaMock = {
      branch: {
        findMany: findManyMock,
        findUnique: findUniqueMock,
        create: createMock,
        update: updateMock,
      },
      $transaction: jest.fn(async (cb) => {
        if (typeof cb === 'function') {
          return (cb as (tx: unknown) => Promise<unknown>)({
            branch: { update: updateMock },
            authSession: { updateMany: updateManySessionsMock },
            auditLog: { create: createAuditMock },
          });
        }
        return Promise.resolve();
      }),
    } as unknown as PrismaService;

    const auditMock = {
      log: auditLogMock,
    } as unknown as AuditService;

    service = new BranchesService(prismaMock, auditMock, clock);
  });

  describe('list', () => {
    it('returns all branches for owner', async () => {
      findManyMock.mockResolvedValue([
        {
          id: uuidv7(),
          code: 'SUC1',
          name: 'Sucursal 1',
          address: null,
          timezone: 'America/Mexico_City',
          isActive: true,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ]);

      const result = await service.list(ownerUser);
      expect(result).toHaveLength(1);
      expect(findManyMock).toHaveBeenCalledWith({
        where: undefined,
        orderBy: { code: 'asc' },
      });
    });

    it('returns only assigned branches for non-owner', async () => {
      findManyMock.mockResolvedValue([]);

      await service.list(managerUser);
      expect(findManyMock).toHaveBeenCalledWith({
        where: { id: { in: managerUser.branchIds } },
        orderBy: { code: 'asc' },
      });
    });
  });

  describe('create', () => {
    it('creates branch and writes audit log', async () => {
      findUniqueMock.mockResolvedValue(null);
      const branchId = uuidv7();
      createMock.mockResolvedValue({
        id: branchId,
        code: 'SUC3',
        name: 'Sucursal 3',
        address: 'Av 3',
        timezone: 'America/Mexico_City',
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      const res = await service.create(ownerUser, {
        code: 'SUC3',
        name: 'Sucursal 3',
        address: 'Av 3',
      });

      expect(res.code).toBe('SUC3');
      expect(auditLogMock).toHaveBeenCalledWith(
        expect.objectContaining({
          action: 'branch.created',
          actorStaffId: ownerUser.staffId,
          entityType: 'branch',
        }),
      );
    });

    it('throws BadRequestException on invalid time zone', async () => {
      await expect(
        service.create(ownerUser, {
          code: 'SUC9',
          name: 'Sucursal 9',
          timezone: 'Mexico',
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('throws ConflictException on duplicate code', async () => {
      findUniqueMock.mockResolvedValue({ id: uuidv7(), code: 'SUC1' });

      await expect(
        service.create(ownerUser, { code: 'SUC1', name: 'Sucursal 1' }),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('update', () => {
    it('throws NotFoundException if branch does not exist', async () => {
      findUniqueMock.mockResolvedValue(null);

      await expect(
        service.update(ownerUser, uuidv7(), { name: 'New Name' }),
      ).rejects.toThrow(NotFoundException);
    });

    it('throws BadRequestException if no fields provided', async () => {
      findUniqueMock.mockResolvedValue({ id: uuidv7() });

      await expect(service.update(ownerUser, uuidv7(), {})).rejects.toThrow(
        BadRequestException,
      );
    });

    it('throws BadRequestException on invalid time zone in update', async () => {
      await expect(
        service.update(ownerUser, uuidv7(), { timezone: 'Invalid/Zone' }),
      ).rejects.toThrow(BadRequestException);
    });

    it('updates branch and writes audit log in transaction', async () => {
      const branchId = uuidv7();
      findUniqueMock.mockResolvedValue({ id: branchId });
      updateMock.mockResolvedValue({
        id: branchId,
        code: 'SUC1',
        name: 'Updated Name',
        address: null,
        timezone: 'America/Mexico_City',
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      const res = await service.update(ownerUser, branchId, {
        name: 'Updated Name',
      });

      expect(res.name).toBe('Updated Name');
      expect(createAuditMock).toHaveBeenCalled();
      const auditArg = createAuditMock.mock.calls[0][0] as {
        data: { action: string; actorStaffId: string };
      };
      expect(auditArg.data.action).toBe('branch.updated');
      expect(auditArg.data.actorStaffId).toBe(ownerUser.staffId);
    });

    it('deactivating branch revokes sessions of that branch in transaction', async () => {
      const branchId = uuidv7();
      findUniqueMock.mockResolvedValue({ id: branchId });
      updateMock.mockResolvedValue({
        id: branchId,
        code: 'SUC1',
        name: 'Sucursal 1',
        address: null,
        timezone: 'America/Mexico_City',
        isActive: false,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      await service.update(ownerUser, branchId, { isActive: false });

      expect(updateManySessionsMock).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { device: { branchId }, revokedAt: null },
        }),
      );
    });
  });
});
