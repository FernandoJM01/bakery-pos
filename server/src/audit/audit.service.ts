import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { PrismaService } from '../prisma/prisma.service';

export interface AuditEntry {
  action: string;
  actorStaffId?: string | null;
  approverStaffId?: string | null;
  branchId?: string | null;
  deviceId?: string | null;
  entityType?: string | null;
  entityId?: string | null;
  data?: Record<string, unknown>;
}

@Injectable()
export class AuditService {
  constructor(private readonly prisma: PrismaService) {}

  async log(entry: AuditEntry): Promise<void> {
    await this.prisma.auditLog.create({
      data: {
        id: uuidv7(),
        action: entry.action,
        actorStaffId: entry.actorStaffId ?? null,
        approverStaffId: entry.approverStaffId ?? null,
        branchId: entry.branchId ?? null,
        deviceId: entry.deviceId ?? null,
        entityType: entry.entityType ?? null,
        entityId: entry.entityId ?? null,
        data: (entry.data ?? {}) as Prisma.InputJsonValue,
      },
    });
  }
}
