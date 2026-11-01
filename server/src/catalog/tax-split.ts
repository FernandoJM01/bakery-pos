export interface TaxSplit {
  baseCents: number;
  iepsCents: number;
  ivaCents: number;
}

/** Integer division rounded half up, for non-negative operands. */
export function divRoundHalfUp(numerator: number, denominator: number): number {
  return Math.floor((2 * numerator + denominator) / (2 * denominator));
}

/**
 * Splits a tax-included price into base, IEPS and IVA (M2 brief 4.1).
 * IEPS applies to the base and IVA to the base plus IEPS, so we work back
 * from the price. The three parts always add up to the price.
 */
export function splitTax(
  priceCents: number,
  ivaBp: number,
  iepsBp: number,
): TaxSplit {
  const beforeIva = divRoundHalfUp(priceCents * 10000, 10000 + ivaBp);
  const baseCents = divRoundHalfUp(beforeIva * 10000, 10000 + iepsBp);
  return {
    baseCents,
    iepsCents: beforeIva - baseCents,
    ivaCents: priceCents - beforeIva,
  };
}
