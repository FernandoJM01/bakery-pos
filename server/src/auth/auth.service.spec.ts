import { HttpException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Role } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { hashPassword } from '../common/crypto';
import { PrismaService } from '../prisma/prisma.service';
import { AuthService } from './auth.service';

describe('AuthService', () => {
  let service: AuthService;
  let findFirstStaffSpy: jest.Mock<Promise<unknown>, [unknown]>;
  let updateStaffSpy: jest.Mock<Promise<unknown>, [unknown]>;
  let createSessionSpy: jest.Mock<Promise<unknown>, [unknown]>;
  let findUniqueSessionSpy: jest.Mock<Promise<unknown>, [unknown]>;
  let findFirstSessionSpy: jest.Mock<Promise<unknown>, [unknown]>;
  let updateSessionSpy: jest.Mock<Promise<unknown>, [unknown]>;
  let auditLogSpy: jest.Mock<Promise<unknown>, [unknown]>;

  beforeEach(() => {
    findFirstStaffSpy = jest.fn<Promise<unknown>, [unknown]>();
    updateStaffSpy = jest.fn<Promise<unknown>, [unknown]>();
    createSessionSpy = jest.fn<Promise<unknown>, [unknown]>();
    findUniqueSessionSpy = jest.fn<Promise<unknown>, [unknown]>();
    findFirstSessionSpy = jest.fn<Promise<unknown>, [unknown]>();
    updateSessionSpy = jest.fn<Promise<unknown>, [unknown]>();
    auditLogSpy = jest
      .fn<Promise<unknown>, [unknown]>()
      .mockResolvedValue(undefined);

    const prisma = {
      staff: {
        findFirst: findFirstStaffSpy,
        findUnique: jest.fn(),
        update: updateStaffSpy,
      },
      authSession: {
        create: createSessionSpy,
        findUnique: findUniqueSessionSpy,
        findFirst: findFirstSessionSpy,
        update: updateSessionSpy,
      },
      rolePermission: {
        findMany: jest.fn().mockResolvedValue([]),
      },
    } as unknown as PrismaService;

    const jwtService = {
      signAsync: jest.fn().mockResolvedValue('mock-jwt-token'),
    } as unknown as JwtService;

    const auditService = {
      log: auditLogSpy,
    } as unknown as AuditService;

    const configService = {
      get: jest.fn().mockImplementation((key: string) => {
        if (key === 'DEVICE_TOKEN_PEPPER')
          return 'test-pepper-at-least-32-chars-long';
        if (key === 'JWT_SECRET')
          return 'test-jwt-secret-at-least-32-chars-long';
        return undefined;
      }),
    } as unknown as ConfigService;

    service = new AuthService(prisma, jwtService, auditService, configService);
  });

  describe('passwordLogin', () => {
    it('throws AUTH_INVALID_CREDENTIALS and audits login_failure on unknown email', async () => {
      findFirstStaffSpy.mockResolvedValue(null);

      await expect(
        service.passwordLogin({
          email: 'unknown@bakery.local',
          password: 'SomePassword123!',
        }),
      ).rejects.toThrow(UnauthorizedException);

      expect(auditLogSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          action: 'auth.login_failure',
          actorStaffId: null,
        }),
      );
    });

    it('throws AUTH_LOCKED when account is already locked', async () => {
      const lockedUntil = new Date(Date.now() + 600000);
      findFirstStaffSpy.mockResolvedValue({
        id: 'staff-uuid',
        email: 'locked@bakery.local',
        lockedUntil,
        staffBranches: [],
      });

      try {
        await service.passwordLogin({
          email: 'locked@bakery.local',
          password: 'Password123!',
        });
        fail('Expected locked exception');
      } catch (err: unknown) {
        expect(err).toBeInstanceOf(HttpException);
        const res = (err as HttpException).getResponse() as Record<
          string,
          unknown
        >;
        expect(res.code).toBe('AUTH_LOCKED');
      }
    });

    it('increments failed attempts on wrong password and locks account on 10th failure', async () => {
      const realPasswordHash = await hashPassword('CorrectPassword123!');
      findFirstStaffSpy.mockResolvedValue({
        id: 'staff-uuid',
        email: 'staff@bakery.local',
        passwordHash: realPasswordHash,
        failedPinAttempts: 9,
        lockedUntil: null,
        staffBranches: [],
      });

      await expect(
        service.passwordLogin({
          email: 'staff@bakery.local',
          password: 'WrongPassword123!',
        }),
      ).rejects.toThrow(HttpException);

      const updateArgs = updateStaffSpy.mock.calls[0][0] as {
        where: { id: string };
        data: { failedPinAttempts: number; lockedUntil?: Date };
      };
      expect(updateArgs.where.id).toBe('staff-uuid');
      expect(updateArgs.data.failedPinAttempts).toBe(10);
      expect(updateArgs.data.lockedUntil).toBeInstanceOf(Date);

      expect(auditLogSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          action: 'auth.locked',
          actorStaffId: 'staff-uuid',
        }),
      );
    });

    it('logs in successfully, creates session, and audits login_success', async () => {
      const realPasswordHash = await hashPassword('CorrectPassword123!');
      const staff = {
        id: 'staff-uuid',
        fullName: 'Fernando Owner',
        displayName: 'Fernando',
        role: Role.OWNER,
        email: 'owner@bakery.local',
        passwordHash: realPasswordHash,
        failedPinAttempts: 3,
        lockedUntil: null,
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date(),
        staffBranches: [{ branchId: 'b1' }],
      };
      findFirstStaffSpy.mockResolvedValue(staff);
      createSessionSpy.mockResolvedValue({
        id: 'session-uuid',
        staffId: 'staff-uuid',
      });

      const response = await service.passwordLogin({
        email: 'owner@bakery.local',
        password: 'CorrectPassword123!',
      });

      expect(response.accessToken).toBe('mock-jwt-token');
      expect(response.refreshToken).toBeDefined();
      expect(response.me.staff.email).toBe('owner@bakery.local');
      expect(response.me.staff).not.toHaveProperty('passwordHash');
      expect(response.me.staff).not.toHaveProperty('pinHash');
      expect(response.me.permissions.length).toBe(26);

      expect(updateStaffSpy).toHaveBeenCalledWith({
        where: { id: 'staff-uuid' },
        data: { failedPinAttempts: 0, lockedUntil: null },
      });
      expect(auditLogSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          action: 'auth.login_success',
          actorStaffId: 'staff-uuid',
        }),
      );
    });
  });

  describe('refreshToken', () => {
    it('revokes session when rotated token is reused', async () => {
      findUniqueSessionSpy.mockResolvedValue(null);
      findFirstSessionSpy.mockResolvedValue({
        id: 'session-uuid',
        staffId: 'staff-uuid',
      });

      await expect(service.refreshToken('reused-token')).rejects.toThrow(
        UnauthorizedException,
      );

      const revokeArgs = updateSessionSpy.mock.calls[0][0] as {
        where: { id: string };
        data: { revokedAt?: Date };
      };
      expect(revokeArgs.where.id).toBe('session-uuid');
      expect(revokeArgs.data.revokedAt).toBeInstanceOf(Date);
    });

    it('rotates refresh token and returns new token pair', async () => {
      findUniqueSessionSpy.mockResolvedValue({
        id: 'session-uuid',
        staffId: 'staff-uuid',
        revokedAt: null,
        expiresAt: new Date(Date.now() + 3600000),
        staff: {
          id: 'staff-uuid',
          isActive: true,
          staffBranches: [{ branchId: 'b1' }],
        },
      });

      const result = await service.refreshToken('valid-token');
      expect(result.accessToken).toBe('mock-jwt-token');
      expect(result.refreshToken).toBeDefined();

      const rotateArgs = updateSessionSpy.mock.calls[0][0] as {
        where: { id: string };
        data: { rotatedTokenHashes?: { push?: string } };
      };
      expect(rotateArgs.where.id).toBe('session-uuid');
      expect(typeof rotateArgs.data.rotatedTokenHashes?.push).toBe('string');
    });
  });

  describe('logout', () => {
    it('revokes session and logs auth.logout', async () => {
      await service.logout({
        staffId: 'staff-uuid',
        sessionId: 'session-uuid',
        deviceId: null,
        role: Role.OWNER,
        branchIds: [],
        permissions: [],
      });

      const logoutArgs = updateSessionSpy.mock.calls[0][0] as {
        where: { id: string };
        data: { revokedAt?: Date };
      };
      expect(logoutArgs.where.id).toBe('session-uuid');
      expect(logoutArgs.data.revokedAt).toBeInstanceOf(Date);

      expect(auditLogSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          action: 'auth.logout',
          actorStaffId: 'staff-uuid',
        }),
      );
    });
  });
});
