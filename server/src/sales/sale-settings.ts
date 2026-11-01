/**
 * Sale rules the tills receive in the staff bundle (M3 brief 2). Fixed in
 * code for M3; an owner setting can replace them later.
 */
export const SALE_SETTINGS = {
  /** A cashier may give up to 10% off without a manager's PIN. */
  discountLimitBp: 1000,
  /** A close differing by more than $50.00 is flagged (M4 brief 2). */
  cashVarianceFlagCents: 5000,
} as const;
