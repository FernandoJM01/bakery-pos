import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Branch, Role } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { AuditService } from '../audit/audit.service';
import { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { withUniqueConflict } from '../common/prisma-errors';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBranchDto, UpdateBranchDto } from './dto/branch.dto';

export function formatBranch(branch: Branch) {
  return {
    id: branch.id,
    code: branch.code,
    name: branch.name,
    address: branch.address,
    timezone: branch.timezone,
    isActive: branch.isActive,
    createdAt: branch.createdAt.toISOString(),
    updatedAt: branch.updatedAt.toISOString(),
  };
}

@Injectable()
export class BranchesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
  ) {}

  async list(user: AuthenticatedUser) {
    const where =
      user.role === Role.OWNER ? undefined : { id: { in: user.branchIds } };

    const branches = await this.prisma.branch.findMany({
      where,
      orderBy: { code: 'asc' },
    });

    return branches.map(formatBranch);
  }

  async create(user: AuthenticatedUser, dto: CreateBranchDto) {
    const existing = await this.prisma.branch.findUnique({
      where: { code: dto.code },
    });
    if (existing) {
      throw new ConflictException({
        code: 'CONFLICT',
        message: 'Branch code already in use',
      });
    }

    const branch = await withUniqueConflict('Branch code already in use', () =>
      this.prisma.branch.create({
        data: {
          id: uuidv7(),
          code: dto.code,
          name: dto.name,
          address: dto.address ?? null,
          timezone: dto.timezone ?? 'America/Mexico_City',
          isActive: true,
        },
      }),
    );

    await this.audit.log({
      action: 'branch.created',
      actorStaffId: user.staffId,
      branchId: branch.id,
      entityType: 'branch',
      entityId: branch.id,
      data: {
        code: branch.code,
        name: branch.name,
        timezone: branch.timezone,
      },
    });

    return formatBranch(branch);
  }

  async update(
    user: AuthenticatedUser,
    branchId: string,
    dto: UpdateBranchDto,
  ) {
    const branch = await this.prisma.branch.findUnique({
      where: { id: branchId },
    });
    if (!branch) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'Branch not found',
      });
    }

    const hasUpdate =
      dto.name !== undefined ||
      dto.address !== undefined ||
      dto.timezone !== undefined ||
      dto.isActive !== undefined;

    if (!hasUpdate) {
      throw new BadRequestException({
        code: 'VALIDATION_FAILED',
        message: 'At least one field must be provided',
      });
    }

    const updated = await this.prisma.branch.update({
      where: { id: branchId },
      data: {
        name: dto.name,
        address: dto.address,
        timezone: dto.timezone,
        isActive: dto.isActive,
      },
    });

    const changes: Record<string, unknown> = {};
    if (dto.name !== undefined) changes.name = dto.name;
    if (dto.address !== undefined) changes.address = dto.address;
    if (dto.timezone !== undefined) changes.timezone = dto.timezone;
    if (dto.isActive !== undefined) changes.isActive = dto.isActive;

    await this.audit.log({
      action: 'branch.updated',
      actorStaffId: user.staffId,
      branchId: updated.id,
      entityType: 'branch',
      entityId: updated.id,
      data: changes,
    });

    return formatBranch(updated);
  }
}
