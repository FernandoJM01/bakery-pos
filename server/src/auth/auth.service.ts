import {
  HttpException,
  HttpStatus,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Device, Role, Staff, StaffBranch } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { AuditService } from '../audit/audit.service';
import { ClockService } from '../common/clock.service';
import {
  generateToken,
  getDummyArgon2Hash,
  hashTokenWithPepper,
  verifyHash,
} from '../common/crypto';
import { PERMISSION_KEYS, PermissionKey } from '../common/permissions';
import { PrismaService } from '../prisma/prisma.service';
import { PasswordLoginDto } from './dto/password-login.dto';
import { PinLoginDto } from './dto/pin-login.dto';
import { AuthenticatedUser, JwtPayload } from './interfaces/auth.interface';
import { getNextFourAm } from './session-expiry';

export interface TokenPairResponse {
  accessToken: string;
  accessTokenExpiresAt: string;
  refreshToken: string;
  refreshTokenExpiresAt: string;
}

export interface FormattedStaff {
  id: string;
  fullName: string;
  displayName: string;
  role: Role;
  email: string | null;
  branchIds: string[];
  isActive: boolean;
  hasPassword: boolean;
  lockedUntil: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface MeResponse {
  staff: FormattedStaff;
  permissions: PermissionKey[];
  deviceId: string | null;
}

export interface LoginResponse extends TokenPairResponse {
  me: MeResponse;
}

@Injectable()
export class AuthService {
  private readonly deviceTokenPepper: string;
  private readonly jwtSecret: string;

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly auditService: AuditService,
    private readonly clock: ClockService,
    configService: ConfigService,
  ) {
    this.deviceTokenPepper = configService.get<string>('DEVICE_TOKEN_PEPPER')!;
    this.jwtSecret = configService.get<string>('JWT_SECRET')!;
  }

  async passwordLogin(dto: PasswordLoginDto): Promise<LoginResponse> {
    const email = dto.email.trim().toLowerCase();
    const staff = await this.prisma.staff.findFirst({
      where: { email: { equals: email, mode: 'insensitive' } },
      include: { staffBranches: true },
    });

    if (!staff) {
      // Constant-time execution for non-existent users
      const dummyHash = await getDummyArgon2Hash();
      await verifyHash(dummyHash, dto.password);

      await this.auditService.log({
        action: 'auth.login_failure',
        actorStaffId: null,
        data: { email, reason: 'unknown_email' },
      });

      throw new UnauthorizedException({
        code: 'AUTH_INVALID_CREDENTIALS',
        message: 'Invalid credentials',
      });
    }

    // Back office lockout uses its own counters, never the till PIN ones.
    const now = this.clock.now();
    if (staff.passwordLockedUntil && staff.passwordLockedUntil > now) {
      throw new HttpException(
        {
          code: 'AUTH_LOCKED',
          message: 'Account is locked due to too many failed login attempts',
          details: { lockedUntil: staff.passwordLockedUntil.toISOString() },
        },
        HttpStatus.LOCKED,
      );
    }

    // Always run one argon2 verification so timing does not reveal whether
    // the staff member has a password.
    const isValidPassword = staff.passwordHash
      ? await verifyHash(staff.passwordHash, dto.password)
      : await verifyHash(await getDummyArgon2Hash(), dto.password).then(
          () => false,
        );

    if (!isValidPassword) {
      // 1. Reset if old lock expired
      await this.prisma.staff.updateMany({
        where: { id: staff.id, passwordLockedUntil: { lte: now } },
        data: {
          failedPasswordAttempts: 0,
          passwordFailureWindowStart: null,
          passwordLockedUntil: null,
        },
      });

      // 2. Reset if window expired (15 minutes)
      const windowCutoff = new Date(now.getTime() - 15 * 60 * 1000);
      await this.prisma.staff.updateMany({
        where: {
          id: staff.id,
          passwordFailureWindowStart: { lt: windowCutoff },
        },
        data: {
          failedPasswordAttempts: 0,
          passwordFailureWindowStart: null,
        },
      });

      // 3. Initialize window start if null
      await this.prisma.staff.updateMany({
        where: {
          id: staff.id,
          passwordFailureWindowStart: null,
        },
        data: {
          passwordFailureWindowStart: now,
        },
      });

      // 4. Atomically increment failed password attempts
      const updated = await this.prisma.staff.update({
        where: { id: staff.id },
        data: { failedPasswordAttempts: { increment: 1 } },
        select: {
          failedPasswordAttempts: true,
          passwordLockedUntil: true,
          email: true,
        },
      });

      // 5. Check if attempts >= 10
      if (
        updated.failedPasswordAttempts >= 10 ||
        (updated.passwordLockedUntil && updated.passwordLockedUntil > now)
      ) {
        let lockedUntil = updated.passwordLockedUntil;
        if (!lockedUntil || lockedUntil <= now) {
          lockedUntil = new Date(now.getTime() + 15 * 60 * 1000);
          await this.prisma.staff.updateMany({
            where: { id: staff.id, passwordLockedUntil: null },
            data: {
              passwordLockedUntil: lockedUntil,
              passwordFailureWindowStart: null,
            },
          });
        }

        await this.auditService.log({
          action: 'auth.login_failure',
          actorStaffId: staff.id,
          data: { email: staff.email, reason: 'invalid_password' },
        });

        await this.auditService.log({
          action: 'auth.locked',
          actorStaffId: staff.id,
          data: { lockedUntil: lockedUntil.toISOString() },
        });

        throw new HttpException(
          {
            code: 'AUTH_LOCKED',
            message: 'Account is locked due to too many failed login attempts',
            details: { lockedUntil: lockedUntil.toISOString() },
          },
          HttpStatus.LOCKED,
        );
      }

      await this.auditService.log({
        action: 'auth.login_failure',
        actorStaffId: staff.id,
        data: { email: staff.email, reason: 'invalid_password' },
      });

      throw new UnauthorizedException({
        code: 'AUTH_INVALID_CREDENTIALS',
        message: 'Invalid credentials',
      });
    }

    if (!staff.isActive) {
      // Same answer as a wrong password: do not confirm the password is right.
      await this.auditService.log({
        action: 'auth.login_failure',
        actorStaffId: staff.id,
        data: { email: staff.email, reason: 'inactive' },
      });
      throw new UnauthorizedException({
        code: 'AUTH_INVALID_CREDENTIALS',
        message: 'Invalid credentials',
      });
    }

    await this.prisma.staff.update({
      where: { id: staff.id },
      data: {
        failedPasswordAttempts: 0,
        passwordFailureWindowStart: null,
        passwordLockedUntil: null,
      },
    });

    const sessionId = uuidv7();
    const rawRefreshToken = generateToken();
    const refreshTokenHash = hashTokenWithPepper(
      rawRefreshToken,
      this.deviceTokenPepper,
    );
    const refreshTokenExpiresAt = new Date(now.getTime() + 12 * 60 * 60 * 1000); // 12 hours

    const session = await this.prisma.authSession.create({
      data: {
        id: sessionId,
        staffId: staff.id,
        deviceId: null,
        refreshTokenHash,
        expiresAt: refreshTokenExpiresAt,
      },
    });

    await this.auditService.log({
      action: 'auth.login_success',
      actorStaffId: staff.id,
      data: { method: 'password', sessionId: session.id },
    });

    const branchIds = staff.staffBranches.map((sb) => sb.branchId);
    const payload: JwtPayload = {
      sub: staff.id,
      sid: session.id,
      branchIds,
    };

    const accessToken = await this.jwtService.signAsync(payload, {
      secret: this.jwtSecret,
      expiresIn: '15m',
    });
    const accessTokenExpiresAt = new Date(now.getTime() + 15 * 60 * 1000);

    const permissions = await this.getStaffPermissions(staff.role);

    return {
      accessToken,
      accessTokenExpiresAt: accessTokenExpiresAt.toISOString(),
      refreshToken: rawRefreshToken,
      refreshTokenExpiresAt: refreshTokenExpiresAt.toISOString(),
      me: {
        staff: this.formatStaff(staff),
        permissions,
        deviceId: null,
      },
    };
  }

  async pinLogin(dto: PinLoginDto, device: Device): Promise<LoginResponse> {
    const now = this.clock.now();

    const branch = await this.prisma.branch.findUnique({
      where: { id: device.branchId },
    });
    if (!branch || !branch.isActive) {
      throw new UnauthorizedException({
        code: 'AUTH_NOT_ALLOWED',
        message: 'Branch not found or inactive',
      });
    }

    const staff = await this.prisma.staff.findUnique({
      where: { id: dto.staffId },
      include: { staffBranches: true },
    });

    if (!staff || !staff.isActive) {
      const dummy = await getDummyArgon2Hash();
      await verifyHash(dummy, dto.pin);
      await this.auditService.log({
        action: 'auth.login_failure',
        branchId: device.branchId,
        deviceId: device.id,
        actorStaffId: staff ? staff.id : null,
        data: { reason: 'unknown_or_inactive' },
      });
      throw new UnauthorizedException({
        code: 'AUTH_NOT_ALLOWED',
        message: 'Staff member is not allowed in this branch or is inactive',
      });
    }

    const isOwner = staff.role === Role.OWNER;
    const isAssigned = staff.staffBranches.some(
      (sb) => sb.branchId === device.branchId,
    );
    if (!isOwner && !isAssigned) {
      await this.auditService.log({
        action: 'auth.login_failure',
        branchId: device.branchId,
        deviceId: device.id,
        actorStaffId: staff.id,
        data: { reason: 'branch_not_allowed' },
      });
      throw new UnauthorizedException({
        code: 'AUTH_NOT_ALLOWED',
        message: 'Staff member is not allowed in this branch or is inactive',
      });
    }

    // Check PIN lockout
    if (staff.lockedUntil && staff.lockedUntil > now) {
      throw new HttpException(
        {
          code: 'AUTH_LOCKED',
          message: 'Account is locked due to too many failed PIN attempts',
          details: { lockedUntil: staff.lockedUntil.toISOString() },
        },
        HttpStatus.LOCKED,
      );
    }

    // Verify PIN
    const isValidPin = await verifyHash(staff.pinHash, dto.pin);
    if (!isValidPin) {
      // 1. Reset if old lock expired
      await this.prisma.staff.updateMany({
        where: { id: staff.id, lockedUntil: { lte: now } },
        data: { failedPinAttempts: 0, lockedUntil: null },
      });

      // 2. Atomically increment failed attempts
      const updated = await this.prisma.staff.update({
        where: { id: staff.id },
        data: { failedPinAttempts: { increment: 1 } },
        select: { failedPinAttempts: true, lockedUntil: true },
      });

      // 3. If attempts >= 5, lock for 5 minutes
      if (
        updated.failedPinAttempts >= 5 ||
        (updated.lockedUntil && updated.lockedUntil > now)
      ) {
        let lockedUntil = updated.lockedUntil;
        if (!lockedUntil || lockedUntil <= now) {
          lockedUntil = new Date(now.getTime() + 5 * 60 * 1000);
          await this.prisma.staff.updateMany({
            where: { id: staff.id, lockedUntil: null },
            data: { lockedUntil },
          });
        }

        await this.auditService.log({
          action: 'auth.login_failure',
          branchId: device.branchId,
          deviceId: device.id,
          actorStaffId: staff.id,
          data: { reason: 'invalid_pin', attempts: updated.failedPinAttempts },
        });

        await this.auditService.log({
          action: 'auth.locked',
          branchId: device.branchId,
          deviceId: device.id,
          actorStaffId: staff.id,
          data: {
            lockedUntil: lockedUntil.toISOString(),
            reason: 'pin_attempts',
          },
        });

        throw new HttpException(
          {
            code: 'AUTH_LOCKED',
            message: 'Account is locked due to too many failed PIN attempts',
            details: { lockedUntil: lockedUntil.toISOString() },
          },
          HttpStatus.LOCKED,
        );
      }

      await this.auditService.log({
        action: 'auth.login_failure',
        branchId: device.branchId,
        deviceId: device.id,
        actorStaffId: staff.id,
        data: { reason: 'invalid_pin', attempts: updated.failedPinAttempts },
      });

      throw new UnauthorizedException({
        code: 'AUTH_INVALID_PIN',
        message: 'Invalid PIN',
      });
    }

    // PIN is valid: reset attempts
    if (staff.failedPinAttempts > 0 || staff.lockedUntil !== null) {
      await this.prisma.staff.update({
        where: { id: staff.id },
        data: { failedPinAttempts: 0, lockedUntil: null },
      });
    }

    const sessionId = uuidv7();
    const rawRefreshToken = generateToken();
    const refreshTokenHash = hashTokenWithPepper(
      rawRefreshToken,
      this.deviceTokenPepper,
    );
    const refreshTokenExpiresAt = getNextFourAm(now, branch.timezone);

    const session = await this.prisma.authSession.create({
      data: {
        id: sessionId,
        staffId: staff.id,
        deviceId: device.id,
        refreshTokenHash,
        expiresAt: refreshTokenExpiresAt,
        createdAt: now,
      },
    });

    await this.auditService.log({
      action: 'auth.login_success',
      branchId: device.branchId,
      deviceId: device.id,
      actorStaffId: staff.id,
      data: { method: 'pin', sessionId: session.id },
    });

    const payload: JwtPayload = {
      sub: staff.id,
      sid: session.id,
      did: device.id,
      branchIds: staff.staffBranches.map((sb) => sb.branchId),
    };

    const accessToken = await this.jwtService.signAsync(payload, {
      secret: this.jwtSecret,
      expiresIn: '15m',
    });
    const accessTokenExpiresAt = new Date(now.getTime() + 15 * 60 * 1000);

    const permissions = await this.getStaffPermissions(staff.role);

    return {
      accessToken,
      accessTokenExpiresAt: accessTokenExpiresAt.toISOString(),
      refreshToken: rawRefreshToken,
      refreshTokenExpiresAt: refreshTokenExpiresAt.toISOString(),
      me: {
        staff: this.formatStaff(staff),
        permissions,
        deviceId: device.id,
      },
    };
  }

  async refreshToken(rawRefreshToken: string): Promise<TokenPairResponse> {
    const hash = hashTokenWithPepper(rawRefreshToken, this.deviceTokenPepper);

    const session = await this.prisma.authSession.findUnique({
      where: { refreshTokenHash: hash },
      include: {
        staff: {
          include: {
            staffBranches: true,
          },
        },
      },
    });

    if (!session) {
      // Check for token reuse in rotated tokens
      const reusedSession = await this.prisma.authSession.findFirst({
        where: { rotatedTokenHashes: { has: hash } },
      });

      if (reusedSession) {
        // Reuse detected! Revoke the whole session immediately
        await this.prisma.authSession.update({
          where: { id: reusedSession.id },
          data: { revokedAt: new Date() },
        });

        // auth.logout is the contract's AuditAction for a revoked session.
        await this.auditService.log({
          action: 'auth.logout',
          actorStaffId: reusedSession.staffId,
          deviceId: reusedSession.deviceId,
          data: { reason: 'refresh_token_reuse', sessionId: reusedSession.id },
        });

        throw new UnauthorizedException({
          code: 'AUTH_REFRESH_INVALID',
          message: 'Refresh token was already used; session has been revoked',
        });
      }

      throw new UnauthorizedException({
        code: 'AUTH_REFRESH_INVALID',
        message: 'Invalid refresh token',
      });
    }

    if (session.revokedAt !== null) {
      throw new UnauthorizedException({
        code: 'AUTH_REFRESH_INVALID',
        message: 'Session is revoked',
      });
    }

    if (session.expiresAt <= new Date()) {
      throw new UnauthorizedException({
        code: 'AUTH_REFRESH_INVALID',
        message: 'Session is expired',
      });
    }

    if (!session.staff || !session.staff.isActive) {
      throw new UnauthorizedException({
        code: 'AUTH_REFRESH_INVALID',
        message: 'Staff member is inactive',
      });
    }

    // Rotate refresh token
    const newRefreshToken = generateToken();
    const newHash = hashTokenWithPepper(
      newRefreshToken,
      this.deviceTokenPepper,
    );

    // Conditional on the old hash, so two concurrent refreshes with the same
    // token cannot both succeed; the loser is treated as an invalid token.
    const rotated = await this.prisma.authSession.updateMany({
      where: { id: session.id, refreshTokenHash: hash, revokedAt: null },
      data: {
        refreshTokenHash: newHash,
        rotatedTokenHashes: { push: hash },
      },
    });
    if (rotated.count !== 1) {
      throw new UnauthorizedException({
        code: 'AUTH_REFRESH_INVALID',
        message: 'Refresh token was already used',
      });
    }

    const payload: JwtPayload = {
      sub: session.staff.id,
      sid: session.id,
      ...(session.deviceId ? { did: session.deviceId } : {}),
      branchIds: session.staff.staffBranches.map((sb) => sb.branchId),
    };

    const accessToken = await this.jwtService.signAsync(payload, {
      secret: this.jwtSecret,
      expiresIn: '15m',
    });
    const now = this.clock.now();
    const accessTokenExpiresAt = new Date(now.getTime() + 15 * 60 * 1000);

    return {
      accessToken,
      accessTokenExpiresAt: accessTokenExpiresAt.toISOString(),
      refreshToken: newRefreshToken,
      refreshTokenExpiresAt: session.expiresAt.toISOString(),
    };
  }

  async logout(user: AuthenticatedUser): Promise<void> {
    const now = this.clock.now();
    await this.prisma.authSession.update({
      where: { id: user.sessionId },
      data: { revokedAt: now },
    });

    await this.auditService.log({
      action: 'auth.logout',
      actorStaffId: user.staffId,
      deviceId: user.deviceId,
      data: { sessionId: user.sessionId },
    });
  }

  async getMe(user: AuthenticatedUser): Promise<MeResponse> {
    const staff = await this.prisma.staff.findUnique({
      where: { id: user.staffId },
      include: { staffBranches: true },
    });

    if (!staff || !staff.isActive) {
      throw new UnauthorizedException({
        code: 'AUTH_REQUIRED',
        message: 'Staff member not found or inactive',
      });
    }

    const permissions = await this.getStaffPermissions(staff.role);

    return {
      staff: this.formatStaff(staff),
      permissions,
      deviceId: user.deviceId,
    };
  }

  private async getStaffPermissions(role: Role): Promise<PermissionKey[]> {
    if (role === Role.OWNER) {
      return [...PERMISSION_KEYS];
    }
    const rolePermissions = await this.prisma.rolePermission.findMany({
      where: { role },
      select: { permissionKey: true },
    });
    return rolePermissions.map((rp) => rp.permissionKey as PermissionKey);
  }

  private formatStaff(
    staff: Staff & { staffBranches: StaffBranch[] },
  ): FormattedStaff {
    return {
      id: staff.id,
      fullName: staff.fullName,
      displayName: staff.displayName,
      role: staff.role,
      email: staff.email,
      branchIds: staff.staffBranches.map((sb) => sb.branchId),
      isActive: staff.isActive,
      hasPassword: Boolean(staff.passwordHash),
      lockedUntil: latestLock(staff.lockedUntil, staff.passwordLockedUntil),
      createdAt: staff.createdAt.toISOString(),
      updatedAt: staff.updatedAt.toISOString(),
    };
  }
}

/** Shows the later of the PIN and password locks, if either is active. */
function latestLock(
  pinLock: Date | null,
  passwordLock: Date | null,
): string | null {
  const now = Date.now();
  const active = [pinLock, passwordLock].filter(
    (d): d is Date => d instanceof Date && d.getTime() > now,
  );
  if (active.length === 0) return null;
  return new Date(Math.max(...active.map((d) => d.getTime()))).toISOString();
}
