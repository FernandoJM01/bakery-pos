import {
  HttpException,
  HttpStatus,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Role, Staff, StaffBranch } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { AuditService } from '../audit/audit.service';
import {
  generateToken,
  getDummyArgon2Hash,
  hashTokenWithPepper,
  verifyHash,
} from '../common/crypto';
import { PERMISSION_KEYS, PermissionKey } from '../common/permissions';
import { PrismaService } from '../prisma/prisma.service';
import { PasswordLoginDto } from './dto/password-login.dto';
import { AuthenticatedUser, JwtPayload } from './interfaces/auth.interface';

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

    // Check account lockout
    if (staff.lockedUntil && staff.lockedUntil > new Date()) {
      throw new HttpException(
        {
          code: 'AUTH_LOCKED',
          message: 'Account is locked due to too many failed login attempts',
          details: { lockedUntil: staff.lockedUntil.toISOString() },
        },
        HttpStatus.LOCKED,
      );
    }

    const isValidPassword = staff.passwordHash
      ? await verifyHash(staff.passwordHash, dto.password)
      : false;

    if (!isValidPassword) {
      const attempts = staff.failedPinAttempts + 1;
      let lockedUntil: Date | null = null;
      if (attempts >= 10) {
        lockedUntil = new Date(Date.now() + 15 * 60 * 1000);
      }

      await this.prisma.staff.update({
        where: { id: staff.id },
        data: {
          failedPinAttempts: attempts,
          lockedUntil,
        },
      });

      await this.auditService.log({
        action: 'auth.login_failure',
        actorStaffId: staff.id,
        data: { email: staff.email, reason: 'invalid_password' },
      });

      if (lockedUntil) {
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

      throw new UnauthorizedException({
        code: 'AUTH_INVALID_CREDENTIALS',
        message: 'Invalid credentials',
      });
    }

    if (!staff.isActive) {
      throw new UnauthorizedException({
        code: 'AUTH_REQUIRED',
        message: 'Account is inactive',
      });
    }

    // Reset failed attempts
    await this.prisma.staff.update({
      where: { id: staff.id },
      data: {
        failedPinAttempts: 0,
        lockedUntil: null,
      },
    });

    const sessionId = uuidv7();
    const rawRefreshToken = generateToken();
    const refreshTokenHash = hashTokenWithPepper(
      rawRefreshToken,
      this.deviceTokenPepper,
    );
    const refreshTokenExpiresAt = new Date(Date.now() + 12 * 60 * 60 * 1000); // 12 hours

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
    const accessTokenExpiresAt = new Date(Date.now() + 15 * 60 * 1000);

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

        await this.auditService.log({
          action: 'auth.session_revoked',
          actorStaffId: reusedSession.staffId,
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

    await this.prisma.authSession.update({
      where: { id: session.id },
      data: {
        refreshTokenHash: newHash,
        rotatedTokenHashes: { push: hash },
      },
    });

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
    const accessTokenExpiresAt = new Date(Date.now() + 15 * 60 * 1000);

    return {
      accessToken,
      accessTokenExpiresAt: accessTokenExpiresAt.toISOString(),
      refreshToken: newRefreshToken,
      refreshTokenExpiresAt: session.expiresAt.toISOString(),
    };
  }

  async logout(user: AuthenticatedUser): Promise<void> {
    await this.prisma.authSession.update({
      where: { id: user.sessionId },
      data: { revokedAt: new Date() },
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
      lockedUntil: staff.lockedUntil ? staff.lockedUntil.toISOString() : null,
      createdAt: staff.createdAt.toISOString(),
      updatedAt: staff.updatedAt.toISOString(),
    };
  }
}
