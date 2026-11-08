import { divRoundHalfUp } from '../catalog/tax-split';

/**
 * What baking a dish costs (M8, decided 8 Nov 2026): a base per dish type
 * plus a price per kilo, rounded half up to the centavo. The app has the
 * same function.
 */
export function ovenFee(
  baseCents: number,
  perKgCents: number,
  weightGrams: number,
): number {
  return baseCents + divRoundHalfUp(perKgCents * weightGrams, 1000);
}
