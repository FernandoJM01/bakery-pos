import { BadRequestException, Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { ClockService } from '../common/clock.service';
import { PrismaService } from '../prisma/prisma.service';
import { ListAuditQueryDto } from './dto/list-audit-query.dto';

export interface AuditEntry {
  action: string;
  actorStaffId?: string | null;
  approverStaffId?: string | null;
  branchId?: string | null;
  deviceId?: string | null;
  entityType?: string | null;
  entityId?: string | null;
  occurredAt?: Date;
  data?: Record<string, unknown>;
}

@Injectable()
export class AuditService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
  ) {}

  async log(entry: AuditEntry): Promise<void> {
    await this.prisma.auditLog.create({
      data: {
        id: uuidv7(),
        occurredAt: entry.occurredAt ?? this.clock.now(),
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

  async list(query: ListAuditQueryDto) {
    const andConditions: Prisma.AuditLogWhereInput[] = [];

    if (query.from) {
      andConditions.push({ occurredAt: { gte: new Date(query.from) } });
    }
    if (query.to) {
      andConditions.push({ occurredAt: { lte: new Date(query.to) } });
    }
    if (query.branchId) {
      andConditions.push({ branchId: query.branchId });
    }
    if (query.staffId) {
      andConditions.push({
        OR: [
          { actorStaffId: query.staffId },
          { approverStaffId: query.staffId },
        ],
      });
    }
    if (query.action) {
      andConditions.push({ action: query.action });
    }

    if (query.cursor) {
      let cursorOccurredAt: Date | undefined;
      let cursorId: string | undefined;

      try {
        const decoded = Buffer.from(query.cursor, 'base64').toString('utf8');
        const [occurredAtStr, id] = decoded.split('|');
        if (occurredAtStr && id) {
          const parsedDate = new Date(occurredAtStr);
          if (!isNaN(parsedDate.getTime())) {
            cursorOccurredAt = parsedDate;
            cursorId = id;
          }
        }
      } catch {
        // Handled below
      }

      if (!cursorOccurredAt || !cursorId) {
        throw new BadRequestException({
          code: 'VALIDATION_FAILED',
          message: 'Invalid pagination cursor',
        });
      }

      andConditions.push({
        OR: [
          { occurredAt: { lt: cursorOccurredAt } },
          {
            occurredAt: cursorOccurredAt,
            id: { lt: cursorId },
          },
        ],
      });
    }

    const where: Prisma.AuditLogWhereInput =
      andConditions.length > 0 ? { AND: andConditions } : {};

    const limit = query.limit ?? 50;
    const rows = await this.prisma.auditLog.findMany({
      where,
      orderBy: [{ occurredAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
    });

    let nextCursor: string | null = null;
    if (rows.length > limit) {
      rows.pop();
      const last = rows[rows.length - 1];
      nextCursor = Buffer.from(
        `${last.occurredAt.toISOString()}|${last.id}`,
      ).toString('base64');
    }

    return {
      items: rows.map((r) => ({
        id: r.id,
        occurredAt: r.occurredAt.toISOString(),
        branchId: r.branchId,
        deviceId: r.deviceId,
        actorStaffId: r.actorStaffId,
        approverStaffId: r.approverStaffId,
        action: r.action,
        entityType: r.entityType,
        entityId: r.entityId,
        data: (r.data as Record<string, unknown>) ?? {},
      })),
      nextCursor,
    };
  }
}
