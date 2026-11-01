import { divRoundHalfUp, splitTax } from '../catalog/tax-split';

export type DiscountKindValue = 'PERCENT' | 'AMOUNT';

export interface TotalsDiscount {
  kind: DiscountKindValue;
  /** Basis points for PERCENT, centavos for AMOUNT. */
  value: number;
}

export interface TotalsLineInput {
  lineNo: number;
  unitPriceCents: number;
  quantity: number;
  ivaBp: number;
  iepsBp: number;
  discount?: TotalsDiscount | null;
}

export interface TotalsLine {
  lineNo: number;
  grossCents: number;
  lineDiscountCents: number;
  orderDiscountCents: number;
  netCents: number;
  baseCents: number;
  iepsCents: number;
  ivaCents: number;
}

export interface TaxByRate {
  kind: 'IVA' | 'IEPS';
  rateBp: number;
  /** IEPS: the base. IVA: the base plus IEPS. */
  baseCents: number;
  taxCents: number;
}

export interface SaleTotals {
  lines: TotalsLine[];
  grossCents: number;
  discountCents: number;
  totalCents: number;
  taxes: TaxByRate[];
}

export class TotalsError extends Error {}

function discountCents(d: TotalsDiscount, amount: number): number {
  if (d.kind === 'PERCENT') {
    if (d.value > 10000) throw new TotalsError('A percentage is at most 100%');
    return divRoundHalfUp(amount * d.value, 10000);
  }
  if (d.value > amount) {
    throw new TotalsError('A discount cannot exceed the amount it applies to');
  }
  return d.value;
}

/**
 * Sale totals, M3 brief section 4.2. The app has the same function; both
 * reproduce `contracts/fixtures/sale-totals-cases.json` (D3).
 */
export function computeSaleTotals(
  lines: readonly TotalsLineInput[],
  orderDiscount?: TotalsDiscount | null,
): SaleTotals {
  const gross = lines.map((l) => l.unitPriceCents * l.quantity);
  const lineDisc = lines.map((l, i) =>
    l.discount ? discountCents(l.discount, gross[i]) : 0,
  );
  const after = gross.map((g, i) => g - lineDisc[i]);
  const sum = after.reduce((a, b) => a + b, 0);
  const ticket = orderDiscount ? discountCents(orderDiscount, sum) : 0;

  const shares = after.map(() => 0);
  if (sum > 0 && ticket > 0) {
    const rem: { r: number; i: number }[] = [];
    after.forEach((a, i) => {
      // ticket × afterLine can pass 2^53 on a huge ticket; BigInt keeps it exact.
      const p = BigInt(ticket) * BigInt(a);
      shares[i] = Number(p / BigInt(sum));
      rem.push({ r: Number(p % BigInt(sum)), i });
    });
    let left = ticket - shares.reduce((a, b) => a + b, 0);
    rem.sort((x, y) => y.r - x.r || lines[x.i].lineNo - lines[y.i].lineNo);
    for (const { i } of rem) {
      if (left === 0) break;
      shares[i] += 1;
      left -= 1;
    }
  }

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

  const out: TotalsLine[] = lines.map((l, i) => {
    const net = after[i] - shares[i];
    const t = splitTax(net, l.ivaBp, l.iepsBp);
    if (l.iepsBp) add('IEPS', l.iepsBp, t.baseCents, t.iepsCents);
    add('IVA', l.ivaBp, t.baseCents + t.iepsCents, t.ivaCents);
    return {
      lineNo: l.lineNo,
      grossCents: gross[i],
      lineDiscountCents: lineDisc[i],
      orderDiscountCents: shares[i],
      netCents: net,
      ...t,
    };
  });

  return {
    lines: out,
    grossCents: out.reduce((a, l) => a + l.grossCents, 0),
    discountCents: out.reduce(
      (a, l) => a + l.lineDiscountCents + l.orderDiscountCents,
      0,
    ),
    totalCents: out.reduce((a, l) => a + l.netCents, 0),
    taxes: [...taxes.values()].sort(
      (a, b) => a.kind.localeCompare(b.kind) || a.rateBp - b.rateBp,
    ),
  };
}

/**
 * Whether a discount takes a larger share than the cashier limit
 * (brief 4.2 step 7): `cents / base > limitBp / 10000`, in integers.
 */
export function overLimit(
  cents: number,
  base: number,
  limitBp: number,
): boolean {
  return base > 0 && cents * 10000 > limitBp * base;
}

/**
 * Amount of refunding `k` more units of a line with net `N` and quantity
 * `q`, `r` already refunded (brief 4.3). Partial refunds add up to `N`.
 */
export function refundAmountCents(
  net: number,
  quantity: number,
  already: number,
  units: number,
): number {
  return (
    divRoundHalfUp(net * (already + units), quantity) -
    divRoundHalfUp(net * already, quantity)
  );
}
