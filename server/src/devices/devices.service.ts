import {
  BadRequestException,
  ConflictException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Branch, Device, DeviceStatus, Role } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { AuditService } from '../audit/audit.service';
import { ClockService } from '../common/clock.service';
import {
  generateEnrollmentCode,
  generateToken,
  hashTokenWithPepper,
} from '../common/crypto';
import { ROLE_PERMISSIONS } from '../common/permissions';
import { PrismaService } from '../prisma/prisma.service';
import { ActivateDeviceDto } from './dto/activate-device.dto';
import { CreateDeviceDto } from './dto/create-device.dto';

export function serializeDevice(device: Device) {
  return {
    id: device.id,
    branchId: device.branchId,
    name: device.name,
    type: device.type,
    status: device.status,
    lastSeenAt: device.lastSeenAt ? device.lastSeenAt.toISOString() : null,
    appVersion: device.appVersion ?? null,
    createdAt: device.createdAt.toISOString(),
    revokedAt: device.revokedAt ? device.revokedAt.toISOString() : null,
  };
}

export function serializeBranch(branch: Branch) {
  return {
    id: branch.id,
    code: branch.code,
    name: branch.name,
    address: branch.address ?? null,
    timezone: branch.timezone,
    isActive: branch.isActive,
    createdAt: branch.createdAt.toISOString(),
    updatedAt: branch.updatedAt.toISOString(),
  };
}

@Injectable()
export class DevicesService {
  private readonly pepper: string;

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly clock: ClockService,
    config: ConfigService,
  ) {
    this.pepper = config.getOrThrow<string>('DEVICE_TOKEN_PEPPER');
  }

  async listDevices(branchId?: string) {
    const devices = await this.prisma.device.findMany({
      where: branchId ? { branchId } : {},
      orderBy: { createdAt: 'desc' },
    });
    return devices.map(serializeDevice);
  }

  async createDevice(dto: CreateDeviceDto, actorStaffId: string) {
    const branch = await this.prisma.branch.findUnique({
      where: { id: dto.branchId },
    });
    if (!branch) {
      throw new BadRequestException({
        code: 'VALIDATION_FAILED',
        message: 'Branch not found',
      });
    }

    const enrollmentCode = generateEnrollmentCode();
    const enrollmentCodeHash = hashTokenWithPepper(enrollmentCode, this.pepper);
    const expiresAt = new Date(this.clock.now().getTime() + 30 * 60 * 1000);

    const device = await this.prisma.device.create({
      data: {
        id: uuidv7(),
        branchId: dto.branchId,
        name: dto.name,
        type: dto.type,
        status: DeviceStatus.PENDING,
        enrollmentCodeHash,
        enrollmentExpiresAt: expiresAt,
        createdBy: actorStaffId,
        createdAt: this.clock.now(),
      },
    });

    await this.audit.log({
      action: 'device.created',
      actorStaffId,
      branchId: dto.branchId,
      deviceId: device.id,
      entityType: 'device',
      entityId: device.id,
      data: { name: device.name, type: device.type },
    });

    return {
      device: serializeDevice(device),
      enrollmentCode,
      expiresAt: expiresAt.toISOString(),
    };
  }

  async regenerateEnrollmentCode(deviceId: string) {
    const device = await this.prisma.device.findUnique({
      where: { id: deviceId },
    });
    if (!device) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'Device not found',
      });
    }

    if (device.status !== DeviceStatus.PENDING) {
      throw new ConflictException({
        code: 'CONFLICT',
        message: 'Device is not in PENDING status',
      });
    }

    const enrollmentCode = generateEnrollmentCode();
    const enrollmentCodeHash = hashTokenWithPepper(enrollmentCode, this.pepper);
    const expiresAt = new Date(this.clock.now().getTime() + 30 * 60 * 1000);

    const updated = await this.prisma.device.update({
      where: { id: deviceId },
      data: {
        enrollmentCodeHash,
        enrollmentExpiresAt: expiresAt,
      },
    });

    return {
      device: serializeDevice(updated),
      enrollmentCode,
      expiresAt: expiresAt.toISOString(),
    };
  }

  async activateDevice(dto: ActivateDeviceDto) {
    const codeHash = hashTokenWithPepper(dto.enrollmentCode, this.pepper);
    const device = await this.prisma.device.findFirst({
      where: {
        enrollmentCodeHash: codeHash,
        status: DeviceStatus.PENDING,
      },
      include: { branch: true },
    });

    const now = this.clock.now();
    if (
      !device ||
      !device.enrollmentExpiresAt ||
      device.enrollmentExpiresAt < now
    ) {
      throw new HttpException(
        {
          code: 'DEVICE_CODE_INVALID',
          message: 'Enrollment code is invalid, used, or expired',
        },
        HttpStatus.GONE,
      );
    }

    const deviceToken = generateToken();
    const tokenHash = hashTokenWithPepper(deviceToken, this.pepper);

    const updated = await this.prisma.$transaction(async (tx) => {
      // Conditional on the code still being unused, so two concurrent
      // activations with one code cannot both succeed (single use, A7).
      const claimed = await tx.device.updateMany({
        where: {
          id: device.id,
          enrollmentCodeHash: codeHash,
          status: DeviceStatus.PENDING,
        },
        data: {
          status: DeviceStatus.ACTIVE,
          tokenHash,
          enrollmentCodeHash: null,
          enrollmentExpiresAt: null,
          appVersion: dto.appVersion,
          lastSeenAt: now,
        },
      });
      if (claimed.count !== 1) {
        throw new HttpException(
          {
            code: 'DEVICE_CODE_INVALID',
            message: 'Enrollment code is invalid, used, or expired',
          },
          HttpStatus.GONE,
        );
      }
      const d = await tx.device.findUniqueOrThrow({
        where: { id: device.id },
        include: { branch: true },
      });

      await tx.auditLog.create({
        data: {
          id: uuidv7(),
          action: 'device.activated',
          branchId: d.branchId,
          deviceId: d.id,
          occurredAt: now,
          entityType: 'device',
          entityId: d.id,
          data: { appVersion: dto.appVersion },
        },
      });

      return d;
    });

    return {
      device: serializeDevice(updated),
      deviceToken,
      branch: serializeBranch(updated.branch),
    };
  }

  async revokeDevice(deviceId: string, actorStaffId: string) {
    const device = await this.prisma.device.findUnique({
      where: { id: deviceId },
    });
    if (!device) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'Device not found',
      });
    }

    // Revoking twice must not move revokedAt or write a second audit row.
    if (device.status === DeviceStatus.REVOKED) {
      return serializeDevice(device);
    }

    const now = this.clock.now();
    const updated = await this.prisma.$transaction(async (tx) => {
      const d = await tx.device.update({
        where: { id: deviceId },
        data: {
          status: DeviceStatus.REVOKED,
          revokedAt: now,
        },
      });

      await tx.authSession.updateMany({
        where: { deviceId, revokedAt: null },
        data: { revokedAt: now },
      });

      await tx.auditLog.create({
        data: {
          id: uuidv7(),
          action: 'device.revoked',
          actorStaffId,
          branchId: d.branchId,
          deviceId: d.id,
          occurredAt: now,
          entityType: 'device',
          entityId: d.id,
          data: {},
        },
      });

      return d;
    });

    return serializeDevice(updated);
  }

  async getStaffBundle(device: Device) {
    const staff = await this.prisma.staff.findMany({
      where: {
        isActive: true,
        OR: [
          { role: Role.OWNER },
          { staffBranches: { some: { branchId: device.branchId } } },
        ],
      },
      select: {
        id: true,
        displayName: true,
        role: true,
        offlinePinVerifier: true,
        pinUpdatedAt: true,
      },
      orderBy: { displayName: 'asc' },
    });

    return {
      branchId: device.branchId,
      generatedAt: this.clock.now().toISOString(),
      staff: staff.map((s) => ({
        id: s.id,
        displayName: s.displayName,
        role: s.role,
        offlinePinVerifier: s.offlinePinVerifier,
        pinUpdatedAt: s.pinUpdatedAt.toISOString(),
      })),
      roles: {
        OWNER: [...ROLE_PERMISSIONS.OWNER],
        BRANCH_MANAGER: [...ROLE_PERMISSIONS.BRANCH_MANAGER],
        CASHIER: [...ROLE_PERMISSIONS.CASHIER],
        BAKER: [...ROLE_PERMISSIONS.BAKER],
      },
    };
  }
}
