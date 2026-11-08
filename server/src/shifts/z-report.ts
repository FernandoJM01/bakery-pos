import { TaxByRate } from '../sales/sale-totals';

export interface ZSaleLine {
  lineNo: number;
  ivaBp: number;
  iepsBp: number;
  baseCents: number;
  iepsCents: number;
  ivaCents: number;
}

export interface ZSale {
  grossCents: number;
  discountCents: number;
  totalCents: number;
  lines: ZSaleLine[];
}

export interface ZRefund {
  kind: 'REFUND' | 'VOID';
  totalCents: number;
  /** Each refund line's parts, with the rates of the sale line. */
  lines: Omit<ZSaleLine, 'lineNo'>[];
}

export interface ZMovement {
  kind: 'IN' | 'OUT';
  reason: string;
  amountCents: number;
}

/**
 * The Z report of a shift from its stored rows (M4 brief 4.5). Tax by rate
 * is net of refunds and is never recomputed from prices.
 */
export function computeZReport(
  sales: readonly ZSale[],
  refunds: readonly ZRefund[],
  movements: readonly ZMovement[],
  prepaidCollectedCents = 0,
) {
  const taxes = new Map<string, TaxByRate>();
  const add = (
    kind: 'IVA' | 'IEPS',
    rateBp: number,
    base: number,
    tax: number,
  ) => {
    const key = `${kind}:${rateBp}`;
    const e = taxes.get(key) ?? { kind, rateBp, baseCents: 0, taxCents: 0 };
    e.baseCents += base;
    e.taxCents += tax;
    taxes.set(key, e);
  };
  const addLine = (l: Omit<ZSaleLine, 'lineNo'>, sign: 1 | -1) => {
    if (l.iepsBp) {
      add('IEPS', l.iepsBp, sign * l.baseCents, sign * l.iepsCents);
    }
    add('IVA', l.ivaBp, sign * (l.baseCents + l.iepsCents), sign * l.ivaCents);
  };
  for (const s of sales) for (const l of s.lines) addLine(l, 1);
  for (const r of refunds) for (const l of r.lines) addLine(l, -1);

  const total = <T>(xs: readonly T[], f: (x: T) => number) =>
    xs.reduce((a, x) => a + f(x), 0);
  const byKind = (kind: ZRefund['kind']) =>
    refunds.filter((r) => r.kind === kind);

  const grouped = new Map<string, ZMovement>();
  for (const m of movements) {
    const key = `${m.kind}:${m.reason}`;
    const e = grouped.get(key) ?? { ...m, amountCents: 0 };
    e.amountCents += m.amountCents;
    grouped.set(key, e);
  }

  return {
    saleCount: sales.length,
    grossCents: total(sales, (s) => s.grossCents),
    discountCents: total(sales, (s) => s.discountCents),
    netCents: total(sales, (s) => s.totalCents),
    taxes: [...taxes.values()].sort(
      (a, b) => a.kind.localeCompare(b.kind) || a.rateBp - b.rateBp,
    ),
    refundCount: byKind('REFUND').length,
    refundCents: total(byKind('REFUND'), (r) => r.totalCents),
    voidCount: byKind('VOID').length,
    voidCents: total(byKind('VOID'), (r) => r.totalCents),
    prepaidCollectedCents,
    cashInCents: total(
      movements.filter((m) => m.kind === 'IN'),
      (m) => m.amountCents,
    ),
    cashOutCents: total(
      movements.filter((m) => m.kind === 'OUT'),
      (m) => m.amountCents,
    ),
    movements: [...grouped.values()].sort(
      (a, b) =>
        a.kind.localeCompare(b.kind) || a.reason.localeCompare(b.reason),
    ),
  };
}
