import { Injectable } from '@nestjs/common';
import { Device, Prisma } from '@prisma/client';
import { formatCategory, formatTaxRate } from '../catalog/catalog-format';
import { ClockService } from '../common/clock.service';
import { PrismaService } from '../prisma/prisma.service';

type Row = { seq: bigint; list: keyof Lists; value: unknown };
interface Lists {
  taxRates: unknown[];
  categories: unknown[];
  products: unknown[];
  variants: unknown[];
  branchPrices: unknown[];
}

/**
 * The till's catalog download (M2 brief 4.2): every catalog row changed
 * after `since`, oldest change first. `limit` counts rows over all lists.
 *
 * Change numbers are handed out in commit order (the trigger takes an
 * advisory lock), so once a till has seen N it can never later find a row
 * below N, and "after since" is all it needs.
 */
@Injectable()
export class CatalogFeedService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
  ) {}

  async pull(device: Device, since: bigint, limit: number) {
    const after = { changeSeq: { gt: since } };
    const page = { orderBy: { changeSeq: 'asc' as const }, take: limit + 1 };
    // One snapshot for all five lists. Read separately, a tax rate committed
    // after its query ran could sit below a product committed before the
    // product query ran; the till would store the higher number and skip the
    // tax rate for good.
    const [taxRates, categories, products, variants, branchPrices] =
      await this.prisma.$transaction(
        [
          this.prisma.taxRate.findMany({ where: after, ...page }),
          this.prisma.category.findMany({ where: after, ...page }),
          this.prisma.product.findMany({ where: after, ...page }),
          this.prisma.productVariant.findMany({ where: after, ...page }),
          this.prisma.branchPrice.findMany({
            where: { ...after, branchId: device.branchId },
            ...page,
          }),
        ],
        { isolationLevel: Prisma.TransactionIsolationLevel.RepeatableRead },
      );

    const rows: Row[] = [
      ...taxRates.map((t) => row(t.changeSeq, 'taxRates', formatTaxRate(t))),
      ...categories.map((c) =>
        row(c.changeSeq, 'categories', formatCategory(c)),
      ),
      ...products.map((p) =>
        row(p.changeSeq, 'products', {
          id: p.id,
          categoryId: p.categoryId,
          name: p.name,
          unit: p.unit,
          photoId: p.photoId,
          ivaRateId: p.ivaRateId,
          iepsRateId: p.iepsRateId,
          dayOldDiscountAfterDays: p.dayOldDiscountAfterDays,
          dayOldDiscountBp: p.dayOldDiscountBp,
          dayOldWasteAfterDays: p.dayOldWasteAfterDays,
          sortOrder: p.sortOrder,
          isActive: p.isActive,
        }),
      ),
      ...variants.map((v) =>
        row(v.changeSeq, 'variants', {
          id: v.id,
          productId: v.productId,
          name: v.name,
          sku: v.sku,
          barcode: v.barcode,
          priceCents: v.priceCents,
          sortOrder: v.sortOrder,
          isActive: v.isActive,
        }),
      ),
      ...branchPrices.map((bp) =>
        row(bp.changeSeq, 'branchPrices', {
          variantId: bp.variantId,
          priceCents: bp.deletedAt ? null : bp.priceCents,
          removed: bp.deletedAt !== null,
        }),
      ),
    ].sort((a, b) => (a.seq < b.seq ? -1 : a.seq > b.seq ? 1 : 0));

    const taken = rows.slice(0, limit);
    const lists: Lists = {
      taxRates: [],
      categories: [],
      products: [],
      variants: [],
      branchPrices: [],
    };
    for (const r of taken) lists[r.list].push(r.value);
    const last = taken.at(-1);

    return {
      nextSince: Number(last ? last.seq : since),
      hasMore: rows.length > limit,
      serverTime: this.clock.now().toISOString(),
      ...lists,
    };
  }
}

function row(seq: bigint, list: keyof Lists, value: unknown): Row {
  return { seq, list, value };
}
