import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { Role } from '@prisma/client';
import { IS_PUBLIC_KEY } from '../../common/decorators/public.decorator';
import { PERMISSION_KEYS } from '../../common/permissions';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthenticatedUser, JwtPayload } from '../interfaces/auth.interface';

@Injectable()
export class AuthGuard implements CanActivate {
  private readonly jwtSecret: string;

  constructor(
    private readonly reflector: Reflector,
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
    configService: ConfigService,
  ) {
    this.jwtSecret = configService.get<string>('JWT_SECRET')!;
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    const request = context.switchToHttp().getRequest<{
      headers: Record<string, string | undefined>;
      user?: AuthenticatedUser;
    }>();

    const authHeader = request.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      if (isPublic) {
        return true;
      }
      throw new UnauthorizedException({
        code: 'AUTH_REQUIRED',
        message: 'Missing or malformed Authorization header',
      });
    }

    const token = authHeader.slice(7).trim();
    let payload: JwtPayload;
    try {
      payload = await this.jwtService.verifyAsync<JwtPayload>(token, {
        secret: this.jwtSecret,
      });
    } catch (err: unknown) {
      if (isPublic) {
        return true;
      }
      const errorName =
        typeof err === 'object' && err !== null && 'name' in err
          ? String(err.name)
          : '';
      if (errorName === 'TokenExpiredError') {
        throw new UnauthorizedException({
          code: 'AUTH_TOKEN_EXPIRED',
          message: 'Access token has expired',
        });
      }
      throw new UnauthorizedException({
        code: 'AUTH_REQUIRED',
        message: 'Invalid access token',
      });
    }

    const session = await this.prisma.authSession.findUnique({
      where: { id: payload.sid },
      include: {
        staff: {
          include: {
            staffBranches: true,
          },
        },
      },
    });

    if (
      !session ||
      session.revokedAt !== null ||
      session.expiresAt <= new Date()
    ) {
      if (isPublic) {
        return true;
      }
      throw new UnauthorizedException({
        code: 'AUTH_REQUIRED',
        message: 'Session is invalid, expired or revoked',
      });
    }

    if (!session.staff || !session.staff.isActive) {
      if (isPublic) {
        return true;
      }
      throw new UnauthorizedException({
        code: 'AUTH_REQUIRED',
        message: 'Staff member is inactive',
      });
    }

    let permissions: string[];
    if (session.staff.role === Role.OWNER) {
      permissions = [...PERMISSION_KEYS];
    } else {
      const rolePerms = await this.prisma.rolePermission.findMany({
        where: { role: session.staff.role },
        select: { permissionKey: true },
      });
      permissions = rolePerms.map((rp) => rp.permissionKey);
    }

    request.user = {
      staffId: session.staff.id,
      sessionId: session.id,
      deviceId: payload.did ?? session.deviceId ?? null,
      role: session.staff.role,
      branchIds: session.staff.staffBranches.map((sb) => sb.branchId),
      permissions,
    };

    return true;
  }
}
