import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  OnApplicationBootstrap,
  OnApplicationShutdown,
} from '@nestjs/common';
import { Device, Prisma, StockEventKind, TransferStatus } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { ClockService } from '../common/clock.service';
import { localDay } from '../common/local-day';
import { PrismaService } from '../prisma/prisma.service';
import {
  CreateTransferDto,
  ReceiveTransferDto,
  StockEventsQueryDto,
  TransfersQueryDto,
  WasteQueryDto,
} from './dto/stock-query.dto';
import { daysBetween } from './fifo';
import { dayOf, StockLedgerService } from './stock-ledger.service';

const HOUR_MS = 3_600_000;
const CHECK_HOUR = 3;

const invalidCursor = () =>
  new BadRequestException({
    code: 'VALIDATION_FAILED',
    message: 'Invalid cursor',
  });

function offset(cursor?: string): number {
  if (!cursor) return 0;
  const n = Number(Buffer.from(cursor, 'base64url').toString('utf8'));
  if (!Number.isInteger(n) || n < 0) throw invalidCursor();
  return n;
}

const nextCursor = (rows: number, limit: number, at: number) =>
  rows > limit
    ? Buffer.from(String(at + limit), 'utf8').toString('base64url')
    : null;

const TRANSFER_INCLUDE = {
  lines: {
    include: {
      variant: {
        select: { name: true, product: { select: { name: true } } },
      },
    },
    orderBy: [{ variantId: 'asc' }, { producedOn: 'asc' }],
  },
} satisfies Prisma.StockTransferInclude;

type TransferRow = Prisma.StockTransferGetPayload<{
  include: typeof TRANSFER_INCLUDE;
}>;

function formatTransfer(t: TransferRow) {
  return {
    id: t.id,
    fromBranchId: t.fromBranchId,
    toBranchId: t.toBranchId,
    status: t.status,
    sentByStaffId: t.sentByStaffId,
    sentAt: t.sentAt.toISOString(),
    receivedByStaffId: t.receivedByStaffId,
    receivedAt: t.receivedAt?.toISOString() ?? null,
    flagged: t.flagged,
    lines: t.lines.map((l) => ({
      variantId: l.variantId,
      productName: l.variant.product.name,
      variantName: l.variant.name,
      producedOn: dayOf(l.producedOn),
      quantitySent: l.quantitySent,
      quantityReceived: l.quantityReceived,
    })),
  };
}

/** Stock reads, transfers and the nightly check (M5 brief 4 and 5). */
@Injectable()
export class StockService
  implements OnApplicationBootstrap, OnApplicationShutdown
{
  private timer: NodeJS.Timeout | null = null;

  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
    private readonly ledger: StockLedgerService,
  ) {}

  onApplicationBootstrap() {
    if (process.env.NODE_ENV === 'test') return;
    // Hourly tick; the check itself runs once a day at 03:00.
    this.timer = setInterval(() => void this.tick(), HOUR_MS);
    this.timer.unref();
  }

  onApplicationShutdown() {
    if (this.timer) clearInterval(this.timer);
  }

  private async tick() {
    if (this.clock.now().getHours() === CHECK_HOUR) await this.runCheck();
  }

  private scope(user: AuthenticatedUser): string[] | null {
    return user.permissions.includes('reports.all') ? null : user.branchIds;
  }

  private assertBranch(user: AuthenticatedUser, branchId: string) {
    const scope = this.scope(user);
    if (scope && !scope.includes(branchId)) {
      throw new ForbiddenException({
        code: 'PERMISSION_DENIED',
        message: 'You cannot see stock of this branch',
      });
    }
  }

  /** The device's branch: open lots and what was sold with no lot. */
  async branchStock(device: Device) {
    const [lots, shortages] = await this.prisma.$transaction(
      [
        this.prisma.stockLot.findMany({
          where: { branchId: device.branchId, quantityLeft: { gt: 0 } },
          orderBy: [{ producedOn: 'asc' }, { id: 'asc' }],
        }),
        this.prisma.stockEvent.groupBy({
          by: ['variantId'],
          where: { branchId: device.branchId, lotId: null },
          _sum: { quantity: true },
          orderBy: { variantId: 'asc' },
        }),
      ],
      { isolationLevel: Prisma.TransactionIsolationLevel.RepeatableRead },
    );
    return {
      generatedAt: this.clock.now().toISOString(),
      lots: lots.map((l) => ({
        id: l.id,
        variantId: l.variantId,
        producedOn: dayOf(l.producedOn),
        quantityLeft: l.quantityLeft,
      })),
      shortages: shortages
        .filter((s) => (s._sum?.quantity ?? 0) < 0)
        .map((s) => ({
          variantId: s.variantId,
          quantity: -(s._sum?.quantity ?? 0),
        })),
    };
  }

  async levels(user: AuthenticatedUser, branchId?: string) {
    if (branchId) this.assertBranch(user, branchId);
    const scope = this.scope(user);
    const where: Prisma.StockEventWhereInput = branchId
      ? { branchId }
      : scope
        ? { branchId: { in: scope } }
        : {};
    const sums = await this.prisma.stockEvent.groupBy({
      by: ['branchId', 'variantId'],
      where,
      _sum: { quantity: true },
    });
    const branches = new Map(
      (await this.prisma.branch.findMany()).map((b) => [b.id, b.timezone]),
    );
    const variants = new Map(
      (
        await this.prisma.productVariant.findMany({
          where: { id: { in: sums.map((s) => s.variantId) } },
          include: { product: true },
        })
      ).map((v) => [v.id, v]),
    );
    const lots = await this.prisma.stockLot.findMany({
      where: {
        quantityLeft: { gt: 0 },
        variantId: { in: [...variants.keys()] },
      },
    });
    const now = this.clock.now();
    return {
      items: sums.map((s) => {
        const v = variants.get(s.variantId)!;
        const today = localDay(now, branches.get(s.branchId)!);
        let fresh = 0;
        let dayOld = 0;
        let wasteDue = 0;
        for (const l of lots) {
          if (l.branchId !== s.branchId || l.variantId !== s.variantId) {
            continue;
          }
          const age = daysBetween(dayOf(l.producedOn), today);
          const { dayOldDiscountAfterDays: old, dayOldWasteAfterDays: end } =
            v.product;
          if (end != null && age >= end) wasteDue += l.quantityLeft;
          if (old != null && age >= old) dayOld += l.quantityLeft;
          else fresh += l.quantityLeft;
        }
        return {
          branchId: s.branchId,
          variantId: s.variantId,
          productName: v.product.name,
          variantName: v.name,
          onHand: s._sum.quantity ?? 0,
          freshUnits: fresh,
          dayOldUnits: dayOld,
          wasteDueUnits: wasteDue,
        };
      }),
    };
  }

  async events(user: AuthenticatedUser, q: StockEventsQueryDto) {
    this.assertBranch(user, q.branchId);
    const limit = q.limit ?? 50;
    const at = offset(q.cursor);
    const rows = await this.prisma.stockEvent.findMany({
      where: { branchId: q.branchId, variantId: q.variantId },
      orderBy: [{ occurredAt: 'desc' }, { id: 'desc' }],
      skip: at,
      take: limit + 1,
    });
    return {
      items: rows.slice(0, limit).map((e) => ({
        id: e.id,
        kind: e.kind,
        quantity: e.quantity,
        lotId: e.lotId,
        referenceType: e.referenceType,
        referenceId: e.referenceId,
        staffId: e.staffId,
        occurredAt: e.occurredAt.toISOString(),
      })),
      nextCursor: nextCursor(rows.length, limit, at),
    };
  }

  async waste(user: AuthenticatedUser, q: WasteQueryDto) {
    if (q.branchId) this.assertBranch(user, q.branchId);
    const scope = this.scope(user);
    const where: Prisma.StockWasteWhereInput = {
      ...(q.branchId
        ? { branchId: q.branchId }
        : scope
          ? { branchId: { in: scope } }
          : {}),
      ...(q.reason ? { reason: q.reason } : {}),
      ...(q.from || q.to
        ? {
            occurredAt: {
              ...(q.from ? { gte: new Date(q.from) } : {}),
              ...(q.to ? { lt: new Date(q.to) } : {}),
            },
          }
        : {}),
    };
    const limit = q.limit ?? 50;
    const at = offset(q.cursor);
    const rows = await this.prisma.stockWaste.findMany({
      where,
      orderBy: [{ occurredAt: 'desc' }, { id: 'desc' }],
      skip: at,
      take: limit + 1,
      include: {
        variant: {
          select: { name: true, product: { select: { name: true } } },
        },
      },
    });
    const costed = await this.prisma.stockWaste.findMany({
      where: { ...where, costCents: { not: null } },
      select: { quantity: true, costCents: true },
    });
    return {
      items: rows.slice(0, limit).map((w) => ({
        id: w.id,
        branchId: w.branchId,
        variantId: w.variantId,
        productName: w.variant.product.name,
        variantName: w.variant.name,
        quantity: w.quantity,
        reason: w.reason,
        staffId: w.staffId,
        occurredAt: w.occurredAt.toISOString(),
        costCents: w.costCents,
      })),
      nextCursor: nextCursor(rows.length, limit, at),
      totalCostCents: costed.reduce(
        (a, w) => a + w.quantity * (w.costCents ?? 0),
        0,
      ),
    };
  }

  async transfers(user: AuthenticatedUser, q: TransfersQueryDto) {
    const scope = this.scope(user);
    const limit = q.limit ?? 50;
    const at = offset(q.cursor);
    const rows = await this.prisma.stockTransfer.findMany({
      where: {
        ...(q.status ? { status: q.status } : {}),
        ...(scope
          ? {
              OR: [
                { fromBranchId: { in: scope } },
                { toBranchId: { in: scope } },
              ],
            }
          : {}),
      },
      orderBy: [{ sentAt: 'desc' }, { id: 'desc' }],
      skip: at,
      take: limit + 1,
      include: TRANSFER_INCLUDE,
    });
    return {
      items: rows.slice(0, limit).map(formatTransfer),
      nextCursor: nextCursor(rows.length, limit, at),
    };
  }

  /** Stock leaves the sender at once, oldest first (M5.4). */
  async send(user: AuthenticatedUser, dto: CreateTransferDto) {
    this.assertBranch(user, dto.fromBranchId);
    if (dto.fromBranchId === dto.toBranchId) {
      throw new BadRequestException({
        code: 'VALIDATION_FAILED',
        message: 'A transfer needs two branches',
      });
    }
    const ids = dto.lines.map((l) => l.variantId);
    if (new Set(ids).size !== ids.length) {
      throw new BadRequestException({
        code: 'VALIDATION_FAILED',
        message: 'A variant repeats',
      });
    }
    const to = await this.prisma.branch.findUnique({
      where: { id: dto.toBranchId },
    });
    if (!to) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'Branch not found',
      });
    }
    const id = uuidv7();
    const now = this.clock.now();
    const transfer = await this.prisma.$transaction(async (tx) => {
      await tx.stockTransfer.create({
        data: {
          id,
          fromBranchId: dto.fromBranchId,
          toBranchId: dto.toBranchId,
          sentByStaffId: user.staffId,
          sentAt: now,
        },
      });
      for (const l of [...dto.lines].sort((a, b) =>
        a.variantId.localeCompare(b.variantId),
      )) {
        await this.ledger.lock(tx, dto.fromBranchId, l.variantId);
        const lots = await tx.stockLot.findMany({
          where: { branchId: dto.fromBranchId, variantId: l.variantId },
        });
        const left = lots.reduce((a, x) => a + x.quantityLeft, 0);
        if (left < l.quantity) {
          throw new ConflictException({
            code: 'CONFLICT',
            message: 'Not enough stock to send',
          });
        }
        const { takes } = await this.ledger.take(tx, {
          branchId: dto.fromBranchId,
          variantId: l.variantId,
          quantity: l.quantity,
          kind: StockEventKind.TRANSFER_OUT,
          referenceType: 'transfer',
          referenceId: id,
          staffId: user.staffId,
          occurredAt: now,
        });
        // Lots keep their date across branches: old bread stays old.
        const byDay = new Map<string, number>();
        for (const t of takes) {
          const day = dayOf(lots.find((x) => x.id === t.lotId)!.producedOn);
          byDay.set(day, (byDay.get(day) ?? 0) + t.quantity);
        }
        for (const [day, quantity] of byDay) {
          await tx.stockTransferLine.create({
            data: {
              transferId: id,
              variantId: l.variantId,
              producedOn: new Date(`${day}T00:00:00Z`),
              quantitySent: quantity,
            },
          });
        }
      }
      await tx.auditLog.create({
        data: {
          id: uuidv7(),
          occurredAt: now,
          action: 'stock.transfer_sent',
          branchId: dto.fromBranchId,
          actorStaffId: user.staffId,
          entityType: 'stock_transfer',
          entityId: id,
          data: { toBranchId: dto.toBranchId },
        },
      });
      return tx.stockTransfer.findUniqueOrThrow({
        where: { id },
        include: TRANSFER_INCLUDE,
      });
    });
    return formatTransfer(transfer);
  }

  /** What arrived enters stock; a difference is flagged (M5.4). */
  async receive(user: AuthenticatedUser, id: string, dto: ReceiveTransferDto) {
    const now = this.clock.now();
    const transfer = await this.prisma.$transaction(async (tx) => {
      await tx.$queryRaw`SELECT 1 FROM "stock_transfer" WHERE "id" = ${id}::uuid FOR UPDATE`;
      const t = await tx.stockTransfer.findUnique({
        where: { id },
        include: { lines: true },
      });
      const scope = this.scope(user);
      if (!t || (scope && !scope.includes(t.toBranchId))) {
        throw new NotFoundException({
          code: 'NOT_FOUND',
          message: 'Transfer not found',
        });
      }
      if (t.status !== TransferStatus.SENT) {
        throw new ConflictException({
          code: 'CONFLICT',
          message: 'This transfer was already received',
        });
      }
      const key = (variantId: string, day: string) => `${variantId}|${day}`;
      const given = new Map(
        dto.lines.map((l) => [
          key(l.variantId, l.producedOn),
          l.quantityReceived,
        ]),
      );
      if (
        given.size !== t.lines.length ||
        t.lines.some((l) => !given.has(key(l.variantId, dayOf(l.producedOn))))
      ) {
        throw new BadRequestException({
          code: 'VALIDATION_FAILED',
          message: 'Give one row per line of the transfer',
        });
      }
      let flagged = false;
      for (const l of t.lines) {
        const day = dayOf(l.producedOn);
        const quantity = given.get(key(l.variantId, day))!;
        if (quantity !== l.quantitySent) flagged = true;
        await tx.stockTransferLine.update({
          where: {
            transferId_variantId_producedOn: {
              transferId: id,
              variantId: l.variantId,
              producedOn: l.producedOn,
            },
          },
          data: { quantityReceived: quantity },
        });
        if (quantity === 0) continue;
        await this.ledger.lock(tx, t.toBranchId, l.variantId);
        await this.ledger.addLot(
          tx,
          {
            branchId: t.toBranchId,
            variantId: l.variantId,
            quantity,
            kind: StockEventKind.TRANSFER_IN,
            referenceType: 'transfer',
            referenceId: id,
            staffId: user.staffId,
            occurredAt: now,
          },
          day,
        );
      }
      await tx.stockTransfer.update({
        where: { id },
        data: {
          status: TransferStatus.RECEIVED,
          receivedByStaffId: user.staffId,
          receivedAt: now,
          flagged,
        },
      });
      const audit = {
        occurredAt: now,
        branchId: t.toBranchId,
        actorStaffId: user.staffId,
        entityType: 'stock_transfer',
        entityId: id,
        data: { flagged },
      };
      await tx.auditLog.create({
        data: { ...audit, id: uuidv7(), action: 'stock.transfer_received' },
      });
      if (flagged) {
        await tx.auditLog.create({
          data: { ...audit, id: uuidv7(), action: 'stock.transfer_mismatch' },
        });
      }
      return tx.stockTransfer.findUniqueOrThrow({
        where: { id },
        include: TRANSFER_INCLUDE,
      });
    });
    return formatTransfer(transfer);
  }

  /**
   * Proves every lot equals its ledger rows (M5.6). It reports and never
   * corrects: a mismatch means something wrote outside the ledger.
   */
  async runCheck() {
    const { rows, bad } = await this.prisma.$transaction(
      async (tx) => {
        const lots = await tx.stockLot.findMany({
          select: {
            id: true,
            branchId: true,
            variantId: true,
            quantityLeft: true,
          },
        });
        const sums = new Map(
          (
            await tx.stockEvent.groupBy({
              by: ['lotId'],
              where: { lotId: { not: null } },
              _sum: { quantity: true },
            })
          ).map((s) => [s.lotId, s._sum.quantity ?? 0]),
        );
        return {
          rows: lots.length,
          bad: lots.filter((l) => (sums.get(l.id) ?? 0) !== l.quantityLeft),
        };
      },
      { isolationLevel: Prisma.TransactionIsolationLevel.RepeatableRead },
    );
    const checkedAt = this.clock.now();
    await this.prisma.$transaction(async (tx) => {
      await tx.stockCheck.create({
        data: {
          id: uuidv7(),
          checkedAt,
          rowsChecked: rows,
          mismatches: bad.length,
        },
      });
      for (const l of bad) {
        await tx.auditLog.create({
          data: {
            id: uuidv7(),
            occurredAt: checkedAt,
            action: 'stock.ledger_mismatch',
            branchId: l.branchId,
            entityType: 'stock_lot',
            entityId: l.id,
            data: { variantId: l.variantId, quantityLeft: l.quantityLeft },
          },
        });
      }
    });
    return { rows, mismatches: bad.length };
  }

  async latestCheck() {
    const c = await this.prisma.stockCheck.findFirst({
      orderBy: { checkedAt: 'desc' },
    });
    return {
      checkedAt: c?.checkedAt.toISOString() ?? null,
      rowsChecked: c?.rowsChecked ?? 0,
      mismatches: c?.mismatches ?? 0,
    };
  }
}
