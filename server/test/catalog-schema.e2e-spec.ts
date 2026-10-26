import { PrismaClient, ProductUnit, TaxKind } from '@prisma/client';
import { randomBytes } from 'crypto';
import { v7 as uuidv7 } from 'uuid';

describe('Catalog Schema, Triggers, Constraints & Permissions (e2e)', () => {
  const prisma = new PrismaClient();

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('has the 3 placeholder tax rates seeded from migration (IVA 0%, IVA 16%, IEPS 8%)', async () => {
    const rates = await prisma.taxRate.findMany({
      orderBy: { rateBp: 'asc' },
    });

    const iva0 = rates.find((r) => r.name === 'IVA 0%');
    const iva16 = rates.find((r) => r.name === 'IVA 16%');
    const ieps8 = rates.find((r) => r.name === 'IEPS 8%');

    expect(iva0).toBeDefined();
    expect(iva0?.kind).toBe(TaxKind.IVA);
    expect(iva0?.rateBp).toBe(0);
    expect(iva0?.isActive).toBe(true);
    expect(iva0?.changeSeq).toBeGreaterThan(0n);

    expect(iva16).toBeDefined();
    expect(iva16?.kind).toBe(TaxKind.IVA);
    expect(iva16?.rateBp).toBe(1600);
    expect(iva16?.isActive).toBe(true);
    expect(iva16?.changeSeq).toBeGreaterThan(0n);

    expect(ieps8).toBeDefined();
    expect(ieps8?.kind).toBe(TaxKind.IEPS);
    expect(ieps8?.rateBp).toBe(800);
    expect(ieps8?.isActive).toBe(true);
    expect(ieps8?.changeSeq).toBeGreaterThan(0n);
  });

  it('increments catalog_change_seq automatically via trigger on insert and update across catalog tables', async () => {
    // 1. Create a category
    const cat = await prisma.category.create({
      data: {
        id: uuidv7(),
        name: `Seq-Test-Cat-${randomBytes(8).toString('hex')}`,
        sortOrder: 1,
      },
    });
    expect(cat.changeSeq).toBeGreaterThan(0n);

    // 2. Update category -> changeSeq must increase
    const updatedCat = await prisma.category.update({
      where: { id: cat.id },
      data: { color: '#ABCDEF' },
    });
    expect(updatedCat.changeSeq).toBeGreaterThan(cat.changeSeq);

    // 3. Create a product
    const iva16 = await prisma.taxRate.findFirstOrThrow({
      where: { name: 'IVA 16%' },
    });
    const prod = await prisma.product.create({
      data: {
        id: uuidv7(),
        categoryId: cat.id,
        name: `Seq-Test-Prod-${randomBytes(8).toString('hex')}`,
        unit: ProductUnit.PIECE,
        ivaRateId: iva16.id,
        sortOrder: 1,
      },
    });
    expect(prod.changeSeq).toBeGreaterThan(updatedCat.changeSeq);

    // 4. Update product -> changeSeq must increase
    const updatedProd = await prisma.product.update({
      where: { id: prod.id },
      data: { description: 'Updated description' },
    });
    expect(updatedProd.changeSeq).toBeGreaterThan(prod.changeSeq);

    // 5. Create a variant
    const variant = await prisma.productVariant.create({
      data: {
        id: uuidv7(),
        productId: prod.id,
        name: 'Seq-Test-Variant',
        priceCents: 1500,
        sortOrder: 1,
      },
    });
    expect(variant.changeSeq).toBeGreaterThan(updatedProd.changeSeq);

    // 6. Update variant -> changeSeq must increase
    const updatedVariant = await prisma.productVariant.update({
      where: { id: variant.id },
      data: { priceCents: 1800 },
    });
    expect(updatedVariant.changeSeq).toBeGreaterThan(variant.changeSeq);

    // 7. Create a branch price
    const branch = await prisma.branch.findFirstOrThrow();
    const branchPrice = await prisma.branchPrice.create({
      data: {
        variantId: variant.id,
        branchId: branch.id,
        priceCents: 2000,
      },
    });
    expect(branchPrice.changeSeq).toBeGreaterThan(updatedVariant.changeSeq);

    // 8. Update branch price (e.g. soft removal with deleted_at) -> changeSeq must increase
    const updatedBp = await prisma.branchPrice.update({
      where: {
        variantId_branchId: {
          variantId: variant.id,
          branchId: branch.id,
        },
      },
      data: { deletedAt: new Date() },
    });
    expect(updatedBp.changeSeq).toBeGreaterThan(branchPrice.changeSeq);
    expect(updatedBp.deletedAt).not.toBeNull();
  });

  it('enforces tax_rate rate_bp check (0..10000)', async () => {
    // Negative rateBp
    await expect(
      prisma.taxRate.create({
        data: {
          id: uuidv7(),
          kind: TaxKind.IVA,
          name: 'Invalid Negative Rate',
          rateBp: -100,
        },
      }),
    ).rejects.toThrow();

    // Over 10000 rateBp (> 100%)
    await expect(
      prisma.taxRate.create({
        data: {
          id: uuidv7(),
          kind: TaxKind.IVA,
          name: 'Invalid Huge Rate',
          rateBp: 10001,
        },
      }),
    ).rejects.toThrow();
  });

  it('enforces category name uniqueness among active categories only', async () => {
    const sharedName = `Unique-Active-Cat-${randomBytes(8).toString('hex')}`;

    // First active category succeeds
    const cat1 = await prisma.category.create({
      data: {
        id: uuidv7(),
        name: sharedName,
        isActive: true,
      },
    });

    // Duplicate active category fails
    await expect(
      prisma.category.create({
        data: {
          id: uuidv7(),
          name: sharedName,
          isActive: true,
        },
      }),
    ).rejects.toThrow();

    // Deactivate first category
    await prisma.category.update({
      where: { id: cat1.id },
      data: { isActive: false },
    });

    // Now a new active category with the same name succeeds
    const cat2 = await prisma.category.create({
      data: {
        id: uuidv7(),
        name: sharedName,
        isActive: true,
      },
    });
    expect(cat2.id).not.toBe(cat1.id);
    expect(cat2.name).toBe(sharedName);
  });

  it('enforces product_variant price_cents > 0 check', async () => {
    const cat = await prisma.category.findFirstOrThrow();
    const iva16 = await prisma.taxRate.findFirstOrThrow({
      where: { name: 'IVA 16%' },
    });
    const prod = await prisma.product.create({
      data: {
        id: uuidv7(),
        categoryId: cat.id,
        name: `Price-Check-Prod-${randomBytes(8).toString('hex')}`,
        unit: ProductUnit.PIECE,
        ivaRateId: iva16.id,
      },
    });

    // price_cents = 0 fails
    await expect(
      prisma.productVariant.create({
        data: {
          id: uuidv7(),
          productId: prod.id,
          name: 'Zero Price Variant',
          priceCents: 0,
        },
      }),
    ).rejects.toThrow();

    // price_cents < 0 fails
    await expect(
      prisma.productVariant.create({
        data: {
          id: uuidv7(),
          productId: prod.id,
          name: 'Negative Price Variant',
          priceCents: -500,
        },
      }),
    ).rejects.toThrow();
  });

  it('enforces product_variant sku and barcode uniqueness among variants', async () => {
    const cat = await prisma.category.findFirstOrThrow();
    const iva16 = await prisma.taxRate.findFirstOrThrow({
      where: { name: 'IVA 16%' },
    });
    const prod = await prisma.product.create({
      data: {
        id: uuidv7(),
        categoryId: cat.id,
        name: `Unique-Variant-Prod-${randomBytes(8).toString('hex')}`,
        unit: ProductUnit.PIECE,
        ivaRateId: iva16.id,
      },
    });

    const uniqueSku = `SKU-${randomBytes(8).toString('hex')}`;
    const uniqueBarcode = `BC-${randomBytes(8).toString('hex')}`;

    await prisma.productVariant.create({
      data: {
        id: uuidv7(),
        productId: prod.id,
        name: 'Variant 1',
        sku: uniqueSku,
        barcode: uniqueBarcode,
        priceCents: 1000,
      },
    });

    // Duplicate SKU
    await expect(
      prisma.productVariant.create({
        data: {
          id: uuidv7(),
          productId: prod.id,
          name: 'Variant Duplicate SKU',
          sku: uniqueSku,
          barcode: `BC-OTHER-${randomBytes(8).toString('hex')}`,
          priceCents: 1200,
        },
      }),
    ).rejects.toThrow();

    // Duplicate Barcode
    await expect(
      prisma.productVariant.create({
        data: {
          id: uuidv7(),
          productId: prod.id,
          name: 'Variant Duplicate Barcode',
          sku: `SKU-OTHER-${randomBytes(8).toString('hex')}`,
          barcode: uniqueBarcode,
          priceCents: 1200,
        },
      }),
    ).rejects.toThrow();
  });

  it('enforces branch_price price_cents > 0 check', async () => {
    const variant = await prisma.productVariant.findFirstOrThrow();
    const branch = await prisma.branch.findFirstOrThrow();

    // Raw query to test branch_price_price_cents_check
    await expect(
      prisma.$executeRaw`
        INSERT INTO "branch_price" ("variant_id", "branch_id", "price_cents", "created_at", "updated_at")
        VALUES (${variant.id}::uuid, ${branch.id}::uuid, 0, NOW(), NOW())
      `,
    ).rejects.toThrow();
  });

  it('enforces product day-old discount and waste constraints', async () => {
    const cat = await prisma.category.findFirstOrThrow();
    const iva16 = await prisma.taxRate.findFirstOrThrow({
      where: { name: 'IVA 16%' },
    });

    // discount days without percentage fails
    await expect(
      prisma.product.create({
        data: {
          id: uuidv7(),
          categoryId: cat.id,
          name: `DayOld-Invalid-1-${randomBytes(8).toString('hex')}`,
          unit: ProductUnit.PIECE,
          ivaRateId: iva16.id,
          dayOldDiscountAfterDays: 2,
          dayOldDiscountBp: null,
        },
      }),
    ).rejects.toThrow();

    // discount percentage without days fails
    await expect(
      prisma.product.create({
        data: {
          id: uuidv7(),
          categoryId: cat.id,
          name: `DayOld-Invalid-2-${randomBytes(8).toString('hex')}`,
          unit: ProductUnit.PIECE,
          ivaRateId: iva16.id,
          dayOldDiscountAfterDays: null,
          dayOldDiscountBp: 2000,
        },
      }),
    ).rejects.toThrow();

    // waste days <= discount days fails
    await expect(
      prisma.product.create({
        data: {
          id: uuidv7(),
          categoryId: cat.id,
          name: `DayOld-Invalid-3-${randomBytes(8).toString('hex')}`,
          unit: ProductUnit.PIECE,
          ivaRateId: iva16.id,
          dayOldDiscountAfterDays: 3,
          dayOldDiscountBp: 2000,
          dayOldWasteAfterDays: 3, // equal, must be >
        },
      }),
    ).rejects.toThrow();

    // Valid: both discount days and percentage set, and waste days > discount days
    const validProd = await prisma.product.create({
      data: {
        id: uuidv7(),
        categoryId: cat.id,
        name: `DayOld-Valid-${randomBytes(8).toString('hex')}`,
        unit: ProductUnit.PIECE,
        ivaRateId: iva16.id,
        dayOldDiscountAfterDays: 1,
        dayOldDiscountBp: 5000,
        dayOldWasteAfterDays: 2,
      },
    });
    expect(validProd.dayOldDiscountAfterDays).toBe(1);
    expect(validProd.dayOldWasteAfterDays).toBe(2);
  });

  it('enforces least-privilege: pos_app cannot DELETE catalog rows or alter audit_log', async () => {
    const cat = await prisma.category.findFirstOrThrow();

    // pos_app has no DELETE grant on catalog tables
    await expect(
      prisma.$executeRaw`DELETE FROM "category" WHERE "id" = ${cat.id}::uuid`,
    ).rejects.toThrow(/permission denied for table category/i);

    // pos_app has no UPDATE or DELETE on audit_log
    await expect(prisma.$executeRaw`DELETE FROM "audit_log"`).rejects.toThrow(
      /permission denied for table audit_log/i,
    );
  });
});
