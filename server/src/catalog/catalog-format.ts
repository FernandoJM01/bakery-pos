import {
  BranchPrice,
  Category,
  Prisma,
  Product,
  ProductVariant,
  TaxRate,
} from '@prisma/client';
import { ConflictException } from '@nestjs/common';

export type VariantWithPrices = ProductVariant & {
  branchPrices: BranchPrice[];
};
export type ProductWithVariants = Product & {
  variants: VariantWithPrices[];
};

/** Live branch overrides only; removed ones keep a row for the till feed. */
export const PRODUCT_INCLUDE = {
  variants: {
    orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
    include: { branchPrices: { where: { deletedAt: null } } },
  },
} satisfies Prisma.ProductInclude;

export function formatTaxRate(t: TaxRate) {
  return {
    id: t.id,
    kind: t.kind,
    name: t.name,
    rateBp: t.rateBp,
    isActive: t.isActive,
    updatedAt: t.updatedAt.toISOString(),
  };
}

export function formatCategory(c: Category) {
  return {
    id: c.id,
    name: c.name,
    sortOrder: c.sortOrder,
    color: c.color,
    isActive: c.isActive,
    updatedAt: c.updatedAt.toISOString(),
  };
}

export function formatBranchPrice(bp: BranchPrice) {
  return {
    variantId: bp.variantId,
    branchId: bp.branchId,
    priceCents: bp.priceCents,
    updatedAt: bp.updatedAt.toISOString(),
  };
}

export function formatVariant(v: VariantWithPrices) {
  return {
    id: v.id,
    productId: v.productId,
    name: v.name,
    sku: v.sku,
    barcode: v.barcode,
    priceCents: v.priceCents,
    sortOrder: v.sortOrder,
    isActive: v.isActive,
    updatedAt: v.updatedAt.toISOString(),
    branchPrices: v.branchPrices.map(formatBranchPrice),
  };
}

export function formatProduct(p: ProductWithVariants) {
  return {
    id: p.id,
    categoryId: p.categoryId,
    name: p.name,
    description: p.description,
    unit: p.unit,
    photoId: p.photoId,
    ivaRateId: p.ivaRateId,
    iepsRateId: p.iepsRateId,
    dayOldDiscountAfterDays: p.dayOldDiscountAfterDays,
    dayOldDiscountBp: p.dayOldDiscountBp,
    dayOldWasteAfterDays: p.dayOldWasteAfterDays,
    sortOrder: p.sortOrder,
    isActive: p.isActive,
    updatedAt: p.updatedAt.toISOString(),
    variants: p.variants.map(formatVariant),
  };
}

/**
 * Like withUniqueConflict, but names the column in `details.field` so the
 * back office can point at the SKU or barcode box (C2).
 */
export async function withFieldConflict<T>(write: () => Promise<T>) {
  try {
    return await write();
  } catch (e) {
    if (
      e instanceof Prisma.PrismaClientKnownRequestError &&
      e.code === 'P2002'
    ) {
      const target = JSON.stringify(e.meta?.target ?? '');
      const field = target.includes('barcode')
        ? 'barcode'
        : target.includes('sku')
          ? 'sku'
          : 'name';
      throw new ConflictException({
        code: 'CONFLICT',
        message: `${field} already in use`,
        details: { field },
      });
    }
    throw e;
  }
}

/** Old and new values of the fields a PATCH actually changed, for audit. */
export function changedFields(
  before: Record<string, unknown>,
  dto: Record<string, unknown>,
): Record<string, { old: unknown; new: unknown }> {
  const changes: Record<string, { old: unknown; new: unknown }> = {};
  for (const [key, value] of Object.entries(dto)) {
    if (value === undefined || before[key] === value) continue;
    changes[key] = { old: before[key] ?? null, new: value };
  }
  return changes;
}
