import {
  ConflictException,
  ForbiddenException,
  HttpException,
  HttpStatus,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Approval, Device, Role } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { AuditService } from '../audit/audit.service';
import { ClockService } from '../common/clock.service';
import {
  generateToken,
  getDummyArgon2Hash,
  hashTokenWithPepper,
  verifyHash,
} from '../common/crypto';
import { PermissionKey } from '../common/permissions';
import { PrismaService } from '../prisma/prisma.service';
import { ApprovalDto } from './dto/approval.dto';
import { AuthenticatedUser } from './interfaces/auth.interface';

export interface ApprovalResponse {
  approvalToken: string;
  expiresAt: string;
  approverStaffId: string;
  action: PermissionKey;
}

@Injectable()
export class ApprovalService {
  private readonly deviceTokenPepper: string;

  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
    private readonly clock: ClockService,
    configService: ConfigService,
  ) {
    this.deviceTokenPepper = configService.get<string>('DEVICE_TOKEN_PEPPER')!;
  }

  async createApproval(
    dto: ApprovalDto,
    requester: AuthenticatedUser,
    device: Device,
  ): Promise<ApprovalResponse> {
    const now = this.clock.now();

    // Requester cannot approve their own action
    if (dto.approverStaffId === requester.staffId) {
      await this.auditService.log({
        action: 'auth.approval_denied',
        branchId: device.branchId,
        deviceId: device.id,
        actorStaffId: requester.staffId,
        approverStaffId: dto.approverStaffId,
        data: {
          action: dto.action,
          reference: dto.reference,
          reason: 'self_approval',
        },
      });
      throw new ForbiddenException({
        code: 'PERMISSION_DENIED',
        message: 'Requester cannot self-approve',
      });
    }

    const approver = await this.prisma.staff.findUnique({
      where: { id: dto.approverStaffId },
      include: { staffBranches: true },
    });

    if (!approver || !approver.isActive) {
      const dummy = await getDummyArgon2Hash();
      await verifyHash(dummy, dto.pin);
      await this.auditService.log({
        action: 'auth.approval_denied',
        branchId: device.branchId,
        deviceId: device.id,
        actorStaffId: requester.staffId,
        approverStaffId: approver ? approver.id : null,
        data: {
          action: dto.action,
          reference: dto.reference,
          reason: 'unknown_or_inactive',
        },
      });
      throw new ForbiddenException({
        code: 'PERMISSION_DENIED',
        message: 'Approver not found or inactive',
      });
    }

    // Check branch assignment (owners allowed anywhere)
    const isOwner = approver.role === Role.OWNER;
    const isAssigned = approver.staffBranches.some(
      (sb) => sb.branchId === device.branchId,
    );
    if (!isOwner && !isAssigned) {
      await this.auditService.log({
        action: 'auth.approval_denied',
        branchId: device.branchId,
        deviceId: device.id,
        actorStaffId: requester.staffId,
        approverStaffId: approver.id,
        data: {
          action: dto.action,
          reference: dto.reference,
          reason: 'branch_not_allowed',
        },
      });
      throw new ForbiddenException({
        code: 'PERMISSION_DENIED',
        message: 'Approver is not assigned to this branch',
      });
    }

    // Check permissions
    if (!isOwner) {
      const rolePerm = await this.prisma.rolePermission.findUnique({
        where: {
          role_permissionKey: {
            role: approver.role,
            permissionKey: dto.action,
          },
        },
      });
      if (!rolePerm) {
        await this.auditService.log({
          action: 'auth.approval_denied',
          branchId: device.branchId,
          deviceId: device.id,
          actorStaffId: requester.staffId,
          approverStaffId: approver.id,
          data: {
            action: dto.action,
            reference: dto.reference,
            reason: 'permission_missing',
          },
        });
        throw new ForbiddenException({
          code: 'PERMISSION_DENIED',
          message: 'Approver lacks permission for this action',
        });
      }
    }

    // Check PIN lockout
    if (approver.lockedUntil && approver.lockedUntil > now) {
      throw new HttpException(
        {
          code: 'AUTH_LOCKED',
          message: 'Account is locked due to too many failed PIN attempts',
          details: { lockedUntil: approver.lockedUntil.toISOString() },
        },
        HttpStatus.LOCKED,
      );
    }

    // Verify PIN
    const isValidPin = await verifyHash(approver.pinHash, dto.pin);
    if (!isValidPin) {
      const attempts =
        approver.lockedUntil && approver.lockedUntil <= now
          ? 1
          : approver.failedPinAttempts + 1;

      if (attempts >= 5) {
        const lockedUntil = new Date(now.getTime() + 5 * 60 * 1000);
        await this.prisma.staff.update({
          where: { id: approver.id },
          data: { failedPinAttempts: 0, lockedUntil },
        });

        await this.auditService.log({
          action: 'auth.approval_denied',
          branchId: device.branchId,
          deviceId: device.id,
          actorStaffId: requester.staffId,
          approverStaffId: approver.id,
          data: {
            action: dto.action,
            reference: dto.reference,
            reason: 'invalid_pin',
            attempts,
          },
        });

        await this.auditService.log({
          action: 'auth.locked',
          branchId: device.branchId,
          deviceId: device.id,
          actorStaffId: approver.id,
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
      } else {
        await this.prisma.staff.update({
          where: { id: approver.id },
          data: { failedPinAttempts: attempts, lockedUntil: null },
        });

        await this.auditService.log({
          action: 'auth.approval_denied',
          branchId: device.branchId,
          deviceId: device.id,
          actorStaffId: requester.staffId,
          approverStaffId: approver.id,
          data: {
            action: dto.action,
            reference: dto.reference,
            reason: 'invalid_pin',
            attempts,
          },
        });

        throw new UnauthorizedException({
          code: 'AUTH_INVALID_PIN',
          message: 'Invalid PIN',
        });
      }
    }

    // PIN is valid: reset attempts
    if (approver.failedPinAttempts > 0 || approver.lockedUntil !== null) {
      await this.prisma.staff.update({
        where: { id: approver.id },
        data: { failedPinAttempts: 0, lockedUntil: null },
      });
    }

    const rawToken = generateToken();
    const tokenHash = hashTokenWithPepper(rawToken, this.deviceTokenPepper);
    const expiresAt = new Date(now.getTime() + 2 * 60 * 1000);

    await this.prisma.approval.create({
      data: {
        id: uuidv7(),
        tokenHash,
        action: dto.action,
        approverStaffId: approver.id,
        requesterStaffId: requester.staffId,
        deviceId: device.id,
        expiresAt,
        createdAt: now,
      },
    });

    await this.auditService.log({
      action: 'auth.approval_granted',
      branchId: device.branchId,
      deviceId: device.id,
      actorStaffId: requester.staffId,
      approverStaffId: approver.id,
      data: {
        action: dto.action,
        ...(dto.reference ? { reference: dto.reference } : {}),
      },
    });

    return {
      approvalToken: rawToken,
      expiresAt: expiresAt.toISOString(),
      approverStaffId: approver.id,
      action: dto.action,
    };
  }

  async consume(
    token: string,
    action: string,
    requesterStaffId: string,
  ): Promise<Approval> {
    const tokenHash = hashTokenWithPepper(token, this.deviceTokenPepper);
    const now = this.clock.now();

    const approval = await this.prisma.approval.findUnique({
      where: { tokenHash },
    });

    if (!approval) {
      throw new UnauthorizedException({
        code: 'APPROVAL_INVALID',
        message: 'Approval token is invalid',
      });
    }

    if (approval.usedAt !== null) {
      throw new ConflictException({
        code: 'APPROVAL_ALREADY_USED',
        message: 'Approval token was already used',
      });
    }

    if (approval.expiresAt < now) {
      throw new HttpException(
        {
          code: 'APPROVAL_EXPIRED',
          message: 'Approval token has expired',
        },
        HttpStatus.GONE,
      );
    }

    if (approval.action !== action) {
      throw new ForbiddenException({
        code: 'APPROVAL_ACTION_MISMATCH',
        message: 'Approval token action mismatch',
      });
    }

    if (approval.requesterStaffId !== requesterStaffId) {
      throw new ForbiddenException({
        code: 'APPROVAL_REQUESTER_MISMATCH',
        message: 'Approval token requester mismatch',
      });
    }

    const updated = await this.prisma.approval.updateMany({
      where: {
        tokenHash,
        usedAt: null,
        expiresAt: { gt: now },
      },
      data: { usedAt: now },
    });

    if (updated.count !== 1) {
      throw new ConflictException({
        code: 'APPROVAL_ALREADY_USED',
        message: 'Approval token was already used',
      });
    }

    return { ...approval, usedAt: now };
  }
}
