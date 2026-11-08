import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { ClockService } from '../common/clock.service';
import { localDay } from '../common/local-day';
import { PrismaService } from '../prisma/prisma.service';
import { daysBefore, daysBetween } from '../stock/fifo-days';
import { SalesGroup } from './dto/reports.dto';

export interface SalesRow {
  key: string;
  label: string;
  saleCount: number;
  quantity: number | null;
  grossCents: number;
  discountCents: number;
  netCents: number;
  cashCents: number;
  prepaidCents: number;
  refundCents: number;
  /** Tax rows only: the base the tax applies to, and the tax. */
  baseCents: number | null;
  taxCents: number | null;
}

const MAX_DAYS = 400;
const n = (v: unknown) => Number(v ?? 0);

/** The key a sale (or a refund) falls under, per grouping (M9.1). */
const SALE_KEY: Record<Exclude<SalesGroup, 'product' | 'taxRate'>, string> = {
  day: `to_char(s.occurred_at AT TIME ZONE b.timezone, 'YYYY-MM-DD')`,
  hour: `to_char(s.occurred_at AT TIME ZONE b.timezone, 'HH24')`,
  branch: `s.branch_id::text`,
  device: `s.device_id::text`,
  cashier: `s.cashier_staff_id::text`,
};
const REFUND_KEY: typeof SALE_KEY = {
  day: `to_char(r.occurred_at AT TIME ZONE b.timezone, 'YYYY-MM-DD')`,
  hour: `to_char(r.occurred_at AT TIME ZONE b.timezone, 'HH24')`,
  branch: `s.branch_id::text`,
  device: `r.device_id::text`,
  cashier: `r.staff_id::text`,
};

/**
 * Reports for the owner and managers (M9). Days and hours are the
 * branch's own; sales and refunds count on the day each happened, as the
 * Z reports do, so the two always agree.
 */
@Injectable()
export class ReportsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
  ) {}

  /** Branches the caller may see, narrowed to [branchId] when given. */
  branches(user: AuthenticatedUser, branchId?: string): string[] | null {
    const scope = user.permissions.includes('reports.all')
      ? null
      : user.branchIds;
    if (branchId) {
      if (scope && !scope.includes(branchId)) {
        throw new ForbiddenException({
          code: 'PERMISSION_DENIED',
          message: 'You cannot see reports of this branch',
        });
      }
      return [branchId];
    }
    return scope;
  }

  private range(from: string, to: string) {
    if (to < from) {
      throw new BadRequestException({
        code: 'VALIDATION_FAILED',
        message: 'The range ends before it starts',
      });
    }
    if (daysBetween(from, to) > MAX_DAYS) {
      throw new BadRequestException({
        code: 'VALIDATION_FAILED',
        message: `A report covers at most ${MAX_DAYS} days`,
      });
    }
  }

  private branchFilter(scope: string[] | null, column: string) {
    return scope
      ? Prisma.sql`AND ${Prisma.raw(column)} = ANY(${scope}::uuid[])`
      : Prisma.empty;
  }

  private async labels(group: SalesGroup, keys: string[]) {
    const ids = keys.filter((k) => /^[0-9a-f-]{36}$/.test(k));
    switch (group) {
      case 'branch':
        return new Map(
          (
            await this.prisma.branch.findMany({ where: { id: { in: ids } } })
          ).map((b) => [b.id, b.name]),
        );
      case 'device':
        return new Map(
          (
            await this.prisma.device.findMany({ where: { id: { in: ids } } })
          ).map((d) => [d.id, d.name]),
        );
      case 'cashier':
        return new Map(
          (
            await this.prisma.staff.findMany({ where: { id: { in: ids } } })
          ).map((s) => [s.id, s.displayName]),
        );
      case 'product':
        return new Map(
          (
            await this.prisma.productVariant.findMany({
              where: { id: { in: ids } },
              include: { product: true },
            })
          ).map((v) => [v.id, `${v.product.name} · ${v.name}`]),
        );
      case 'hour':
        return new Map(keys.map((k) => [k, `${k}:00`]));
      case 'taxRate':
        // Labelled where the rows are made: "IVA 16%".
        return new Map<string, string>();
      default:
        return new Map(keys.map((k) => [k, k]));
    }
  }

  private blank(key: string): SalesRow {
    return {
      key,
      label: key,
      saleCount: 0,
      quantity: null,
      grossCents: 0,
      discountCents: 0,
      netCents: 0,
      cashCents: 0,
      prepaidCents: 0,
      refundCents: 0,
      baseCents: null,
      taxCents: null,
    };
  }

  async sales(
    user: AuthenticatedUser,
    q: { from: string; to: string; branchId?: string; groupBy: SalesGroup },
  ) {
    this.range(q.from, q.to);
    const scope = this.branches(user, q.branchId);
    const inRange = (col: string) =>
      Prisma.sql`(${Prisma.raw(col)} AT TIME ZONE b.timezone)::date BETWEEN ${q.from}::date AND ${q.to}::date`;
    const rows = new Map<string, SalesRow>();
    const row = (key: string) => {
      let r = rows.get(key);
      if (!r) rows.set(key, (r = this.blank(key)));
      return r;
    };

    if (q.groupBy === 'product') {
      const sold = await this.prisma.$queryRaw<
        {
          key: string;
          sales: bigint;
          qty: bigint;
          gross: bigint;
          disc: bigint;
          net: bigint;
        }[]
      >`SELECT l.variant_id::text AS key, COUNT(DISTINCT s.id) AS sales,
          SUM(l.quantity) AS qty, SUM(l.gross_cents) AS gross,
          SUM(l.line_discount_cents + l.order_discount_cents) AS disc,
          SUM(l.net_cents) AS net
        FROM sale_line l JOIN sale s ON s.id = l.sale_id JOIN branch b ON b.id = s.branch_id
        WHERE ${inRange('s.occurred_at')} ${this.branchFilter(scope, 's.branch_id')}
        GROUP BY 1`;
      for (const s of sold) {
        const r = row(s.key);
        r.saleCount = n(s.sales);
        r.quantity = n(s.qty);
        r.grossCents = n(s.gross);
        r.discountCents = n(s.disc);
        r.netCents = n(s.net);
      }
      const back = await this.prisma.$queryRaw<
        { key: string; cents: bigint }[]
      >`
        SELECT l.variant_id::text AS key, SUM(rl.amount_cents) AS cents
        FROM refund_line rl JOIN refund r ON r.id = rl.refund_id
        JOIN sale s ON s.id = r.sale_id JOIN branch b ON b.id = s.branch_id
        JOIN sale_line l ON l.sale_id = r.sale_id AND l.line_no = rl.line_no
        WHERE ${inRange('r.occurred_at')} ${this.branchFilter(scope, 's.branch_id')}
        GROUP BY 1`;
      for (const b of back) row(b.key).refundCents = n(b.cents);
    } else if (q.groupBy === 'taxRate') {
      const parts = await this.prisma.$queryRaw<
        { kind: string; bp: number; base: bigint; tax: bigint; sign: number }[]
      >`SELECT 'IVA' AS kind, l.iva_bp AS bp, SUM(l.base_cents + l.ieps_cents) AS base,
          SUM(l.iva_cents) AS tax, 1 AS sign
        FROM sale_line l JOIN sale s ON s.id = l.sale_id JOIN branch b ON b.id = s.branch_id
        WHERE ${inRange('s.occurred_at')} ${this.branchFilter(scope, 's.branch_id')}
        GROUP BY 2
        UNION ALL
        SELECT 'IEPS', l.ieps_bp, SUM(l.base_cents), SUM(l.ieps_cents), 1
        FROM sale_line l JOIN sale s ON s.id = l.sale_id JOIN branch b ON b.id = s.branch_id
        WHERE l.ieps_bp > 0 AND ${inRange('s.occurred_at')} ${this.branchFilter(scope, 's.branch_id')}
        GROUP BY 2
        UNION ALL
        SELECT 'IVA', l.iva_bp, SUM(rl.base_cents + rl.ieps_cents), SUM(rl.iva_cents), -1
        FROM refund_line rl JOIN refund r ON r.id = rl.refund_id
        JOIN sale s ON s.id = r.sale_id JOIN branch b ON b.id = s.branch_id
        JOIN sale_line l ON l.sale_id = r.sale_id AND l.line_no = rl.line_no
        WHERE ${inRange('r.occurred_at')} ${this.branchFilter(scope, 's.branch_id')}
        GROUP BY 2
        UNION ALL
        SELECT 'IEPS', l.ieps_bp, SUM(rl.base_cents), SUM(rl.ieps_cents), -1
        FROM refund_line rl JOIN refund r ON r.id = rl.refund_id
        JOIN sale s ON s.id = r.sale_id JOIN branch b ON b.id = s.branch_id
        JOIN sale_line l ON l.sale_id = r.sale_id AND l.line_no = rl.line_no
        WHERE l.ieps_bp > 0 AND ${inRange('r.occurred_at')} ${this.branchFilter(scope, 's.branch_id')}
        GROUP BY 2`;
      for (const p of parts) {
        const key = `${p.kind}:${p.bp}`;
        const r = row(key);
        r.label = `${p.kind} ${(p.bp / 100).toFixed(p.bp % 100 ? 2 : 0)}%`;
        // Tax by rate is net of refunds, as on the Z report.
        r.baseCents = (r.baseCents ?? 0) + p.sign * n(p.base);
        r.taxCents = (r.taxCents ?? 0) + p.sign * n(p.tax);
        if (p.sign < 0) r.refundCents += n(p.base) + n(p.tax);
        else r.netCents += n(p.base) + n(p.tax);
      }
    } else {
      const key = Prisma.raw(SALE_KEY[q.groupBy]);
      const sold = await this.prisma.$queryRaw<
        {
          key: string;
          sales: bigint;
          gross: bigint;
          disc: bigint;
          net: bigint;
          cash: bigint;
          prepaid: bigint;
        }[]
      >`SELECT ${key} AS key, COUNT(*) AS sales, SUM(s.gross_cents) AS gross,
          SUM(s.discount_cents) AS disc, SUM(s.total_cents) AS net,
          SUM(CASE WHEN p.method = 'CASH' THEN p.amount_cents ELSE 0 END) AS cash,
          SUM(CASE WHEN p.method = 'PREPAID' THEN p.amount_cents ELSE 0 END) AS prepaid
        FROM sale s JOIN branch b ON b.id = s.branch_id JOIN payment p ON p.sale_id = s.id
        WHERE ${inRange('s.occurred_at')} ${this.branchFilter(scope, 's.branch_id')}
        GROUP BY 1`;
      for (const s of sold) {
        const r = row(s.key);
        r.saleCount = n(s.sales);
        r.grossCents = n(s.gross);
        r.discountCents = n(s.disc);
        r.netCents = n(s.net);
        r.cashCents = n(s.cash);
        r.prepaidCents = n(s.prepaid);
      }
      const back = await this.prisma.$queryRaw<
        { key: string; cents: bigint }[]
      >`
        SELECT ${Prisma.raw(REFUND_KEY[q.groupBy])} AS key, SUM(r.total_cents) AS cents
        FROM refund r JOIN sale s ON s.id = r.sale_id JOIN branch b ON b.id = s.branch_id
        WHERE ${inRange('r.occurred_at')} ${this.branchFilter(scope, 's.branch_id')}
        GROUP BY 1`;
      for (const b of back) row(b.key).refundCents = n(b.cents);
    }

    const names = await this.labels(q.groupBy, [...rows.keys()]);
    const items = [...rows.values()]
      .map((r) => ({ ...r, label: names.get(r.key) ?? r.label }))
      .sort((a, b) =>
        ['day', 'hour', 'taxRate'].includes(q.groupBy)
          ? a.key.localeCompare(b.key)
          : b.netCents - a.netCents || a.label.localeCompare(b.label),
      );
    const totals = items.reduce((t, r) => {
      t.saleCount += q.groupBy === 'product' ? 0 : r.saleCount;
      t.grossCents += r.grossCents;
      t.discountCents += r.discountCents;
      t.netCents += r.netCents;
      t.cashCents += r.cashCents;
      t.prepaidCents += r.prepaidCents;
      t.refundCents += r.refundCents;
      return t;
    }, this.blank('total'));
    return {
      from: q.from,
      to: q.to,
      groupBy: q.groupBy,
      items,
      totals: { ...totals, label: 'Total' },
    };
  }

  /** Per product and branch: what was made, sold, wasted and is left (M9.2). */
  async stock(
    user: AuthenticatedUser,
    q: { from: string; to: string; branchId?: string },
  ) {
    this.range(q.from, q.to);
    const scope = this.branches(user, q.branchId);
    const moves = await this.prisma.$queryRaw<
      { branch: string; variant: string; kind: string; qty: bigint }[]
    >`SELECT e.branch_id::text AS branch, e.variant_id::text AS variant,
        e.kind::text AS kind, SUM(e.quantity) AS qty
      FROM stock_event e JOIN branch b ON b.id = e.branch_id
      WHERE (e.occurred_at AT TIME ZONE b.timezone)::date BETWEEN ${q.from}::date AND ${q.to}::date
      ${this.branchFilter(scope, 'e.branch_id')}
      GROUP BY 1, 2, 3`;
    const onHand = await this.prisma.$queryRaw<
      { branch: string; variant: string; qty: bigint }[]
    >`SELECT e.branch_id::text AS branch, e.variant_id::text AS variant, SUM(e.quantity) AS qty
      FROM stock_event e JOIN branch b ON b.id = e.branch_id
      WHERE (e.occurred_at AT TIME ZONE b.timezone)::date <= ${q.to}::date
      ${this.branchFilter(scope, 'e.branch_id')}
      GROUP BY 1, 2`;
    const dayOld = await this.prisma.$queryRaw<
      { branch: string; variant: string; qty: bigint }[]
    >`SELECT s.branch_id::text AS branch, l.variant_id::text AS variant, SUM(l.quantity) AS qty
      FROM sale_line l JOIN sale s ON s.id = l.sale_id JOIN branch b ON b.id = s.branch_id
      WHERE l.day_old AND (s.occurred_at AT TIME ZONE b.timezone)::date BETWEEN ${q.from}::date AND ${q.to}::date
      ${this.branchFilter(scope, 's.branch_id')}
      GROUP BY 1, 2`;
    const waste = await this.prisma.$queryRaw<
      { branch: string; variant: string; cost: bigint | null }[]
    >`SELECT w.branch_id::text AS branch, w.variant_id::text AS variant,
        SUM(w.quantity * w.cost_cents) AS cost
      FROM stock_waste w JOIN branch b ON b.id = w.branch_id
      WHERE (w.occurred_at AT TIME ZONE b.timezone)::date BETWEEN ${q.from}::date AND ${q.to}::date
      ${this.branchFilter(scope, 'w.branch_id')}
      GROUP BY 1, 2`;

    const rows = new Map<
      string,
      {
        branchId: string;
        variantId: string;
        produced: number;
        sold: number;
        dayOldSold: number;
        returned: number;
        wasted: number;
        transferredIn: number;
        transferredOut: number;
        adjusted: number;
        onHand: number;
        wasteCostCents: number | null;
      }
    >();
    const row = (branchId: string, variantId: string) => {
      const k = `${branchId}|${variantId}`;
      let r = rows.get(k);
      if (!r) {
        rows.set(
          k,
          (r = {
            branchId,
            variantId,
            produced: 0,
            sold: 0,
            dayOldSold: 0,
            returned: 0,
            wasted: 0,
            transferredIn: 0,
            transferredOut: 0,
            adjusted: 0,
            onHand: 0,
            wasteCostCents: null,
          }),
        );
      }
      return r;
    };
    for (const m of moves) {
      const r = row(m.branch, m.variant);
      const qty = n(m.qty);
      switch (m.kind) {
        case 'PRODUCTION':
          r.produced += qty;
          break;
        case 'SALE':
          r.sold -= qty;
          break;
        case 'REFUND_RETURN':
          r.returned += qty;
          break;
        case 'WASTE':
          r.wasted -= qty;
          break;
        case 'TRANSFER_IN':
          r.transferredIn += qty;
          break;
        case 'TRANSFER_OUT':
          r.transferredOut -= qty;
          break;
        default:
          r.adjusted += qty;
      }
    }
    for (const h of onHand) row(h.branch, h.variant).onHand = n(h.qty);
    for (const d of dayOld) row(d.branch, d.variant).dayOldSold = n(d.qty);
    for (const w of waste) {
      if (w.cost != null) row(w.branch, w.variant).wasteCostCents = n(w.cost);
    }

    const variants = new Map(
      (
        await this.prisma.productVariant.findMany({
          where: { id: { in: [...rows.values()].map((r) => r.variantId) } },
          include: { product: true },
        })
      ).map((v) => [v.id, v]),
    );
    const branchNames = new Map(
      (await this.prisma.branch.findMany()).map((b) => [b.id, b.name]),
    );
    return {
      from: q.from,
      to: q.to,
      items: [...rows.values()]
        .map((r) => ({
          ...r,
          branchName: branchNames.get(r.branchId) ?? '',
          productName: variants.get(r.variantId)?.product.name ?? '',
          variantName: variants.get(r.variantId)?.name ?? '',
        }))
        .sort(
          (a, b) =>
            a.branchName.localeCompare(b.branchName) ||
            a.productName.localeCompare(b.productName),
        ),
    };
  }

  /** Prepaid balances and what orders are due (M9.3). */
  async orders(
    user: AuthenticatedUser,
    q: { from: string; to: string; branchId?: string },
  ) {
    this.range(q.from, q.to);
    const scope = this.branches(user, q.branchId);
    const tickets = await this.prisma.$queryRaw<
      { day: string; status: string; count: bigint; cents: bigint }[]
    >`SELECT to_char(t.due_date, 'YYYY-MM-DD') AS day, t.status::text AS status,
        COUNT(*) AS count, SUM(t.total_cents) AS cents
      FROM order_ticket t
      WHERE t.due_date BETWEEN ${q.from}::date AND ${q.to}::date
      ${this.branchFilter(scope, 't.branch_id')}
      GROUP BY 1, 2 ORDER BY 1, 2`;
    // A customer's balance is theirs, not a branch's; a manager sees the
    // customers with orders in their branches.
    const balances = await this.prisma.$queryRaw<
      { id: string; name: string; phone: string | null; cents: bigint }[]
    >`SELECT c.id::text AS id, c.name, c.phone, COALESCE(SUM(e.amount_cents), 0) AS cents
      FROM customer c LEFT JOIN prepaid_entry e ON e.customer_id = c.id
      WHERE ${scope ? Prisma.sql`EXISTS (SELECT 1 FROM customer_order o WHERE o.customer_id = c.id AND o.branch_id = ANY(${scope}::uuid[]))` : Prisma.sql`TRUE`}
      GROUP BY c.id ORDER BY 4 ASC, c.name`;
    return {
      from: q.from,
      to: q.to,
      tickets: tickets.map((t) => ({
        date: t.day,
        status: t.status,
        count: n(t.count),
        totalCents: n(t.cents),
      })),
      balances: balances.map((b) => ({
        customerId: b.id,
        name: b.name,
        phone: b.phone,
        balanceCents: n(b.cents),
      })),
    };
  }

  /**
   * The owner's day at a glance (M9): today against the same weekday last
   * week, by hour, top products, the last 14 days, and what needs a look.
   */
  async dashboard(
    user: AuthenticatedUser,
    q: { date?: string; branchId?: string },
  ) {
    const scope = this.branches(user, q.branchId);
    const tz =
      (
        await this.prisma.branch.findFirst({
          where: scope ? { id: { in: scope } } : {},
          orderBy: { code: 'asc' },
        })
      )?.timezone ?? 'America/Mexico_City';
    const date = q.date ?? localDay(this.clock.now(), tz);
    const weekAgo = daysBefore(date, 7);
    const base = { branchId: q.branchId };
    const [today, lastWeek, byHour, byProduct, byDay, byBranch] =
      await Promise.all([
        this.sales(user, { ...base, from: date, to: date, groupBy: 'day' }),
        this.sales(user, {
          ...base,
          from: weekAgo,
          to: weekAgo,
          groupBy: 'day',
        }),
        this.sales(user, { ...base, from: date, to: date, groupBy: 'hour' }),
        this.sales(user, { ...base, from: date, to: date, groupBy: 'product' }),
        this.sales(user, {
          ...base,
          from: daysBefore(date, 13),
          to: date,
          groupBy: 'day',
        }),
        this.sales(user, { ...base, from: date, to: date, groupBy: 'branch' }),
      ]);
    const filter = this.branchFilter(scope, 'x.branch_id');
    const [waste] = await this.prisma.$queryRaw<
      { cost: bigint | null; units: bigint | null }[]
    >`SELECT SUM(x.quantity * x.cost_cents) AS cost, SUM(x.quantity) AS units
      FROM stock_waste x JOIN branch b ON b.id = x.branch_id
      WHERE (x.occurred_at AT TIME ZONE b.timezone)::date = ${date}::date ${filter}`;
    const [flagged] = await this.prisma.$queryRaw<{ count: bigint }[]>`
      SELECT COUNT(*) AS count FROM cash_shift x JOIN branch b ON b.id = x.branch_id
      WHERE x.flagged AND (x.closed_at AT TIME ZONE b.timezone)::date = ${date}::date ${filter}`;
    const [prepaid] = await this.prisma.$queryRaw<{ cents: bigint | null }[]>`
      SELECT SUM(e.amount_cents) AS cents
      FROM prepaid_entry e JOIN cash_shift x ON x.id = e.shift_id JOIN branch b ON b.id = x.branch_id
      WHERE e.kind = 'PAYMENT' AND (e.occurred_at AT TIME ZONE b.timezone)::date = ${date}::date ${filter}`;
    const [owing] = await this.prisma.$queryRaw<{ count: bigint }[]>`
      SELECT COUNT(*) AS count FROM (
        SELECT e.customer_id FROM prepaid_entry e GROUP BY 1 HAVING SUM(e.amount_cents) < 0
      ) t`;

    const t = today.totals;
    const w = lastWeek.totals;
    return {
      date,
      compareDate: weekAgo,
      netCents: t.netCents - t.refundCents,
      saleCount: t.saleCount,
      averageTicketCents: t.saleCount
        ? Math.round(t.netCents / t.saleCount)
        : 0,
      refundCents: t.refundCents,
      compareNetCents: w.netCents - w.refundCents,
      compareSaleCount: w.saleCount,
      wasteCostCents: n(waste?.cost),
      wasteUnits: n(waste?.units),
      flaggedShifts: n(flagged?.count),
      prepaidCollectedCents: n(prepaid?.cents),
      customersOwing: n(owing?.count),
      hours: byHour.items.map((r) => ({
        hour: Number(r.key),
        netCents: r.netCents,
        saleCount: r.saleCount,
      })),
      topProducts: byProduct.items.slice(0, 5).map((r) => ({
        variantId: r.key,
        label: r.label,
        quantity: r.quantity ?? 0,
        netCents: r.netCents,
      })),
      days: byDay.items.map((r) => ({
        date: r.key,
        netCents: r.netCents - r.refundCents,
        saleCount: r.saleCount,
      })),
      branches: byBranch.items.map((r) => ({
        branchId: r.key,
        name: r.label,
        netCents: r.netCents - r.refundCents,
        saleCount: r.saleCount,
      })),
    };
  }
}
