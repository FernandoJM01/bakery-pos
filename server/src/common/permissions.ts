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

export const PERMISSION_DEFINITIONS: Record<PermissionKey, string> = {
  'sale.create': 'Create sales and process customer transactions',
  'sale.void_line_before_payment': 'Void items in active sale before payment',
  'sale.void_after_payment': 'Void sale after payment completed',
  'sale.refund': 'Issue refunds for returned goods',
  'sale.discount_within_limit': 'Apply standard discounts within cashier limit',
  'sale.discount_over_limit':
    'Apply manager-level discounts exceeding normal limits',
  'cash.open_shift': 'Open cash register shift and record opening balance',
  'cash.close_shift': 'Close cash register shift and record count',
  'cash.movement': 'Perform cash drops or additions',
  'cash.open_drawer_no_sale': 'Open cash drawer without transaction',
  'stock.production_entry': 'Register baked goods from production ovens',
  'stock.waste': 'Record damaged or unsold discarded products',
  'stock.count_adjust': 'Perform inventory count adjustments',
  'stock.transfer': 'Transfer stock between branches',
  'orders.manage': 'Manage standing and advance cake/bread orders',
  'orders.pickup': 'Process order pickups and finalize payment',
  'oven.intake_pickup': 'Check in customer baking requests and record pickup',
  'oven.board': 'View baking board and production queue',
  'catalog.manage': 'Manage products, prices, and categories',
  'staff.manage': 'Create, edit, and deactivate staff members',
  'devices.manage': 'Enroll, list, and revoke POS till and production devices',
  'branches.manage': 'Create and manage bakery branches',
  'reports.branch': 'View branch-level sales and cash reports',
  'reports.all': 'View consolidated cross-branch enterprise reports',
  'audit.view': 'View tamper-evident security audit logs',
  'settings.manage': 'Configure store and system operational settings',
};

export const ROLE_PERMISSIONS: Record<
  'OWNER' | 'BRANCH_MANAGER' | 'CASHIER' | 'BAKER',
  readonly PermissionKey[]
> = {
  OWNER: PERMISSION_KEYS,
  BRANCH_MANAGER: [
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
    'reports.branch',
  ],
  CASHIER: [
    'sale.create',
    'sale.void_line_before_payment',
    'sale.discount_within_limit',
    'cash.open_shift',
    'cash.close_shift',
    'orders.pickup',
    'oven.intake_pickup',
  ],
  BAKER: ['stock.production_entry', 'stock.waste', 'oven.board'],
};
