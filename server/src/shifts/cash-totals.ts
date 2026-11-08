export interface ExpectedCashInput {
  floatCents: number;
  /** `amountCents` of each sale payment; change is already out of it. */
  saleAmountsCents: readonly number[];
  cashInCents: readonly number[];
  cashOutCents: readonly number[];
  refundsCents: readonly number[];
  /** Order prepayments taken in this shift (M6 brief 2). */
  prepaymentsCents?: readonly number[];
}

export interface CloseResult {
  expectedCents: number;
  varianceCents: number;
  flagged: boolean;
}

const sum = (xs: readonly number[]) => xs.reduce((a, b) => a + b, 0);

/**
 * Expected cash and the difference at close, M4 brief section 4.3, with
 * prepayments from M6. Sales and refunds paid from a balance are left out. The app
 * has the same function; both reproduce
 * `contracts/fixtures/shift-cash-cases.json` (E3).
 */
export function closeResult(
  input: ExpectedCashInput,
  countedCents: number,
  flagCents: number,
): CloseResult {
  const expectedCents =
    input.floatCents +
    sum(input.saleAmountsCents) +
    sum(input.prepaymentsCents ?? []) +
    sum(input.cashInCents) -
    sum(input.cashOutCents) -
    sum(input.refundsCents);
  const varianceCents = countedCents - expectedCents;
  return {
    expectedCents,
    varianceCents,
    flagged: Math.abs(varianceCents) > flagCents,
  };
}

/** What a count by denomination adds up to. */
export function countTotal(
  rows: readonly { denominationCents: number; quantity: number }[],
): number {
  return rows.reduce((a, r) => a + r.denominationCents * r.quantity, 0);
}
