/**
 * Sale rules the tills receive in the staff bundle (M3 brief 2). Fixed in
 * code for M3; an owner setting can replace them later.
 */
export const SALE_SETTINGS = {
  /** A cashier may give up to 10% off without a manager's PIN. */
  discountLimitBp: 1000,
} as const;
