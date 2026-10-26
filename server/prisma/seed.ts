import { PrismaClient, ProductUnit, Role } from '@prisma/client';
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

  // 5. Seed Catalog (Categories, Products, Variants, and Branch Prices)
  console.log('Seeding catalog (3 categories, 10 products)...');
  await prisma.branchPrice.deleteMany();
  await prisma.productVariant.deleteMany();
  await prisma.product.deleteMany();
  await prisma.category.deleteMany();

  const iva0 = await prisma.taxRate.findFirstOrThrow({ where: { name: 'IVA 0%' } });
  const iva16 = await prisma.taxRate.findFirstOrThrow({ where: { name: 'IVA 16%' } });
  const ieps8 = await prisma.taxRate.findFirstOrThrow({ where: { name: 'IEPS 8%' } });

  // Category 1: Pan Dulce
  const catPanDulce = await prisma.category.create({
    data: {
      id: uuidv7(),
      name: 'Pan Dulce',
      sortOrder: 10,
      color: '#D97706',
      isActive: true,
    },
  });

  // Category 2: Pan Tradicional y Salado
  const catPanSalado = await prisma.category.create({
    data: {
      id: uuidv7(),
      name: 'Pan Tradicional y Salado',
      sortOrder: 20,
      color: '#B45309',
      isActive: true,
    },
  });

  // Category 3: Pastelería y Repostería
  const catPasteleria = await prisma.category.create({
    data: {
      id: uuidv7(),
      name: 'Pastelería y Repostería',
      sortOrder: 30,
      color: '#7C3AED',
      isActive: true,
    },
  });

  // 1. Concha (Pan Dulce)
  await prisma.product.create({
    data: {
      id: uuidv7(),
      categoryId: catPanDulce.id,
      name: 'Concha',
      description: 'Pan dulce tradicional mexicano con pasta crujiente',
      unit: ProductUnit.PIECE,
      ivaRateId: iva16.id,
      iepsRateId: ieps8.id,
      sortOrder: 10,
      isActive: true,
      variants: {
        create: [
          {
            id: uuidv7(),
            name: 'Concha de Vainilla',
            sku: 'PAN-CON-VAI',
            barcode: '750100010001',
            priceCents: 1200,
            sortOrder: 10,
            isActive: true,
          },
          {
            id: uuidv7(),
            name: 'Concha de Chocolate',
            sku: 'PAN-CON-CHO',
            barcode: '750100010002',
            priceCents: 1200,
            sortOrder: 20,
            isActive: true,
          },
        ],
      },
    },
  });

  // 2. Cuerno (Pan Dulce)
  await prisma.product.create({
    data: {
      id: uuidv7(),
      categoryId: catPanDulce.id,
      name: 'Cuerno',
      description: 'Hojaldre esponjoso con mantequilla',
      unit: ProductUnit.PIECE,
      ivaRateId: iva16.id,
      iepsRateId: ieps8.id,
      sortOrder: 20,
      isActive: true,
      variants: {
        create: [
          {
            id: uuidv7(),
            name: 'Cuerno Tradicional',
            sku: 'PAN-CUE-TRA',
            barcode: '750100010003',
            priceCents: 1400,
            sortOrder: 10,
            isActive: true,
          },
        ],
      },
    },
  });

  // 3. Oreja (Pan Dulce)
  await prisma.product.create({
    data: {
      id: uuidv7(),
      categoryId: catPanDulce.id,
      name: 'Oreja',
      description: 'Hojaldre crujiente caramelizado con azúcar',
      unit: ProductUnit.PIECE,
      ivaRateId: iva16.id,
      iepsRateId: ieps8.id,
      sortOrder: 30,
      isActive: true,
      variants: {
        create: [
          {
            id: uuidv7(),
            name: 'Oreja Clásica',
            sku: 'PAN-ORE-CLA',
            barcode: '750100010004',
            priceCents: 1300,
            sortOrder: 10,
            isActive: true,
          },
        ],
      },
    },
  });

  // 4. Dona (Pan Dulce)
  await prisma.product.create({
    data: {
      id: uuidv7(),
      categoryId: catPanDulce.id,
      name: 'Dona',
      description: 'Dona suave esponjada',
      unit: ProductUnit.PIECE,
      ivaRateId: iva16.id,
      iepsRateId: ieps8.id,
      sortOrder: 40,
      isActive: true,
      variants: {
        create: [
          {
            id: uuidv7(),
            name: 'Dona de Azúcar',
            sku: 'PAN-DON-AZU',
            barcode: '750100010005',
            priceCents: 1500,
            sortOrder: 10,
            isActive: true,
          },
          {
            id: uuidv7(),
            name: 'Dona de Chocolate',
            sku: 'PAN-DON-CHO',
            barcode: '750100010006',
            priceCents: 1600,
            sortOrder: 20,
            isActive: true,
          },
        ],
      },
    },
  });

  // 5. Bolillo (Pan Salado) - with SUC2 branch price override
  const bolilloVariantId = uuidv7();
  await prisma.product.create({
    data: {
      id: uuidv7(),
      categoryId: catPanSalado.id,
      name: 'Bolillo',
      description: 'Bolillo crujiente tradicional recién horneado',
      unit: ProductUnit.PIECE,
      ivaRateId: iva0.id,
      iepsRateId: null,
      sortOrder: 10,
      isActive: true,
      variants: {
        create: [
          {
            id: bolilloVariantId,
            name: 'Bolillo Tradicional',
            sku: 'PAN-BOL-TRA',
            barcode: '750100020001',
            priceCents: 350,
            sortOrder: 10,
            isActive: true,
          },
        ],
      },
    },
  });

  await prisma.branchPrice.create({
    data: {
      variantId: bolilloVariantId,
      branchId: suc2.id,
      priceCents: 400,
    },
  });

  // 6. Telera (Pan Salado)
  await prisma.product.create({
    data: {
      id: uuidv7(),
      categoryId: catPanSalado.id,
      name: 'Telera',
      description: 'Pan suave ideal para tortas',
      unit: ProductUnit.PIECE,
      ivaRateId: iva0.id,
      iepsRateId: null,
      sortOrder: 20,
      isActive: true,
      variants: {
        create: [
          {
            id: uuidv7(),
            name: 'Telera Tradicional',
            sku: 'PAN-TEL-TRA',
            barcode: '750100020002',
            priceCents: 350,
            sortOrder: 10,
            isActive: true,
          },
        ],
      },
    },
  });

  // 7. Baguette Rústica (Pan Salado)
  await prisma.product.create({
    data: {
      id: uuidv7(),
      categoryId: catPanSalado.id,
      name: 'Baguette Rústica',
      description: 'Baguette de corteza crujiente y miga aireada',
      unit: ProductUnit.PIECE,
      ivaRateId: iva0.id,
      iepsRateId: null,
      sortOrder: 30,
      isActive: true,
      variants: {
        create: [
          {
            id: uuidv7(),
            name: 'Baguette 250g',
            sku: 'PAN-BAG-250',
            barcode: '750100020003',
            priceCents: 2500,
            sortOrder: 10,
            isActive: true,
          },
        ],
      },
    },
  });

  // 8. Pastel de Tres Leches (Pastelería)
  await prisma.product.create({
    data: {
      id: uuidv7(),
      categoryId: catPasteleria.id,
      name: 'Pastel de Tres Leches',
      description: 'Bizcocho bañado en mezcla de tres leches con canela',
      unit: ProductUnit.PIECE,
      ivaRateId: iva16.id,
      iepsRateId: ieps8.id,
      sortOrder: 10,
      isActive: true,
      variants: {
        create: [
          {
            id: uuidv7(),
            name: 'Rebanada Individual',
            sku: 'PAS-3L-REB',
            barcode: '750100030001',
            priceCents: 4500,
            sortOrder: 10,
            isActive: true,
          },
          {
            id: uuidv7(),
            name: 'Pastel Entero Chico',
            sku: 'PAS-3L-CHI',
            barcode: '750100030002',
            priceCents: 28000,
            sortOrder: 20,
            isActive: true,
          },
        ],
      },
    },
  });

  // 9. Pay de Queso (Pastelería)
  await prisma.product.create({
    data: {
      id: uuidv7(),
      categoryId: catPasteleria.id,
      name: 'Pay de Queso',
      description: 'Pay horneado sobre base de galleta crujiente',
      unit: ProductUnit.PIECE,
      ivaRateId: iva16.id,
      iepsRateId: ieps8.id,
      sortOrder: 20,
      isActive: true,
      variants: {
        create: [
          {
            id: uuidv7(),
            name: 'Rebanada de Pay',
            sku: 'PAS-PAY-REB',
            barcode: '750100030003',
            priceCents: 4000,
            sortOrder: 10,
            isActive: true,
          },
        ],
      },
    },
  });

  // 10. Galletas Surtidas (Pastelería)
  await prisma.product.create({
    data: {
      id: uuidv7(),
      categoryId: catPasteleria.id,
      name: 'Galletas Surtidas',
      description: 'Paquete surtido de galletas de mantequilla finas',
      unit: ProductUnit.PACKAGE,
      ivaRateId: iva16.id,
      iepsRateId: ieps8.id,
      sortOrder: 30,
      isActive: true,
      variants: {
        create: [
          {
            id: uuidv7(),
            name: 'Paquete 500g',
            sku: 'PAS-GAL-500',
            barcode: '750100030004',
            priceCents: 6500,
            sortOrder: 10,
            isActive: true,
          },
        ],
      },
    },
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
