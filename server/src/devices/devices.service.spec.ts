import {
  BadRequestException,
  ConflictException,
  HttpException,
  HttpStatus,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Branch, Device, DeviceStatus, DeviceType, Role } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { AuditService } from '../audit/audit.service';
import { ClockService } from '../common/clock.service';
import { hashTokenWithPepper } from '../common/crypto';
import { PrismaService } from '../prisma/prisma.service';
import { DevicesService } from './devices.service';

describe('DevicesService', () => {
  let service: DevicesService;
  let prisma: PrismaService;
  let audit: AuditService;
  let clock: ClockService;

  let findUniqueBranchMock: jest.Mock<Promise<unknown>, [unknown]>;
  let findUniqueDeviceMock: jest.Mock<Promise<unknown>, [unknown]>;
  let findFirstDeviceMock: jest.Mock<Promise<unknown>, [unknown]>;
  let createDeviceMock: jest.Mock<Promise<unknown>, [unknown]>;
  let updateDeviceMock: jest.Mock<Promise<unknown>, [unknown]>;
  let updateManySessionMock: jest.Mock<Promise<unknown>, [unknown]>;
  let findManyStaffMock: jest.Mock<Promise<unknown>, [unknown]>;
  let createAuditLogMock: jest.Mock<Promise<unknown>, [unknown]>;
  let auditLogMock: jest.Mock<Promise<unknown>, [unknown]>;

  const pepper = 'unit-test-pepper';

  const mockBranch: Branch = {
    id: uuidv7(),
    code: 'SUC1',
    name: 'Sucursal Centro',
    address: 'Av Juárez 100',
    timezone: 'America/Mexico_City',
    isActive: true,
    createdAt: new Date('2026-10-21T00:00:00Z'),
    updatedAt: new Date('2026-10-21T00:00:00Z'),
  };

  beforeEach(() => {
    findUniqueBranchMock = jest.fn<Promise<unknown>, [unknown]>();
    findUniqueDeviceMock = jest.fn<Promise<unknown>, [unknown]>();
    findFirstDeviceMock = jest.fn<Promise<unknown>, [unknown]>();
    createDeviceMock = jest.fn<Promise<unknown>, [unknown]>();
    updateDeviceMock = jest.fn<Promise<unknown>, [unknown]>();
    updateManySessionMock = jest.fn<Promise<unknown>, [unknown]>();
    findManyStaffMock = jest.fn<Promise<unknown>, [unknown]>();
    createAuditLogMock = jest.fn<Promise<unknown>, [unknown]>();
    auditLogMock = jest.fn<Promise<unknown>, [unknown]>();

    prisma = {
      branch: {
        findUnique: findUniqueBranchMock,
      },
      device: {
        findUnique: findUniqueDeviceMock,
        findFirst: findFirstDeviceMock,
        create: createDeviceMock,
        update: updateDeviceMock,
      },
      authSession: {
        updateMany: updateManySessionMock,
      },
      staff: {
        findMany: findManyStaffMock,
      },
      auditLog: {
        create: createAuditLogMock,
      },
      $transaction: jest.fn(async (cb: (tx: unknown) => Promise<unknown>) =>
        cb(prisma),
      ),
    } as unknown as PrismaService;

    audit = {
      log: auditLogMock,
    } as unknown as AuditService;

    clock = new ClockService();
    const config = {
      getOrThrow: jest.fn().mockReturnValue(pepper),
    } as unknown as ConfigService;

    service = new DevicesService(prisma, audit, clock, config);
  });

  describe('createDevice', () => {
    it('creates a pending device with an 8-character enrollment code valid 30 minutes', async () => {
      findUniqueBranchMock.mockResolvedValue(mockBranch);
      const baseTime = new Date('2026-10-21T10:00:00Z');
      clock.setNow(baseTime);

      const deviceId = uuidv7();
      const actorStaffId = uuidv7();
      createDeviceMock.mockImplementation(
        ({ data }: { data: Record<string, unknown> }): Promise<Device> =>
          Promise.resolve({
            ...data,
            id: deviceId,
          } as unknown as Device),
      );

      const res = await service.createDevice(
        {
          branchId: mockBranch.id,
          name: 'Caja 1',
          type: DeviceType.TILL,
        },
        actorStaffId,
      );

      expect(res.device.id).toBe(deviceId);
      expect(res.device.status).toBe(DeviceStatus.PENDING);
      expect(res.enrollmentCode).toMatch(/^[A-HJ-NP-Z2-9]{8}$/);
      expect(new Date(res.expiresAt).getTime()).toBe(
        baseTime.getTime() + 30 * 60 * 1000,
      );
      expect(auditLogMock).toHaveBeenCalledWith(
        expect.objectContaining({
          action: 'device.created',
          actorStaffId,
          branchId: mockBranch.id,
          deviceId,
        }),
      );
    });

    it('throws BadRequestException if branch does not exist', async () => {
      findUniqueBranchMock.mockResolvedValue(null);

      await expect(
        service.createDevice(
          {
            branchId: uuidv7(),
            name: 'Caja 1',
            type: DeviceType.TILL,
          },
          uuidv7(),
        ),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('regenerateEnrollmentCode', () => {
    it('issues a new enrollment code for a PENDING device', async () => {
      const deviceId = uuidv7();
      const pendingDevice = {
        id: deviceId,
        branchId: mockBranch.id,
        name: 'Caja 1',
        type: DeviceType.TILL,
        status: DeviceStatus.PENDING,
        createdAt: new Date(),
        lastSeenAt: null,
        appVersion: null,
        revokedAt: null,
      } as Device;

      findUniqueDeviceMock.mockResolvedValue(pendingDevice);
      updateDeviceMock.mockImplementation(
        ({ data }: { data: Record<string, unknown> }): Promise<Device> =>
          Promise.resolve({
            ...pendingDevice,
            ...data,
          }),
      );

      const res = await service.regenerateEnrollmentCode(deviceId);
      expect(res.enrollmentCode).toMatch(/^[A-HJ-NP-Z2-9]{8}$/);
      expect(updateDeviceMock).toHaveBeenCalled();
    });

    it('throws 409 CONFLICT if device is ACTIVE', async () => {
      const deviceId = uuidv7();
      findUniqueDeviceMock.mockResolvedValue({
        id: deviceId,
        status: DeviceStatus.ACTIVE,
      });

      await expect(service.regenerateEnrollmentCode(deviceId)).rejects.toThrow(
        ConflictException,
      );
    });

    it('throws 404 NOT_FOUND if device not found', async () => {
      findUniqueDeviceMock.mockResolvedValue(null);

      await expect(service.regenerateEnrollmentCode(uuidv7())).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('activateDevice', () => {
    it('activates a pending device, creates 32-byte token and audits', async () => {
      const code = 'ABCDEFGH';
      const codeHash = hashTokenWithPepper(code, pepper);
      const baseTime = new Date('2026-10-21T10:00:00Z');
      clock.setNow(baseTime);

      const deviceId = uuidv7();
      const pendingDevice = {
        id: deviceId,
        branchId: mockBranch.id,
        name: 'Caja 1',
        type: DeviceType.TILL,
        status: DeviceStatus.PENDING,
        enrollmentCodeHash: codeHash,
        enrollmentExpiresAt: new Date(baseTime.getTime() + 10 * 60 * 1000),
        branch: mockBranch,
        createdAt: baseTime,
      };

      findFirstDeviceMock.mockResolvedValue(pendingDevice);
      updateDeviceMock.mockImplementation(
        ({ data }: { data: Record<string, unknown> }): Promise<Device> =>
          Promise.resolve({
            ...pendingDevice,
            ...data,
            status: DeviceStatus.ACTIVE,
            branch: mockBranch,
          } as unknown as Device),
      );

      const res = await service.activateDevice({
        enrollmentCode: code,
        appVersion: '1.0.0',
      });

      expect(res.device.status).toBe(DeviceStatus.ACTIVE);
      expect(res.deviceToken).toHaveLength(64);
      expect(res.branch.id).toBe(mockBranch.id);
      expect(createAuditLogMock).toHaveBeenCalled();
      const auditArg = createAuditLogMock.mock.calls[0][0] as {
        data: { action: string; deviceId: string };
      };
      expect(auditArg.data.action).toBe('device.activated');
      expect(auditArg.data.deviceId).toBe(deviceId);
    });

    it('throws 410 DEVICE_CODE_INVALID when code is expired or invalid', async () => {
      const code = 'ABCDEFGH';
      findFirstDeviceMock.mockResolvedValue(null);

      await expect(
        service.activateDevice({
          enrollmentCode: code,
          appVersion: '1.0.0',
        }),
      ).rejects.toThrow(
        new HttpException(
          {
            code: 'DEVICE_CODE_INVALID',
            message: 'Enrollment code is invalid, used, or expired',
          },
          HttpStatus.GONE,
        ),
      );
    });
  });

  describe('revokeDevice', () => {
    it('marks device REVOKED and revokes all device sessions in transaction', async () => {
      const deviceId = uuidv7();
      const actorStaffId = uuidv7();
      const activeDevice = {
        id: deviceId,
        branchId: mockBranch.id,
        name: 'Caja 1',
        type: DeviceType.TILL,
        status: DeviceStatus.ACTIVE,
        createdAt: new Date(),
      };

      findUniqueDeviceMock.mockResolvedValue(activeDevice);
      updateDeviceMock.mockImplementation(
        ({ data }: { data: Record<string, unknown> }): Promise<Device> =>
          Promise.resolve({
            ...activeDevice,
            ...data,
          } as unknown as Device),
      );

      updateManySessionMock.mockResolvedValue({ count: 1 });
      createAuditLogMock.mockResolvedValue({});

      const res = await service.revokeDevice(deviceId, actorStaffId);
      expect(res.status).toBe(DeviceStatus.REVOKED);
      expect(updateManySessionMock).toHaveBeenCalled();
      const sessionArg = updateManySessionMock.mock.calls[0][0] as {
        where: { deviceId: string; revokedAt: null };
        data: { revokedAt: Date };
      };
      expect(sessionArg.where.deviceId).toBe(deviceId);
      expect(sessionArg.where.revokedAt).toBeNull();
      expect(sessionArg.data.revokedAt).toBeInstanceOf(Date);

      expect(createAuditLogMock).toHaveBeenCalled();
      const auditArg = createAuditLogMock.mock.calls[0][0] as {
        data: { action: string; actorStaffId: string; deviceId: string };
      };
      expect(auditArg.data.action).toBe('device.revoked');
      expect(auditArg.data.actorStaffId).toBe(actorStaffId);
      expect(auditArg.data.deviceId).toBe(deviceId);
    });
  });

  describe('getStaffBundle', () => {
    it('returns active staff of branch plus owners with offline verifier and role permissions', async () => {
      const activeDevice = {
        id: uuidv7(),
        branchId: mockBranch.id,
      } as Device;

      const staffRows = [
        {
          id: uuidv7(),
          displayName: 'Cajero 1',
          role: Role.CASHIER,
          offlinePinVerifier: '$argon2id$v=19$offline-verifier',
          pinUpdatedAt: new Date(),
        },
        {
          id: uuidv7(),
          displayName: 'Owner Fernando',
          role: Role.OWNER,
          offlinePinVerifier: '$argon2id$v=19$offline-owner',
          pinUpdatedAt: new Date(),
        },
      ];

      findManyStaffMock.mockResolvedValue(staffRows);

      const res = await service.getStaffBundle(activeDevice);
      expect(res.branchId).toBe(mockBranch.id);
      expect(res.staff).toHaveLength(2);
      expect(res.staff[0].offlinePinVerifier).toBe(
        '$argon2id$v=19$offline-verifier',
      );
      expect(res.roles.OWNER).toBeDefined();
      expect(res.roles.CASHIER).toBeDefined();

      const json = JSON.stringify(res);
      expect(json).not.toContain('pinHash');
      expect(json).not.toContain('passwordHash');
    });
  });
});
