import { PrismaClient } from '@prisma/client';
import { PERMISSION_KEYS, ROLE_PERMISSIONS } from '../src/common/permissions';

// Runs after `prisma migrate deploy` and before any seed, so it proves the
// migration alone gives every environment (production included) the matrix.
describe('Permission matrix in the database (e2e)', () => {
  const prisma = new PrismaClient();

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('has exactly the 26 contract permission keys', async () => {
    const rows = await prisma.permission.findMany({ select: { key: true } });
    expect(rows.map((r) => r.key).sort()).toEqual([...PERMISSION_KEYS].sort());
  });

  it('has exactly the approved role_permission rows', async () => {
    const rows = await prisma.rolePermission.findMany();
    const actual = rows.map((r) => `${r.role}:${r.permissionKey}`).sort();
    const expected = Object.entries(ROLE_PERMISSIONS)
      .flatMap(([role, keys]) => keys.map((key) => `${role}:${key}`))
      .sort();
    expect(actual).toEqual(expected);
  });
});
