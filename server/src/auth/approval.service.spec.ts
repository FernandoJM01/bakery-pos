import {
  ConflictException,
  ForbiddenException,
  HttpException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Device, DeviceStatus, DeviceType, Role } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { AuditService } from '../audit/audit.service';
import { ClockService } from '../common/clock.service';
import { hashPin, hashTokenWithPepper } from '../common/crypto';
import { PrismaService } from '../prisma/prisma.service';
import { ApprovalService } from './approval.service';
import { AuthenticatedUser } from './interfaces/auth.interface';

describe('ApprovalService', () => {
  let service: ApprovalService;
  let clock: ClockService;

  let findUniqueStaffMock: jest.Mock<Promise<unknown>, [unknown]>;
  let updateStaffMock: jest.Mock<Promise<unknown>, [unknown]>;
  let updateManyStaffMock: jest.Mock<Promise<unknown>, [unknown]>;
  let findUniqueRolePermMock: jest.Mock<Promise<unknown>, [unknown]>;
  let createApprovalMock: jest.Mock<Promise<unknown>, [unknown]>;
  let findUniqueApprovalMock: jest.Mock<Promise<unknown>, [unknown]>;
  let updateManyApprovalMock: jest.Mock<Promise<unknown>, [unknown]>;
  let auditLogMock: jest.Mock<Promise<unknown>, [unknown]>;

  const pepper = 'test-pepper-at-least-32-chars-long';
  const branchId = uuidv7();

  const mockDevice: Device = {
    id: uuidv7(),
    branchId,
    name: 'Caja 1',
    type: DeviceType.TILL,
    status: DeviceStatus.ACTIVE,
    enrollmentCodeHash: null,
    enrollmentExpiresAt: null,
    tokenHash: 'tokenhash',
    lastSeenAt: null,
    appVersion: '1.0.0',
    createdBy: null,
    createdAt: new Date(),
    revokedAt: null,
  };

  const mockRequester: AuthenticatedUser = {
    staffId: uuidv7(),
    sessionId: uuidv7(),
    deviceId: mockDevice.id,
    role: 'CASHIER',
    branchIds: [branchId],
    permissions: ['sale.create'],
  };

  beforeEach(() => {
    clock = new ClockService();
    clock.setNow(new Date('2026-10-23T10:00:00Z'));

    findUniqueStaffMock = jest.fn<Promise<unknown>, [unknown]>();
    updateStaffMock = jest.fn<Promise<unknown>, [unknown]>();
    updateManyStaffMock = jest
      .fn<Promise<unknown>, [unknown]>()
      .mockResolvedValue({ count: 0 });
    findUniqueRolePermMock = jest.fn<Promise<unknown>, [unknown]>();
    createApprovalMock = jest.fn<Promise<unknown>, [unknown]>();
    findUniqueApprovalMock = jest.fn<Promise<unknown>, [unknown]>();
    updateManyApprovalMock = jest
      .fn<Promise<unknown>, [unknown]>()
      .mockResolvedValue({ count: 1 });
    auditLogMock = jest
      .fn<Promise<unknown>, [unknown]>()
      .mockResolvedValue(undefined);

    const prismaMock = {
      staff: {
        findUnique: findUniqueStaffMock,
        update: updateStaffMock,
        updateMany: updateManyStaffMock,
      },
      rolePermission: {
        findUnique: findUniqueRolePermMock,
      },
      approval: {
        create: createApprovalMock,
        findUnique: findUniqueApprovalMock,
        updateMany: updateManyApprovalMock,
      },
    } as unknown as PrismaService;

    const auditMock = {
      log: auditLogMock,
    } as unknown as AuditService;

    const mockConfig = {
      get: jest.fn().mockReturnValue(pepper),
    } as unknown as ConfigService;

    service = new ApprovalService(prismaMock, auditMock, clock, mockConfig);
  });

  describe('createApproval', () => {
    it('refuses self-approval (PERMISSION_DENIED)', async () => {
      await expect(
        service.createApproval(
          {
            approverStaffId: mockRequester.staffId,
            pin: '1234',
            action: 'sale.discount_over_limit',
          },
          mockRequester,
          mockDevice,
        ),
      ).rejects.toThrow(ForbiddenException);

      const auditArgs = auditLogMock.mock.calls[0][0] as {
        action: string;
        actorStaffId: string;
        data?: { reason?: string };
      };
      expect(auditArgs.action).toBe('auth.approval_denied');
      expect(auditArgs.actorStaffId).toBe(mockRequester.staffId);
      expect(auditArgs.data?.reason).toBe('self_approval');
    });

    it('refuses if approver is not found or inactive (PERMISSION_DENIED)', async () => {
      findUniqueStaffMock.mockResolvedValue(null);

      await expect(
        service.createApproval(
          {
            approverStaffId: uuidv7(),
            pin: '1234',
            action: 'sale.discount_over_limit',
          },
          mockRequester,
          mockDevice,
        ),
      ).rejects.toThrow(ForbiddenException);
    });

    it('refuses if approver is from another branch and not owner (PERMISSION_DENIED)', async () => {
      const { pinHash } = await hashPin('1234');
      findUniqueStaffMock.mockResolvedValue({
        id: uuidv7(),
        role: Role.BRANCH_MANAGER,
        isActive: true,
        pinHash,
        failedPinAttempts: 0,
        lockedUntil: null,
        staffBranches: [{ branchId: uuidv7() }], // different branch
      });

      await expect(
        service.createApproval(
          {
            approverStaffId: uuidv7(),
            pin: '1234',
            action: 'sale.discount_over_limit',
          },
          mockRequester,
          mockDevice,
        ),
      ).rejects.toThrow(ForbiddenException);
    });

    it('refuses if approver lacks the requested permission (PERMISSION_DENIED)', async () => {
      const { pinHash } = await hashPin('1234');
      findUniqueStaffMock.mockResolvedValue({
        id: uuidv7(),
        role: Role.BRANCH_MANAGER,
        isActive: true,
        pinHash,
        failedPinAttempts: 0,
        lockedUntil: null,
        staffBranches: [{ branchId }],
      });
      findUniqueRolePermMock.mockResolvedValue(null);

      await expect(
        service.createApproval(
          {
            approverStaffId: uuidv7(),
            pin: '1234',
            action: 'catalog.manage',
          },
          mockRequester,
          mockDevice,
        ),
      ).rejects.toThrow(ForbiddenException);
    });

    it("A12: a cashier's PIN cannot approve, even an action cashiers hold", async () => {
      const { pinHash } = await hashPin('1234');
      findUniqueStaffMock.mockResolvedValue({
        id: uuidv7(),
        role: Role.CASHIER,
        isActive: true,
        pinHash,
        failedPinAttempts: 0,
        lockedUntil: null,
        staffBranches: [{ branchId }],
      });
      findUniqueRolePermMock.mockResolvedValue({
        role: Role.CASHIER,
        permissionKey: 'sale.create',
      });

      await expect(
        service.createApproval(
          { approverStaffId: uuidv7(), pin: '1234', action: 'sale.create' },
          mockRequester,
          mockDevice,
        ),
      ).rejects.toThrow(ForbiddenException);
      expect(createApprovalMock).not.toHaveBeenCalled();
      const audit = auditLogMock.mock.calls[0][0] as {
        action: string;
        data: { reason: string };
      };
      expect(audit.action).toBe('auth.approval_denied');
      expect(audit.data.reason).toBe('role_cannot_approve');
    });

    it('refuses a session that belongs to a different device', async () => {
      await expect(
        service.createApproval(
          { approverStaffId: uuidv7(), pin: '1234', action: 'sale.refund' },
          { ...mockRequester, deviceId: uuidv7() },
          mockDevice,
        ),
      ).rejects.toThrow(ForbiddenException);
      expect(findUniqueStaffMock).not.toHaveBeenCalled();
    });

    it('locks approver after 5 wrong PIN attempts (AUTH_LOCKED)', async () => {
      const { pinHash } = await hashPin('1234');
      const approverId = uuidv7();
      findUniqueStaffMock.mockResolvedValue({
        id: approverId,
        role: Role.BRANCH_MANAGER,
        isActive: true,
        pinHash,
        failedPinAttempts: 4,
        lockedUntil: null,
        staffBranches: [{ branchId }],
      });
      findUniqueRolePermMock.mockResolvedValue({
        role: Role.BRANCH_MANAGER,
        permissionKey: 'sale.discount_over_limit',
      });
      updateStaffMock.mockResolvedValue({
        id: approverId,
        failedPinAttempts: 5,
        lockedUntil: null,
      });

      await expect(
        service.createApproval(
          {
            approverStaffId: approverId,
            pin: '9999',
            action: 'sale.discount_over_limit',
          },
          mockRequester,
          mockDevice,
        ),
      ).rejects.toThrow(HttpException);

      expect(updateStaffMock).toHaveBeenCalledWith({
        where: { id: approverId },
        data: { failedPinAttempts: { increment: 1 } },
        select: { failedPinAttempts: true, lockedUntil: true },
      });

      const lockCall = updateManyStaffMock.mock.calls.find(
        (c) => (c[0] as { data?: { lockedUntil?: Date } }).data?.lockedUntil,
      )?.[0] as {
        where: { id: string; lockedUntil: null };
        data: { lockedUntil: Date };
      };
      expect(lockCall).toBeDefined();
      expect(lockCall.where.id).toBe(approverId);
      expect(lockCall.where.lockedUntil).toBeNull();
      expect(lockCall.data.lockedUntil).toBeInstanceOf(Date);

      const lockAudit = auditLogMock.mock.calls[1][0] as {
        action: string;
        actorStaffId: string;
      };
      expect(lockAudit.action).toBe('auth.locked');
      expect(lockAudit.actorStaffId).toBe(approverId);
    });

    it('creates approval token and returns ApprovalResponse on valid PIN', async () => {
      const { pinHash } = await hashPin('1234');
      const approverId = uuidv7();
      findUniqueStaffMock.mockResolvedValue({
        id: approverId,
        role: Role.BRANCH_MANAGER,
        isActive: true,
        pinHash,
        failedPinAttempts: 2,
        lockedUntil: null,
        staffBranches: [{ branchId }],
      });
      findUniqueRolePermMock.mockResolvedValue({
        role: Role.BRANCH_MANAGER,
        permissionKey: 'sale.discount_over_limit',
      });
      createApprovalMock.mockResolvedValue({});

      const res = await service.createApproval(
        {
          approverStaffId: approverId,
          pin: '1234',
          action: 'sale.discount_over_limit',
          reference: 'SALE-100',
        },
        mockRequester,
        mockDevice,
      );

      expect(res.approvalToken).toBeDefined();
      expect(res.action).toBe('sale.discount_over_limit');
      expect(res.approverStaffId).toBe(approverId);
      expect(new Date(res.expiresAt).getTime()).toBeGreaterThan(
        clock.now().getTime(),
      );

      // Reset attempts
      expect(updateStaffMock).toHaveBeenCalledWith({
        where: { id: approverId },
        data: { failedPinAttempts: 0, lockedUntil: null },
      });

      // Audit logged with actor and approver
      const grantAudit = auditLogMock.mock.calls[0][0] as {
        action: string;
        actorStaffId: string;
        approverStaffId: string;
        data?: { action?: string; reference?: string };
      };
      expect(grantAudit.action).toBe('auth.approval_granted');
      expect(grantAudit.actorStaffId).toBe(mockRequester.staffId);
      expect(grantAudit.approverStaffId).toBe(approverId);
      expect(grantAudit.data?.action).toBe('sale.discount_over_limit');
      expect(grantAudit.data?.reference).toBe('SALE-100');
    });
  });

  describe('consume', () => {
    it('consumes valid approval token atomically', async () => {
      const token = 'valid-token';
      const tokenHash = hashTokenWithPepper(token, pepper);
      const requesterStaffId = uuidv7();

      findUniqueApprovalMock.mockResolvedValue({
        id: uuidv7(),
        tokenHash,
        action: 'sale.discount_over_limit',
        requesterStaffId,
        expiresAt: new Date(clock.now().getTime() + 60000),
        usedAt: null,
      });

      updateManyApprovalMock.mockResolvedValue({ count: 1 });

      const consumed = await service.consume(
        token,
        'sale.discount_over_limit',
        requesterStaffId,
      );
      expect(consumed.usedAt).toBeDefined();
    });

    it('rejects already used token with ConflictException (APPROVAL_ALREADY_USED)', async () => {
      const token = 'already-used';
      const tokenHash = hashTokenWithPepper(token, pepper);
      const requesterStaffId = uuidv7();

      findUniqueApprovalMock.mockResolvedValue({
        id: uuidv7(),
        tokenHash,
        action: 'sale.discount_over_limit',
        requesterStaffId,
        expiresAt: new Date(clock.now().getTime() + 60000),
        usedAt: new Date(),
      });

      await expect(
        service.consume(token, 'sale.discount_over_limit', requesterStaffId),
      ).rejects.toThrow(ConflictException);
    });

    it('rejects expired token with GONE (APPROVAL_EXPIRED)', async () => {
      const token = 'expired';
      const tokenHash = hashTokenWithPepper(token, pepper);
      const requesterStaffId = uuidv7();

      findUniqueApprovalMock.mockResolvedValue({
        id: uuidv7(),
        tokenHash,
        action: 'sale.discount_over_limit',
        requesterStaffId,
        expiresAt: new Date(clock.now().getTime() - 1000),
        usedAt: null,
      });

      await expect(
        service.consume(token, 'sale.discount_over_limit', requesterStaffId),
      ).rejects.toThrow(HttpException);
    });

    it('rejects action mismatch (APPROVAL_ACTION_MISMATCH)', async () => {
      const token = 'action-mismatch';
      const tokenHash = hashTokenWithPepper(token, pepper);
      const requesterStaffId = uuidv7();

      findUniqueApprovalMock.mockResolvedValue({
        id: uuidv7(),
        tokenHash,
        action: 'sale.refund',
        requesterStaffId,
        expiresAt: new Date(clock.now().getTime() + 60000),
        usedAt: null,
      });

      await expect(
        service.consume(token, 'sale.discount_over_limit', requesterStaffId),
      ).rejects.toThrow(ForbiddenException);
    });

    it('rejects requester mismatch (APPROVAL_REQUESTER_MISMATCH)', async () => {
      const token = 'requester-mismatch';
      const tokenHash = hashTokenWithPepper(token, pepper);

      findUniqueApprovalMock.mockResolvedValue({
        id: uuidv7(),
        tokenHash,
        action: 'sale.discount_over_limit',
        requesterStaffId: uuidv7(),
        expiresAt: new Date(clock.now().getTime() + 60000),
        usedAt: null,
      });

      await expect(
        service.consume(
          token,
          'sale.discount_over_limit',
          uuidv7(), // different requester
        ),
      ).rejects.toThrow(ForbiddenException);
    });

    it('rejects invalid token with UnauthorizedException (APPROVAL_INVALID)', async () => {
      findUniqueApprovalMock.mockResolvedValue(null);

      await expect(
        service.consume('unknown-token', 'sale.refund', uuidv7()),
      ).rejects.toThrow(UnauthorizedException);
    });
  });
});
