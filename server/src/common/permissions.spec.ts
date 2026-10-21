import {
  PERMISSION_DEFINITIONS,
  PERMISSION_KEYS,
  ROLE_PERMISSIONS,
} from './permissions';

describe('Permissions & Role-Permission Matrix (Section 6)', () => {
  it('defines all 26 permission keys from the contract and brief', () => {
    expect(PERMISSION_KEYS.length).toBe(26);
    expect(new Set(PERMISSION_KEYS).size).toBe(26);
  });

  it('provides a description for every permission key', () => {
    for (const key of PERMISSION_KEYS) {
      expect(PERMISSION_DEFINITIONS[key]).toBeDefined();
      expect(PERMISSION_DEFINITIONS[key].length).toBeGreaterThan(0);
    }
  });

  it('matches the section 6 permission matrix for OWNER (all 26 permissions)', () => {
    expect(ROLE_PERMISSIONS.OWNER).toEqual(PERMISSION_KEYS);
    expect(ROLE_PERMISSIONS.OWNER.length).toBe(26);
  });

  it('matches the section 6 permission matrix for BRANCH_MANAGER (19 permissions)', () => {
    const expectedManagerPermissions = [
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
    ];

    expect(ROLE_PERMISSIONS.BRANCH_MANAGER.length).toBe(19);
    expect([...ROLE_PERMISSIONS.BRANCH_MANAGER].sort()).toEqual(
      [...expectedManagerPermissions].sort(),
    );
  });

  it('matches the section 6 permission matrix for CASHIER (7 permissions)', () => {
    const expectedCashierPermissions = [
      'sale.create',
      'sale.void_line_before_payment',
      'sale.discount_within_limit',
      'cash.open_shift',
      'cash.close_shift',
      'orders.pickup',
      'oven.intake_pickup',
    ];

    expect(ROLE_PERMISSIONS.CASHIER.length).toBe(7);
    expect([...ROLE_PERMISSIONS.CASHIER].sort()).toEqual(
      [...expectedCashierPermissions].sort(),
    );
  });

  it('matches the section 6 permission matrix for BAKER (3 permissions)', () => {
    const expectedBakerPermissions = [
      'stock.production_entry',
      'stock.waste',
      'oven.board',
    ];

    expect(ROLE_PERMISSIONS.BAKER.length).toBe(3);
    expect([...ROLE_PERMISSIONS.BAKER].sort()).toEqual(
      [...expectedBakerPermissions].sort(),
    );
  });

  it('contains only valid permission keys across all roles', () => {
    const validKeySet = new Set<string>(PERMISSION_KEYS);
    for (const [, perms] of Object.entries(ROLE_PERMISSIONS)) {
      for (const perm of perms) {
        expect(validKeySet.has(perm)).toBe(true);
      }
      expect(new Set(perms).size).toBe(perms.length); // no duplicates
    }
  });
});
