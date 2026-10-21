import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { Role } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthenticatedUser } from '../interfaces/auth.interface';
import { AuthGuard } from './auth.guard';

describe('AuthGuard', () => {
  let guard: AuthGuard;
  let reflector: Reflector;
  let jwtService: JwtService;
  let prisma: PrismaService;

  beforeEach(() => {
    reflector = new Reflector();
    jwtService = new JwtService();
    prisma = {
      authSession: {
        findUnique: jest.fn(),
      },
      rolePermission: {
        findMany: jest.fn(),
      },
    } as unknown as PrismaService;

    const configService = {
      get: jest.fn().mockImplementation((key: string) => {
        if (key === 'JWT_SECRET')
          return 'test-jwt-secret-at-least-32-chars-long';
        return undefined;
      }),
    } as unknown as ConfigService;

    guard = new AuthGuard(reflector, jwtService, prisma, configService);
  });

  function createMockContext(
    headers: Record<string, string | undefined> = {},
    isPublic = false,
  ) {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(isPublic);
    const request: {
      headers: Record<string, string | undefined>;
      user?: AuthenticatedUser;
    } = { headers, user: undefined };
    const context = {
      getHandler: () => ({}),
      getClass: () => ({}),
      switchToHttp: () => ({
        getRequest: () => request,
      }),
    } as unknown as ExecutionContext;

    return { context, request };
  }

  it('allows access to @Public() routes with no Authorization header', async () => {
    const { context } = createMockContext({}, true);
    expect(await guard.canActivate(context)).toBe(true);
  });

  it('throws AUTH_REQUIRED on protected route when header is missing', async () => {
    const { context } = createMockContext({});
    await expect(guard.canActivate(context)).rejects.toThrow(
      UnauthorizedException,
    );
  });

  it('throws AUTH_REQUIRED when token format is invalid', async () => {
    const { context } = createMockContext({ authorization: 'Basic 12345' });
    await expect(guard.canActivate(context)).rejects.toThrow(
      UnauthorizedException,
    );
  });

  it('throws AUTH_TOKEN_EXPIRED when access token is expired', async () => {
    jest.spyOn(jwtService, 'verifyAsync').mockRejectedValue({
      name: 'TokenExpiredError',
    });
    const { context } = createMockContext({ authorization: 'Bearer expired' });

    try {
      await guard.canActivate(context);
      fail('Expected guard to throw');
    } catch (err: unknown) {
      expect(err).toBeInstanceOf(UnauthorizedException);
      const res = (err as UnauthorizedException).getResponse() as Record<
        string,
        unknown
      >;
      expect(res.code).toBe('AUTH_TOKEN_EXPIRED');
    }
  });

  it('throws AUTH_REQUIRED when session is revoked', async () => {
    jest.spyOn(jwtService, 'verifyAsync').mockResolvedValue({
      sub: 'staff-uuid',
      sid: 'session-uuid',
      branchIds: [],
    });
    (prisma.authSession.findUnique as jest.Mock).mockResolvedValue({
      id: 'session-uuid',
      staffId: 'staff-uuid',
      expiresAt: new Date(Date.now() + 100000),
      revokedAt: new Date(), // revoked
      staff: { isActive: true, role: Role.CASHIER, staffBranches: [] },
    });

    const { context } = createMockContext({ authorization: 'Bearer token' });
    await expect(guard.canActivate(context)).rejects.toThrow(
      UnauthorizedException,
    );
  });

  it('throws AUTH_REQUIRED when staff member is inactive', async () => {
    jest.spyOn(jwtService, 'verifyAsync').mockResolvedValue({
      sub: 'staff-uuid',
      sid: 'session-uuid',
      branchIds: [],
    });
    (prisma.authSession.findUnique as jest.Mock).mockResolvedValue({
      id: 'session-uuid',
      staffId: 'staff-uuid',
      expiresAt: new Date(Date.now() + 100000),
      revokedAt: null,
      staff: { isActive: false, role: Role.CASHIER, staffBranches: [] }, // inactive
    });

    const { context } = createMockContext({ authorization: 'Bearer token' });
    await expect(guard.canActivate(context)).rejects.toThrow(
      UnauthorizedException,
    );
  });

  it('authenticates valid token, loads permissions and sets request.user', async () => {
    jest.spyOn(jwtService, 'verifyAsync').mockResolvedValue({
      sub: 'staff-uuid',
      sid: 'session-uuid',
      branchIds: ['branch-1'],
    });
    (prisma.authSession.findUnique as jest.Mock).mockResolvedValue({
      id: 'session-uuid',
      staffId: 'staff-uuid',
      deviceId: null,
      expiresAt: new Date(Date.now() + 100000),
      revokedAt: null,
      staff: {
        id: 'staff-uuid',
        isActive: true,
        role: Role.CASHIER,
        staffBranches: [{ branchId: 'branch-1' }],
      },
    });
    (prisma.rolePermission.findMany as jest.Mock).mockResolvedValue([
      { permissionKey: 'sale.create' },
    ]);

    const { context, request } = createMockContext({
      authorization: 'Bearer valid-token',
    });
    expect(await guard.canActivate(context)).toBe(true);
    expect(request.user).toBeDefined();
    expect(request.user?.staffId).toBe('staff-uuid');
    expect(request.user?.permissions).toContain('sale.create');
  });
});
