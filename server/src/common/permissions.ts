/** Permission keys from contracts/openapi.yaml (PermissionKey). */
export const PERMISSION_KEYS = [
  'sale.create',
  'sale.void_line_before_payment',
  'sale.void_after_payment',
  'sale.refund',
  'sale.discount_within_limit',
  'sale.discount_over_limit',
  'cash.open_shift',
  'cash.close_shift',
  'cash.movement',
  'cash.open_drawer_no_sale',
  'stock.production_entry',
  'stock.waste',
  'stock.count_adjust',
  'stock.transfer',
  'orders.manage',
  'orders.pickup',
  'oven.intake_pickup',
  'oven.board',
  'catalog.manage',
  'staff.manage',
  'devices.manage',
  'branches.manage',
  'reports.branch',
  'reports.all',
  'audit.view',
  'settings.manage',
] as const;

export type PermissionKey = (typeof PERMISSION_KEYS)[number];

/** Matches any logged-in staff member (contract: `x-permission: authenticated`). */
export const AUTHENTICATED = 'authenticated';

export type RoutePermission = PermissionKey | typeof AUTHENTICATED;
