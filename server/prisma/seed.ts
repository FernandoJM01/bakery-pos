import { PrismaClient, Role } from '@prisma/client';
import { randomBytes, randomInt } from 'crypto';
import { v7 as uuidv7 } from 'uuid';
import { hashPassword, hashPin } from '../src/common/crypto';
import {
  PERMISSION_DEFINITIONS,
  PERMISSION_KEYS,
  ROLE_PERMISSIONS,
} from '../src/common/permissions';

const prisma = new PrismaClient();

function randomPin(): string {
  return randomInt(1000, 10000).toString();
}

function randomPassword(): string {
  // At least 12 characters, safe URL-safe base64
  return randomBytes(12).toString('base64url');
}

interface SeedStaffCredential {
  role: string;
  branch: string;
  name: string;
  email: string | null;
  password: string | null;
  pin: string;
}

async function main() {
  if (process.env.NODE_ENV === 'production') {
    throw new Error('Database seed cannot be run in production environment.');
  }

  console.log('Seeding Bakery POS database for development/staging...');

  // 1. Seed Permissions (all 26 keys)
  console.log(`Seeding ${PERMISSION_KEYS.length} permissions...`);
  for (const key of PERMISSION_KEYS) {
    await prisma.permission.upsert({
      where: { key },
      update: { description: PERMISSION_DEFINITIONS[key] },
      create: {
        key,
        description: PERMISSION_DEFINITIONS[key],
      },
    });
  }

  // 2. Seed Role-Permissions (from Section 6 matrix)
  console.log('Seeding role_permission matrix...');
  await prisma.rolePermission.deleteMany();
  const rolePermissionData = Object.entries(ROLE_PERMISSIONS).flatMap(
    ([role, keys]) =>
      keys.map((permissionKey) => ({
        role: role as Role,
        permissionKey,
      })),
  );
  await prisma.rolePermission.createMany({
    data: rolePermissionData,
  });

  // 3. Seed Branches (SUC1 and SUC2)
  console.log('Seeding branches SUC1 and SUC2...');
  const suc1 = await prisma.branch.upsert({
    where: { code: 'SUC1' },
    update: {
      name: 'Sucursal Centro',
      address: 'Av. Hidalgo 123, Centro',
      timezone: 'America/Mexico_City',
    },
    create: {
      id: uuidv7(),
      code: 'SUC1',
      name: 'Sucursal Centro',
      address: 'Av. Hidalgo 123, Centro',
      timezone: 'America/Mexico_City',
      isActive: true,
    },
  });

  const suc2 = await prisma.branch.upsert({
    where: { code: 'SUC2' },
    update: {
      name: 'Sucursal Norte',
      address: 'Blvd. Norte 456, Norte',
      timezone: 'America/Mexico_City',
    },
    create: {
      id: uuidv7(),
      code: 'SUC2',
      name: 'Sucursal Norte',
      address: 'Blvd. Norte 456, Norte',
      timezone: 'America/Mexico_City',
      isActive: true,
    },
  });

  // 4. Seed Staff: Clean existing test staff and sessions. Staff referenced by
  // audit rows cannot be deleted (audit history is immutable), so a used
  // database must be reset instead.
  if ((await prisma.auditLog.count()) > 0) {
    throw new Error(
      'audit_log has rows, so seeded staff cannot be replaced. Reset the dev database with `npx prisma migrate reset` (it re-runs the seed).',
    );
  }
  console.log('Seeding staff and credentials...');
  await prisma.authSession.deleteMany();
  await prisma.staffBranch.deleteMany();
  await prisma.staff.deleteMany();

  const credentials: SeedStaffCredential[] = [];

  // Helper to create staff member with hashed credentials
  async function createStaff(params: {
    fullName: string;
    displayName: string;
    role: Role;
    email?: string;
    rawPassword?: string;
    rawPin: string;
    branchIds: string[];
    branchLabel: string;
  }) {
    const { pinHash, offlinePinVerifier } = await hashPin(params.rawPin);
    const passwordHash = params.rawPassword
      ? await hashPassword(params.rawPassword)
      : null;

    const staffId = uuidv7();
    await prisma.staff.create({
      data: {
        id: staffId,
        fullName: params.fullName,
        displayName: params.displayName,
        role: params.role,
        email: params.email ?? null,
        passwordHash,
        pinHash,
        offlinePinVerifier,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: {
          create: params.branchIds.map((branchId) => ({ branchId })),
        },
      },
    });

    credentials.push({
      role: params.role,
      branch: params.branchLabel,
      name: params.displayName,
      email: params.email ?? '-',
      password: params.rawPassword ?? '-',
      pin: params.rawPin,
    });
  }

  // Owner (access to all branches)
  await createStaff({
    fullName: 'Fernando Propietario',
    displayName: 'Fernando (Owner)',
    role: Role.OWNER,
    email: 'owner@bakery.local',
    rawPassword: randomPassword(),
    rawPin: randomPin(),
    branchIds: [suc1.id, suc2.id],
    branchLabel: 'ALL (SUC1, SUC2)',
  });

  // SUC1 Staff: 1 Manager, 2 Cashiers, 1 Baker
  await createStaff({
    fullName: 'Gerente Centro',
    displayName: 'Gerente Centro',
    role: Role.BRANCH_MANAGER,
    email: 'manager.suc1@bakery.local',
    rawPassword: randomPassword(),
    rawPin: randomPin(),
    branchIds: [suc1.id],
    branchLabel: 'SUC1',
  });

  await createStaff({
    fullName: 'Cajero Centro 1',
    displayName: 'Cajero C1',
    role: Role.CASHIER,
    rawPin: randomPin(),
    branchIds: [suc1.id],
    branchLabel: 'SUC1',
  });

  await createStaff({
    fullName: 'Cajero Centro 2',
    displayName: 'Cajero C2',
    role: Role.CASHIER,
    rawPin: randomPin(),
    branchIds: [suc1.id],
    branchLabel: 'SUC1',
  });

  await createStaff({
    fullName: 'Panadero Centro',
    displayName: 'Panadero Centro',
    role: Role.BAKER,
    rawPin: randomPin(),
    branchIds: [suc1.id],
    branchLabel: 'SUC1',
  });

  // SUC2 Staff: 1 Manager, 2 Cashiers, 1 Baker
  await createStaff({
    fullName: 'Gerente Norte',
    displayName: 'Gerente Norte',
    role: Role.BRANCH_MANAGER,
    email: 'manager.suc2@bakery.local',
    rawPassword: randomPassword(),
    rawPin: randomPin(),
    branchIds: [suc2.id],
    branchLabel: 'SUC2',
  });

  await createStaff({
    fullName: 'Cajero Norte 1',
    displayName: 'Cajero N1',
    role: Role.CASHIER,
    rawPin: randomPin(),
    branchIds: [suc2.id],
    branchLabel: 'SUC2',
  });

  await createStaff({
    fullName: 'Cajero Norte 2',
    displayName: 'Cajero N2',
    role: Role.CASHIER,
    rawPin: randomPin(),
    branchIds: [suc2.id],
    branchLabel: 'SUC2',
  });

  await createStaff({
    fullName: 'Panadero Norte',
    displayName: 'Panadero Norte',
    role: Role.BAKER,
    rawPin: randomPin(),
    branchIds: [suc2.id],
    branchLabel: 'SUC2',
  });

  console.log('\n======================================================');
  console.log('  SEEDED STAFF CREDENTIALS (SHOWN ONCE)');
  console.log('======================================================');
  console.table(credentials);
  console.log('======================================================\n');
}

main()
  .catch((err) => {
    console.error('Seed error:', err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
