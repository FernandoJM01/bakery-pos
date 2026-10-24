import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, Role, Staff } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { AuditService } from '../audit/audit.service';
import { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { ClockService } from '../common/clock.service';
import { hashPassword, hashPin } from '../common/crypto';
import { withUniqueConflict } from '../common/prisma-errors';
import { PrismaService } from '../prisma/prisma.service';
import {
  CreateStaffDto,
  ListStaffQueryDto,
  SetPinDto,
  UpdateStaffDto,
} from './dto/staff.dto';

export function formatStaff(
  staff: Staff & { staffBranches?: { branchId: string }[] },
) {
  return {
    id: staff.id,
    fullName: staff.fullName,
    displayName: staff.displayName,
    role: staff.role,
    email: staff.email,
    branchIds: staff.staffBranches
      ? staff.staffBranches.map((sb) => sb.branchId)
      : [],
    isActive: staff.isActive,
    hasPassword: staff.passwordHash !== null,
    lockedUntil: staff.lockedUntil ? staff.lockedUntil.toISOString() : null,
    createdAt: staff.createdAt.toISOString(),
    updatedAt: staff.updatedAt.toISOString(),
  };
}

@Injectable()
export class StaffService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly clock: ClockService,
  ) {}

  async list(query: ListStaffQueryDto) {
    const where: Prisma.StaffWhereInput = {};

    if (!query.includeInactive) {
      where.isActive = true;
    }
    if (query.role) {
      where.role = query.role;
    }
    if (query.branchId) {
      where.staffBranches = { some: { branchId: query.branchId } };
    }

    const staffList = await this.prisma.staff.findMany({
      where,
      include: { staffBranches: true },
      orderBy: { fullName: 'asc' },
    });

    return staffList.map(formatStaff);
  }

  async get(staffId: string) {
    const staff = await this.prisma.staff.findUnique({
      where: { id: staffId },
      include: { staffBranches: true },
    });
    if (!staff) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'Staff member not found',
      });
    }
    return formatStaff(staff);
  }

  async create(currentUser: AuthenticatedUser, dto: CreateStaffDto) {
    if (currentUser.role !== Role.OWNER && dto.role === Role.OWNER) {
      throw new ForbiddenException({
        code: 'PERMISSION_DENIED',
        message: 'Managers cannot create an owner',
      });
    }

    if (dto.role === Role.OWNER) {
      if (!dto.email) {
        throw new BadRequestException({
          code: 'VALIDATION_FAILED',
          message: 'Email is required for owner',
        });
      }
      if (!dto.password || dto.password.length < 10) {
        throw new BadRequestException({
          code: 'VALIDATION_FAILED',
          message: 'Password of at least 10 characters is required for owner',
        });
      }
    }

    if (dto.email) {
      const existing = await this.prisma.staff.findUnique({
        where: { email: dto.email.toLowerCase() },
      });
      if (existing) {
        throw new ConflictException({
          code: 'CONFLICT',
          message: 'Email already in use',
        });
      }
    }

    const branchCount = await this.prisma.branch.count({
      where: { id: { in: dto.branchIds } },
    });
    if (branchCount !== dto.branchIds.length) {
      throw new BadRequestException({
        code: 'VALIDATION_FAILED',
        message: 'One or more branch IDs are invalid',
      });
    }

    const { pinHash, offlinePinVerifier } = await hashPin(dto.pin);
    const passwordHash = dto.password ? await hashPassword(dto.password) : null;
    const now = this.clock.now();
    const staffId = uuidv7();

    const staff = await withUniqueConflict('Email already in use', () =>
      this.prisma.staff.create({
        data: {
          id: staffId,
          fullName: dto.fullName,
          displayName: dto.displayName,
          role: dto.role,
          email: dto.email ? dto.email.toLowerCase() : null,
          passwordHash,
          pinHash,
          offlinePinVerifier,
          pinUpdatedAt: now,
          isActive: true,
          staffBranches: {
            create: dto.branchIds.map((branchId) => ({ branchId })),
          },
        },
        include: { staffBranches: true },
      }),
    );

    await this.audit.log({
      action: 'staff.created',
      actorStaffId: currentUser.staffId,
      entityType: 'staff',
      entityId: staff.id,
      branchId: dto.branchIds[0] ?? null,
      data: {
        fullName: staff.fullName,
        displayName: staff.displayName,
        role: staff.role,
        email: staff.email,
        branchIds: dto.branchIds,
      },
    });

    return formatStaff(staff);
  }

  async update(
    currentUser: AuthenticatedUser,
    staffId: string,
    dto: UpdateStaffDto,
  ) {
    const existing = await this.prisma.staff.findUnique({
      where: { id: staffId },
      include: { staffBranches: true },
    });
    if (!existing) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'Staff member not found',
      });
    }

    const hasUpdate =
      dto.fullName !== undefined ||
      dto.displayName !== undefined ||
      dto.role !== undefined ||
      dto.email !== undefined ||
      dto.password !== undefined ||
      dto.branchIds !== undefined ||
      dto.isActive !== undefined;

    if (!hasUpdate) {
      throw new BadRequestException({
        code: 'VALIDATION_FAILED',
        message: 'At least one field must be provided',
      });
    }

    // Guard rail: nobody can deactivate or demote the last active owner
    if (existing.role === Role.OWNER && existing.isActive) {
      const isDemoting = dto.role !== undefined && dto.role !== Role.OWNER;
      const isDeactivating = dto.isActive === false;
      if (isDemoting || isDeactivating) {
        const activeOwners = await this.prisma.staff.count({
          where: { role: Role.OWNER, isActive: true },
        });
        if (activeOwners <= 1) {
          throw new ConflictException({
            code: 'CONFLICT',
            message: 'Cannot deactivate or demote the last active owner',
          });
        }
      }
    }

    // Guard rail: a manager can never create or promote an OWNER
    if (currentUser.role !== Role.OWNER && dto.role === Role.OWNER) {
      throw new ForbiddenException({
        code: 'PERMISSION_DENIED',
        message: 'Managers cannot promote to owner',
      });
    }

    // An owner (staying one or being promoted) must keep an email and a
    // password, or they could no longer log in to the back office.
    if ((dto.role ?? existing.role) === Role.OWNER) {
      const effectiveEmail =
        dto.email !== undefined ? dto.email : existing.email;
      const effectivePassword = dto.password
        ? true
        : existing.passwordHash !== null;
      if (!effectiveEmail || !effectivePassword) {
        throw new BadRequestException({
          code: 'VALIDATION_FAILED',
          message:
            'Owner must have an email and a password of at least 10 characters',
        });
      }
    }

    // Duplicate email check
    if (dto.email !== undefined && dto.email !== null) {
      if (dto.email.toLowerCase() !== existing.email?.toLowerCase()) {
        const duplicate = await this.prisma.staff.findUnique({
          where: { email: dto.email.toLowerCase() },
        });
        if (duplicate) {
          throw new ConflictException({
            code: 'CONFLICT',
            message: 'Email already in use',
          });
        }
      }
    }

    if (dto.branchIds) {
      const branchCount = await this.prisma.branch.count({
        where: { id: { in: dto.branchIds } },
      });
      if (branchCount !== dto.branchIds.length) {
        throw new BadRequestException({
          code: 'VALIDATION_FAILED',
          message: 'One or more branch IDs are invalid',
        });
      }
    }

    let passwordHash: string | undefined;
    if (dto.password) {
      passwordHash = await hashPassword(dto.password);
    }

    const now = this.clock.now();
    const updated = await withUniqueConflict('Email already in use', () =>
      this.prisma.$transaction(async (tx) => {
        if (dto.branchIds) {
          await tx.staffBranch.deleteMany({ where: { staffId } });
          await tx.staffBranch.createMany({
            data: dto.branchIds.map((branchId) => ({ staffId, branchId })),
          });
        }

        if (dto.isActive === false) {
          await tx.authSession.updateMany({
            where: { staffId, revokedAt: null },
            data: { revokedAt: now },
          });
        }

        const s = await tx.staff.update({
          where: { id: staffId },
          data: {
            fullName: dto.fullName,
            displayName: dto.displayName,
            role: dto.role,
            email:
              dto.email !== undefined
                ? dto.email
                  ? dto.email.toLowerCase()
                  : null
                : undefined,
            passwordHash,
            isActive: dto.isActive,
          },
          include: { staffBranches: true },
        });

        const isDeactivation =
          dto.isActive === false && existing.isActive === true;
        const changes: Record<string, unknown> = {};
        if (dto.fullName !== undefined) changes.fullName = dto.fullName;
        if (dto.displayName !== undefined)
          changes.displayName = dto.displayName;
        if (dto.role !== undefined) changes.role = dto.role;
        if (dto.email !== undefined) changes.email = dto.email;
        if (dto.password !== undefined) changes.hasPassword = true;
        if (dto.branchIds !== undefined) changes.branchIds = dto.branchIds;
        if (dto.isActive !== undefined) changes.isActive = dto.isActive;

        await tx.auditLog.create({
          data: {
            id: uuidv7(),
            occurredAt: now,
            action: isDeactivation ? 'staff.deactivated' : 'staff.updated',
            actorStaffId: currentUser.staffId,
            entityType: 'staff',
            entityId: staffId,
            data: changes as Prisma.InputJsonValue,
          },
        });

        return s;
      }),
    );

    return formatStaff(updated);
  }

  async setPin(
    currentUser: AuthenticatedUser,
    staffId: string,
    dto: SetPinDto,
  ) {
    const staff = await this.prisma.staff.findUnique({
      where: { id: staffId },
    });
    if (!staff) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'Staff member not found',
      });
    }

    const { pinHash, offlinePinVerifier } = await hashPin(dto.pin);
    const now = this.clock.now();

    await this.prisma.$transaction(async (tx) => {
      await tx.staff.update({
        where: { id: staffId },
        data: {
          pinHash,
          offlinePinVerifier,
          pinUpdatedAt: now,
          failedPinAttempts: 0,
          lockedUntil: null,
        },
      });

      await tx.authSession.updateMany({
        where: { staffId, revokedAt: null },
        data: { revokedAt: now },
      });

      await tx.auditLog.create({
        data: {
          id: uuidv7(),
          occurredAt: now,
          action: 'staff.pin_changed',
          actorStaffId: currentUser.staffId,
          entityType: 'staff',
          entityId: staffId,
          data: {},
        },
      });
    });
  }
}
