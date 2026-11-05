import { divRoundHalfUp } from '../catalog/tax-split';

export interface FifoLot {
  id: string;
  /** YYYY-MM-DD at the branch. */
  producedOn: string;
  left: number;
}

export interface FifoResult {
  takes: { lotId: string; quantity: number }[];
  /** Units with no lot left to take from. */
  unassigned: number;
}

/**
 * Which lots `quantity` units come from, oldest first (M5 brief 4.2). The app
 * has the same function; both reproduce
 * `contracts/fixtures/stock-fifo-cases.json` (F2). Lots after `agedOnOrBefore`
 * do not count when given.
 */
export function assignLots(
  lots: readonly FifoLot[],
  quantity: number,
  agedOnOrBefore?: string | null,
): FifoResult {
  const open = lots
    .filter((l) => l.left > 0)
    .filter((l) => agedOnOrBefore == null || l.producedOn <= agedOnOrBefore)
    .sort(
      (a, b) =>
        a.producedOn.localeCompare(b.producedOn) || a.id.localeCompare(b.id),
    );
  const takes: FifoResult['takes'] = [];
  let rest = quantity;
  for (const l of open) {
    if (rest === 0) break;
    const take = Math.min(l.left, rest);
    takes.push({ lotId: l.id, quantity: take });
    rest -= take;
  }
  return { takes, unassigned: rest };
}

/** Day-old price from the full price (M5 brief 2). */
export function dayOldPrice(fullCents: number, discountBp: number): number {
  return divRoundHalfUp(fullCents * (10000 - discountBp), 10000);
}

/** The calendar day `days` before a YYYY-MM-DD day. */
export function daysBefore(day: string, days: number): string {
  const d = new Date(`${day}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() - days);
  return d.toISOString().slice(0, 10);
}

/** Whole calendar days from `from` to `to`, both YYYY-MM-DD. */
export function daysBetween(from: string, to: string): number {
  return Math.round(
    (Date.parse(`${to}T00:00:00Z`) - Date.parse(`${from}T00:00:00Z`)) /
      86_400_000,
  );
}
