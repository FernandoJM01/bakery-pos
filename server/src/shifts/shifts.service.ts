import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { CashCount, CashCountStage, Prisma, ShiftStatus } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { PrismaService } from '../prisma/prisma.service';
import { ShiftsQueryDto } from './dto/shifts-query.dto';
import { computeZReport } from './z-report';

const SUMMARY_INCLUDE = {
  device: { select: { folioPrefix: true } },
  openedBy: { select: { displayName: true } },
  closedBy: { select: { displayName: true } },
} satisfies Prisma.CashShiftInclude;

type SummaryRow = Prisma.CashShiftGetPayload<{
  include: typeof SUMMARY_INCLUDE;
}>;

const notFound = () =>
  new NotFoundException({ code: 'NOT_FOUND', message: 'Shift not found' });

/** `SUC1-02-Z0012` */
export function zLabel(prefix: string | null, zNumber: number | null) {
  if (zNumber == null) return null;
  return `${prefix ?? ''}-Z${String(zNumber).padStart(4, '0')}`;
}

function summary(s: SummaryRow) {
  return {
    id: s.id,
    branchId: s.branchId,
    deviceId: s.deviceId,
    status: s.status,
    zNumber: s.zNumber,
    zLabel: zLabel(s.device.folioPrefix, s.zNumber),
    openedAt: s.openedAt.toISOString(),
    openedByStaffId: s.openedByStaffId,
    openedByName: s.openedBy.displayName,
    closedAt: s.closedAt?.toISOString() ?? null,
    closedByStaffId: s.closedByStaffId,
    closedByName: s.closedBy?.displayName ?? null,
    floatCents: s.floatCents,
    expectedCents: s.expectedCents,
    countedCents: s.countedCents,
    varianceCents: s.varianceCents,
    flagged: s.flagged,
  };
}

function encodeCursor(s: SummaryRow) {
  return Buffer.from(`${s.openedAt.toISOString()}|${s.id}`, 'utf8').toString(
    'base64url',
  );
}

function decodeCursor(cursor: string) {
  const [at, id] = Buffer.from(cursor, 'base64url').toString('utf8').split('|');
  const openedAt = new Date(at ?? '');
  if (Number.isNaN(openedAt.getTime()) || !/^[0-9a-f-]{36}$/i.test(id ?? '')) {
    throw new BadRequestException({
      code: 'VALIDATION_FAILED',
      message: 'Invalid cursor',
    });
  }
  return { openedAt, id };
}

const countRows = (rows: CashCount[], stage: CashCountStage) =>
  rows
    .filter((r) => r.stage === stage)
    .sort((a, b) => b.denominationCents - a.denominationCents)
    .map((r) => ({
      denominationCents: r.denominationCents,
      quantity: r.quantity,
    }));

/** Shifts for the back office (M4 brief 5). */
@Injectable()
export class ShiftsService {
  constructor(private readonly prisma: PrismaService) {}

  private scope(user: AuthenticatedUser): string[] | null {
    return user.permissions.includes('reports.all') ? null : user.branchIds;
  }

  async list(user: AuthenticatedUser, q: ShiftsQueryDto) {
    const scope = this.scope(user);
    if (q.branchId && scope && !scope.includes(q.branchId)) {
      throw new ForbiddenException({
        code: 'PERMISSION_DENIED',
        message: 'You cannot see shifts of this branch',
      });
    }
    const limit = q.limit ?? 50;
    const and: Prisma.CashShiftWhereInput[] = [];
    if (scope) and.push({ branchId: { in: scope } });
    if (q.branchId) and.push({ branchId: q.branchId });
    if (q.deviceId) and.push({ deviceId: q.deviceId });
    if (q.flagged !== undefined) and.push({ flagged: q.flagged });
    if (q.from) and.push({ openedAt: { gte: new Date(q.from) } });
    if (q.to) and.push({ openedAt: { lt: new Date(q.to) } });
    if (q.cursor) {
      const c = decodeCursor(q.cursor);
      and.push({
        OR: [
          { openedAt: { lt: c.openedAt } },
          { openedAt: c.openedAt, id: { lt: c.id } },
        ],
      });
    }
    const rows = await this.prisma.cashShift.findMany({
      where: { AND: and },
      orderBy: [{ openedAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      include: SUMMARY_INCLUDE,
    });
    const page = rows.slice(0, limit);
    return {
      items: page.map(summary),
      nextCursor:
        rows.length > limit ? encodeCursor(page[page.length - 1]) : null,
    };
  }

  async get(user: AuthenticatedUser, id: string) {
    const shift = await this.prisma.cashShift.findUnique({
      where: { id },
      include: {
        ...SUMMARY_INCLUDE,
        counts: true,
        movements: { orderBy: { occurredAt: 'asc' } },
        notes: { orderBy: { createdAt: 'asc' } },
      },
    });
    const scope = this.scope(user);
    // Another branch's shift reads as missing, not forbidden.
    if (!shift || (scope && !scope.includes(shift.branchId))) throw notFound();

    const closed = shift.status === ShiftStatus.CLOSED;
    return {
      ...summary(shift),
      openCount: countRows(shift.counts, CashCountStage.OPEN),
      closeCount: closed ? countRows(shift.counts, CashCountStage.CLOSE) : null,
      movements: shift.movements.map((m) => ({
        id: m.id,
        kind: m.kind,
        amountCents: m.amountCents,
        reason: m.reason,
        note: m.note,
        staffId: m.staffId,
        approverStaffId: m.approverStaffId,
        occurredAt: m.occurredAt.toISOString(),
      })),
      notes: shift.notes.map((n) => ({
        staffId: n.staffId,
        note: n.note,
        createdAt: n.createdAt.toISOString(),
      })),
      zReport: closed ? await this.zReport(shift.id, shift.movements) : null,
    };
  }

  private async zReport(
    shiftId: string,
    movements: { kind: 'IN' | 'OUT'; reason: string; amountCents: number }[],
  ) {
    const [sales, refunds] = await Promise.all([
      this.prisma.sale.findMany({
        where: { shiftId },
        include: { lines: true },
      }),
      this.prisma.refund.findMany({
        where: { shiftId },
        include: { lines: true, sale: { include: { lines: true } } },
      }),
    ]);
    return computeZReport(
      sales,
      refunds.map((r) => ({
        kind: r.kind,
        totalCents: r.totalCents,
        lines: r.lines.map((l) => {
          const line = r.sale.lines.find((x) => x.lineNo === l.lineNo)!;
          return {
            ivaBp: line.ivaBp,
            iepsBp: line.iepsBp,
            baseCents: l.baseCents,
            iepsCents: l.iepsCents,
            ivaCents: l.ivaCents,
          };
        }),
      })),
      movements,
    );
  }

  async addNote(user: AuthenticatedUser, id: string, note: string) {
    const shift = await this.prisma.cashShift.findUnique({ where: { id } });
    const scope = this.scope(user);
    if (!shift || (scope && !scope.includes(shift.branchId))) throw notFound();
    await this.prisma.$transaction(async (tx) => {
      await tx.cashShiftNote.create({
        data: { id: uuidv7(), shiftId: id, staffId: user.staffId, note },
      });
      await tx.auditLog.create({
        data: {
          id: uuidv7(),
          action: 'cash.note_added',
          branchId: shift.branchId,
          actorStaffId: user.staffId,
          entityType: 'cash_shift',
          entityId: id,
          data: { note },
        },
      });
    });
    return this.get(user, id);
  }
}
