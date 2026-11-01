import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, SyncQuarantine } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { ClockService } from '../common/clock.service';
import { PrismaService } from '../prisma/prisma.service';
import { QuarantineQueryDto } from './dto/sync.dto';

export function formatQuarantine(q: SyncQuarantine) {
  return {
    recordId: q.recordId,
    deviceId: q.deviceId,
    branchId: q.branchId,
    type: q.type,
    occurredAt: q.occurredAt.toISOString(),
    receivedAt: q.receivedAt.toISOString(),
    errorCode: q.errorCode,
    errorMessage: q.errorMessage,
    payload: q.payload,
    resolvedAt: q.resolvedAt?.toISOString() ?? null,
    resolvedByStaffId: q.resolvedBy,
    resolutionNote: q.resolutionNote,
  };
}

/** Keyset cursor over (receivedAt desc, recordId desc). */
function encodeCursor(q: SyncQuarantine) {
  return Buffer.from(
    `${q.receivedAt.toISOString()}|${q.recordId}`,
    'utf8',
  ).toString('base64url');
}

function decodeCursor(cursor: string) {
  const [at, id] = Buffer.from(cursor, 'base64url').toString('utf8').split('|');
  const receivedAt = new Date(at ?? '');
  if (
    Number.isNaN(receivedAt.getTime()) ||
    !/^[0-9a-f-]{36}$/i.test(id ?? '')
  ) {
    throw new BadRequestException({
      code: 'VALIDATION_FAILED',
      message: 'Invalid cursor',
    });
  }
  return { receivedAt, recordId: id };
}

@Injectable()
export class QuarantineService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
  ) {}

  async list(query: QuarantineQueryDto) {
    const limit = query.limit ?? 50;
    const status = query.status ?? 'OPEN';
    const and: Prisma.SyncQuarantineWhereInput[] = [];
    if (status === 'OPEN') and.push({ resolvedAt: null });
    if (status === 'RESOLVED') and.push({ resolvedAt: { not: null } });
    if (query.deviceId) and.push({ deviceId: query.deviceId });
    if (query.cursor) {
      const c = decodeCursor(query.cursor);
      and.push({
        OR: [
          { receivedAt: { lt: c.receivedAt } },
          { receivedAt: c.receivedAt, recordId: { lt: c.recordId } },
        ],
      });
    }
    const rows = await this.prisma.syncQuarantine.findMany({
      where: { AND: and },
      orderBy: [{ receivedAt: 'desc' }, { recordId: 'desc' }],
      take: limit + 1,
    });
    const items = rows.slice(0, limit);
    return {
      items: items.map(formatQuarantine),
      nextCursor:
        rows.length > limit ? encodeCursor(items[items.length - 1]) : null,
    };
  }

  async resolve(recordId: string, note: string, staffId: string) {
    return this.prisma.$transaction(async (tx) => {
      const now = this.clock.now();
      // The resolvedAt condition makes two resolves race-safe: one wins.
      const { count } = await tx.syncQuarantine.updateMany({
        where: { recordId, resolvedAt: null },
        data: { resolvedAt: now, resolvedBy: staffId, resolutionNote: note },
      });
      const row = await tx.syncQuarantine.findUnique({ where: { recordId } });
      if (!row) {
        throw new NotFoundException({
          code: 'NOT_FOUND',
          message: 'Quarantined record not found',
        });
      }
      if (count === 0) {
        throw new ConflictException({
          code: 'CONFLICT',
          message: 'Record is already resolved',
        });
      }
      await tx.auditLog.create({
        data: {
          id: uuidv7(),
          occurredAt: now,
          action: 'sync.quarantine_resolved',
          actorStaffId: staffId,
          branchId: row.branchId,
          deviceId: row.deviceId,
          entityType: 'sync_record',
          entityId: recordId,
          data: { errorCode: row.errorCode, note },
        },
      });
      return formatQuarantine(row);
    });
  }
}
