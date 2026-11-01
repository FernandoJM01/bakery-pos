import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  Device,
  Payment,
  Prisma,
  Refund,
  RefundLine,
  Sale,
  SaleDiscount,
  SaleLine,
  SaleVoidedLine,
  Staff,
} from '@prisma/client';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { PrismaService } from '../prisma/prisma.service';
import { SalesQueryDto } from './dto/sales-query.dto';
import { TaxByRate } from './sale-totals';

type SummaryRow = Sale & {
  cashier: Pick<Staff, 'displayName'>;
  _count: { lines: number };
};

type DetailRow = Sale & {
  cashier: Pick<Staff, 'displayName'>;
  lines: SaleLine[];
  discounts: SaleDiscount[];
  payments: Payment[];
  voidedLines: SaleVoidedLine[];
  refunds: (Refund & { lines: RefundLine[] })[];
};

const SUMMARY_INCLUDE = {
  cashier: { select: { displayName: true } },
  _count: { select: { lines: true } },
} as const;

const DETAIL_INCLUDE = {
  cashier: { select: { displayName: true } },
  lines: { orderBy: { lineNo: 'asc' } },
  discounts: { orderBy: [{ lineNo: 'asc' }, { id: 'asc' }] },
  payments: true,
  voidedLines: { orderBy: { seq: 'asc' } },
  refunds: {
    orderBy: [{ occurredAt: 'asc' }, { id: 'asc' }],
    include: { lines: { orderBy: { lineNo: 'asc' } } },
  },
} satisfies Prisma.SaleInclude;

function summary(
  s: Sale & { cashier: Pick<Staff, 'displayName'> },
  lineCount: number,
) {
  return {
    id: s.id,
    folio: s.folio,
    branchId: s.branchId,
    deviceId: s.deviceId,
    cashierStaffId: s.cashierStaffId,
    cashierName: s.cashier.displayName,
    occurredAt: s.occurredAt.toISOString(),
    status: s.status,
    lineCount,
    grossCents: s.grossCents,
    discountCents: s.discountCents,
    totalCents: s.totalCents,
    refundedCents: s.refundedCents,
  };
}

/** Tax by kind and rate, summed from the stored lines (M3 brief 4.2 step 6). */
export function taxesOf(lines: SaleLine[]): TaxByRate[] {
  const map = new Map<string, TaxByRate>();
  const add = (
    kind: 'IVA' | 'IEPS',
    rateBp: number,
    base: number,
    tax: number,
  ) => {
    const key = `${kind}:${rateBp}`;
    const e = map.get(key) ?? { kind, rateBp, baseCents: 0, taxCents: 0 };
    e.baseCents += base;
    e.taxCents += tax;
    map.set(key, e);
  };
  for (const l of lines) {
    if (l.iepsBp) add('IEPS', l.iepsBp, l.baseCents, l.iepsCents);
    add('IVA', l.ivaBp, l.baseCents + l.iepsCents, l.ivaCents);
  }
  return [...map.values()].sort(
    (a, b) => a.kind.localeCompare(b.kind) || a.rateBp - b.rateBp,
  );
}

export function formatSale(s: DetailRow) {
  return {
    ...summary(s, s.lines.length),
    folioNumber: s.folioNumber,
    shiftId: s.shiftId,
    receivedAt: s.receivedAt.toISOString(),
    lines: s.lines.map((l) => ({
      lineNo: l.lineNo,
      variantId: l.variantId,
      productName: l.productName,
      variantName: l.variantName,
      quantity: l.quantity,
      unitPriceCents: l.unitPriceCents,
      grossCents: l.grossCents,
      lineDiscountCents: l.lineDiscountCents,
      orderDiscountCents: l.orderDiscountCents,
      netCents: l.netCents,
      ivaRateId: l.ivaRateId,
      ivaBp: l.ivaBp,
      iepsRateId: l.iepsRateId,
      iepsBp: l.iepsBp,
      baseCents: l.baseCents,
      iepsCents: l.iepsCents,
      ivaCents: l.ivaCents,
      refundedQuantity: l.refundedQuantity,
      refundedCents: l.refundedCents,
    })),
    discounts: s.discounts.map((d) => ({
      lineNo: d.lineNo,
      kind: d.kind,
      value: d.value,
      cents: d.cents,
      reason: d.reason,
      note: d.note,
      approverStaffId: d.approverStaffId,
    })),
    taxes: taxesOf(s.lines),
    payments: s.payments.map((p) => ({
      method: p.method,
      amountCents: p.amountCents,
      tenderedCents: p.tenderedCents,
      changeCents: p.changeCents,
    })),
    voidedLines: s.voidedLines.map((v) => ({
      variantId: v.variantId,
      quantity: v.quantity,
      unitPriceCents: v.unitPriceCents,
      voidedAt: v.voidedAt.toISOString(),
      staffId: v.staffId,
    })),
    refunds: s.refunds.map((r) => ({
      id: r.id,
      kind: r.kind,
      reason: r.reason,
      note: r.note,
      deviceId: r.deviceId,
      staffId: r.staffId,
      approverStaffId: r.approverStaffId,
      occurredAt: r.occurredAt.toISOString(),
      totalCents: r.totalCents,
      lines: r.lines.map((l) => ({
        lineNo: l.lineNo,
        quantity: l.quantity,
        amountCents: l.amountCents,
        baseCents: l.baseCents,
        iepsCents: l.iepsCents,
        ivaCents: l.ivaCents,
        restock: l.restock,
      })),
    })),
  };
}

function encodeCursor(s: Sale) {
  return Buffer.from(`${s.occurredAt.toISOString()}|${s.id}`, 'utf8').toString(
    'base64url',
  );
}

function decodeCursor(cursor: string) {
  const [at, id] = Buffer.from(cursor, 'base64url').toString('utf8').split('|');
  const occurredAt = new Date(at ?? '');
  if (
    Number.isNaN(occurredAt.getTime()) ||
    !/^[0-9a-f-]{36}$/i.test(id ?? '')
  ) {
    throw new BadRequestException({
      code: 'VALIDATION_FAILED',
      message: 'Invalid cursor',
    });
  }
  return { occurredAt, id };
}

const notFound = () =>
  new NotFoundException({ code: 'NOT_FOUND', message: 'Sale not found' });

/** Sales for the back office and folio lookups for refunds (M3 brief 5). */
@Injectable()
export class SalesService {
  constructor(private readonly prisma: PrismaService) {}

  /** Branches the user may read, or null for every branch. */
  private scope(user: AuthenticatedUser): string[] | null {
    return user.permissions.includes('reports.all') ? null : user.branchIds;
  }

  async list(user: AuthenticatedUser, q: SalesQueryDto) {
    const scope = this.scope(user);
    if (q.branchId && scope && !scope.includes(q.branchId)) {
      throw new ForbiddenException({
        code: 'PERMISSION_DENIED',
        message: 'You cannot see sales of this branch',
      });
    }
    const limit = q.limit ?? 50;
    const and: Prisma.SaleWhereInput[] = [];
    if (scope) and.push({ branchId: { in: scope } });
    if (q.branchId) and.push({ branchId: q.branchId });
    if (q.deviceId) and.push({ deviceId: q.deviceId });
    if (q.folio) and.push({ folio: q.folio.trim().toUpperCase() });
    if (q.from) and.push({ occurredAt: { gte: new Date(q.from) } });
    if (q.to) and.push({ occurredAt: { lt: new Date(q.to) } });
    if (q.cursor) {
      const c = decodeCursor(q.cursor);
      and.push({
        OR: [
          { occurredAt: { lt: c.occurredAt } },
          { occurredAt: c.occurredAt, id: { lt: c.id } },
        ],
      });
    }
    const rows: SummaryRow[] = await this.prisma.sale.findMany({
      where: { AND: and },
      orderBy: [{ occurredAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      include: SUMMARY_INCLUDE,
    });
    const page = rows.slice(0, limit);
    return {
      items: page.map((s) => summary(s, s._count.lines)),
      nextCursor:
        rows.length > limit ? encodeCursor(page[page.length - 1]) : null,
    };
  }

  async get(user: AuthenticatedUser, saleId: string) {
    const sale = await this.prisma.sale.findUnique({
      where: { id: saleId },
      include: DETAIL_INCLUDE,
    });
    const scope = this.scope(user);
    // Another branch's sale reads as missing, not forbidden.
    if (!sale || (scope && !scope.includes(sale.branchId))) throw notFound();
    return formatSale(sale);
  }

  /** A sale of the till's branch by folio, for a refund or a void. */
  async lookup(device: Device, folio: string) {
    const sale = await this.prisma.sale.findUnique({
      where: { folio: folio.trim().toUpperCase() },
      include: DETAIL_INCLUDE,
    });
    if (!sale || sale.branchId !== device.branchId) throw notFound();
    return formatSale(sale);
  }
}
