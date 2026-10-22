import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Reflector } from '@nestjs/core';
import { Device, DeviceStatus } from '@prisma/client';
import { Request } from 'express';
import { ClockService } from '../../common/clock.service';
import { hashTokenWithPepper } from '../../common/crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { REQUIRE_DEVICE_KEY } from '../decorators/require-device.decorator';

export interface RequestWithDevice extends Request {
  device?: Device;
}

@Injectable()
export class DeviceGuard implements CanActivate {
  private readonly pepper: string;

  constructor(
    private readonly reflector: Reflector,
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
    config: ConfigService,
  ) {
    this.pepper = config.getOrThrow<string>('DEVICE_TOKEN_PEPPER');
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isDeviceRequired = this.reflector.getAllAndOverride<boolean>(
      REQUIRE_DEVICE_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!isDeviceRequired) {
      return true;
    }

    const request = context.switchToHttp().getRequest<RequestWithDevice>();
    const rawToken = request.headers['x-device-token'];
    const token = Array.isArray(rawToken) ? rawToken[0] : rawToken;

    if (!token) {
      throw new UnauthorizedException({
        code: 'DEVICE_UNKNOWN',
        message: 'Device token required',
      });
    }

    const tokenHash = hashTokenWithPepper(token, this.pepper);
    const device = await this.prisma.device.findUnique({
      where: { tokenHash },
    });

    if (!device) {
      throw new UnauthorizedException({
        code: 'DEVICE_UNKNOWN',
        message: 'Unknown device',
      });
    }

    if (device.status === DeviceStatus.REVOKED) {
      throw new UnauthorizedException({
        code: 'DEVICE_REVOKED',
        message: 'Device has been revoked',
      });
    }

    if (device.status !== DeviceStatus.ACTIVE) {
      throw new UnauthorizedException({
        code: 'DEVICE_UNKNOWN',
        message: 'Device is not active',
      });
    }

    request.device = device;

    const now = this.clock.now();
    if (
      !device.lastSeenAt ||
      now.getTime() - device.lastSeenAt.getTime() >= 60000
    ) {
      await this.prisma.device.update({
        where: { id: device.id },
        data: { lastSeenAt: now },
      });
    }

    return true;
  }
}
