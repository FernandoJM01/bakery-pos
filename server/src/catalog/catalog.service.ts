import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, TaxKind } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { ClockService } from '../common/clock.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  PRODUCT_INCLUDE,
  changedFields,
  formatBranchPrice,
  formatCategory,
  formatProduct,
  formatTaxRate,
  formatVariant,
  withFieldConflict,
} from './catalog-format';
import {
  CreateCategoryDto,
  CreateProductDto,
  CreateTaxRateDto,
  CreateVariantDto,
  ListProductsQueryDto,
  UpdateCategoryDto,
  UpdateProductDto,
  UpdateTaxRateDto,
  UpdateVariantDto,
} from './dto/catalog.dto';

type Tx = Prisma.TransactionClient;

function notFound(what: string): NotFoundException {
  return new NotFoundException({
    code: 'NOT_FOUND',
    message: `${what} not found`,
  });
}

function invalid(message: string): BadRequestException {
  return new BadRequestException({ code: 'VALIDATION_FAILED', message });
}

function conflict(message: string): ConflictException {
  return new ConflictException({ code: 'CONFLICT', message });
}

interface DayOld {
  dayOldDiscountAfterDays: number | null;
  dayOldDiscountBp: number | null;
  dayOldWasteAfterDays: number | null;
}

/** Same rules as the database checks, reported as 400 rather than 500 (C7). */
export function assertDayOldRule(d: DayOld): void {
  if ((d.dayOldDiscountAfterDays === null) !== (d.dayOldDiscountBp === null)) {
    throw invalid('Day-old discount days and percentage go together');
  }
  if (
    d.dayOldWasteAfterDays !== null &&
    d.dayOldDiscountAfterDays !== null &&
    d.dayOldWasteAfterDays <= d.dayOldDiscountAfterDays
  ) {
    throw invalid('Day-old waste days must be after the discount days');
  }
}

@Injectable()
export class CatalogService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
  ) {}

  private async audit(
    tx: Tx,
    user: AuthenticatedUser,
    action: string,
    entityType: string,
    entityId: string,
    data: Record<string, unknown>,
  ): Promise<void> {
    await tx.auditLog.create({
      data: {
        id: uuidv7(),
        occurredAt: this.clock.now(),
        action,
        actorStaffId: user.staffId,
        entityType,
        entityId,
        data: data as Prisma.InputJsonValue,
      },
    });
  }

  // ── Tax rates ──────────────────────────────────────────────────────────

  async listTaxRates(includeInactive = false) {
    const rates = await this.prisma.taxRate.findMany({
      where: includeInactive ? undefined : { isActive: true },
      orderBy: [{ kind: 'asc' }, { rateBp: 'asc' }, { name: 'asc' }],
    });
    return rates.map(formatTaxRate);
  }

  async createTaxRate(user: AuthenticatedUser, dto: CreateTaxRateDto) {
    const rate = await this.prisma.$transaction(async (tx) => {
      const r = await tx.taxRate.create({
        data: {
          id: uuidv7(),
          kind: dto.kind,
          name: dto.name,
          rateBp: dto.rateBp,
        },
      });
      await this.audit(tx, user, 'catalog.tax_rate_created', 'tax_rate', r.id, {
        kind: r.kind,
        name: r.name,
        rateBp: r.rateBp,
      });
      return r;
    });
    return formatTaxRate(rate);
  }

  async updateTaxRate(
    user: AuthenticatedUser,
    id: string,
    dto: UpdateTaxRateDto,
  ) {
    const rate = await this.prisma.$transaction(async (tx) => {
      const before = await tx.taxRate.findUnique({ where: { id } });
      if (!before) throw notFound('Tax rate');
      if (dto.isActive === false && before.isActive) {
        const inUse = await tx.product.count({
          where: {
            isActive: true,
            OR: [{ ivaRateId: id }, { iepsRateId: id }],
          },
        });
        if (inUse > 0) throw conflict('Tax rate is used by active products');
      }
      const changes = changedFields(before, { ...dto });
      if (Object.keys(changes).length === 0) return before;
      const r = await tx.taxRate.update({
        where: { id },
        data: { name: dto.name, isActive: dto.isActive },
      });
      await this.audit(tx, user, 'catalog.tax_rate_updated', 'tax_rate', id, {
        changes,
      });
      return r;
    });
    return formatTaxRate(rate);
  }

  // ── Categories ─────────────────────────────────────────────────────────

  async listCategories(includeInactive = false) {
    const categories = await this.prisma.category.findMany({
      where: includeInactive ? undefined : { isActive: true },
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
    });
    return categories.map(formatCategory);
  }

  async createCategory(user: AuthenticatedUser, dto: CreateCategoryDto) {
    const category = await withFieldConflict(() =>
      this.prisma.$transaction(async (tx) => {
        const c = await tx.category.create({
          data: {
            id: uuidv7(),
            name: dto.name,
            color: dto.color ?? null,
            sortOrder: dto.sortOrder ?? 0,
          },
        });
        await this.audit(
          tx,
          user,
          'catalog.category_created',
          'category',
          c.id,
          {
            name: c.name,
          },
        );
        return c;
      }),
    );
    return formatCategory(category);
  }

  async updateCategory(
    user: AuthenticatedUser,
    id: string,
    dto: UpdateCategoryDto,
  ) {
    const category = await withFieldConflict(() =>
      this.prisma.$transaction(async (tx) => {
        const before = await tx.category.findUnique({ where: { id } });
        if (!before) throw notFound('Category');
        const changes = changedFields(before, { ...dto });
        if (Object.keys(changes).length === 0) return before;
        const c = await tx.category.update({
          where: { id },
          data: {
            name: dto.name,
            color: dto.color,
            sortOrder: dto.sortOrder,
            isActive: dto.isActive,
          },
        });
        await this.audit(tx, user, 'catalog.category_updated', 'category', id, {
          changes,
        });
        return c;
      }),
    );
    return formatCategory(category);
  }

  // ── Products ───────────────────────────────────────────────────────────

  /**
   * Search is case and accent insensitive (`pan dulce` finds "Pan Dulce",
   * `concha` finds "Conchá"), over product name, variant name, SKU and
   * barcode. The cursor is an offset: the catalog is small and edited by
   * one owner, so keyset paging over the category join is not worth it.
   */
  async listProducts(query: ListProductsQueryDto) {
    const limit = query.limit ?? 50;
    const offset = decodeOffset(query.cursor);
    const conditions: Prisma.Sql[] = [Prisma.sql`TRUE`];
    if (!query.includeInactive) conditions.push(Prisma.sql`p.is_active`);
    if (query.categoryId) {
      conditions.push(Prisma.sql`p.category_id = ${query.categoryId}::uuid`);
    }
    const q = query.q?.trim();
    if (q) {
      const like = `%${q.replace(/[\\%_]/g, (ch) => `\\${ch}`)}%`;
      conditions.push(Prisma.sql`(
        unaccent(lower(p.name)) LIKE unaccent(lower(${like}))
        OR EXISTS (
          SELECT 1 FROM product_variant v
          WHERE v.product_id = p.id AND (
            unaccent(lower(v.name)) LIKE unaccent(lower(${like}))
            OR lower(v.sku) LIKE lower(${like})
            OR lower(v.barcode) LIKE lower(${like})
          )
        )
      )`);
    }
    const rows = await this.prisma.$queryRaw<{ id: string }[]>`
      SELECT p.id FROM product p JOIN category c ON c.id = p.category_id
      WHERE ${Prisma.join(conditions, ' AND ')}
      ORDER BY c.sort_order, c.name, p.sort_order, p.name, p.id
      LIMIT ${limit + 1} OFFSET ${offset}`;
    const pageIds = rows.slice(0, limit).map((r) => r.id);
    const products = await this.prisma.product.findMany({
      where: { id: { in: pageIds } },
      include: PRODUCT_INCLUDE,
    });
    const byId = new Map(products.map((p) => [p.id, p]));
    return {
      items: pageIds.map((id) => formatProduct(byId.get(id)!)),
      nextCursor: rows.length > limit ? encodeOffset(offset + limit) : null,
    };
  }

  async getProduct(id: string) {
    const product = await this.prisma.product.findUnique({
      where: { id },
      include: PRODUCT_INCLUDE,
    });
    if (!product) throw notFound('Product');
    return formatProduct(product);
  }

  /** Checks the references a product points at, inside the write's transaction. */
  private async assertReferences(
    tx: Tx,
    refs: {
      categoryId?: string;
      ivaRateId?: string;
      iepsRateId?: string | null;
      photoId?: string | null;
    },
  ): Promise<void> {
    if (refs.categoryId !== undefined) {
      const c = await tx.category.findUnique({
        where: { id: refs.categoryId },
      });
      if (!c) throw invalid('Category does not exist');
    }
    for (const [rateId, kind] of [
      [refs.ivaRateId, TaxKind.IVA],
      [refs.iepsRateId, TaxKind.IEPS],
    ] as const) {
      if (rateId === undefined || rateId === null) continue;
      const r = await tx.taxRate.findUnique({ where: { id: rateId } });
      if (!r || r.kind !== kind || !r.isActive) {
        throw invalid(`${kind} rate must be an active ${kind} tax rate`);
      }
    }
    if (refs.photoId) {
      const p = await tx.photo.findUnique({ where: { id: refs.photoId } });
      if (!p) throw invalid('Photo does not exist');
    }
  }

  async createProduct(user: AuthenticatedUser, dto: CreateProductDto) {
    const dayOld: DayOld = {
      dayOldDiscountAfterDays: dto.dayOldDiscountAfterDays ?? null,
      dayOldDiscountBp: dto.dayOldDiscountBp ?? null,
      dayOldWasteAfterDays: dto.dayOldWasteAfterDays ?? null,
    };
    assertDayOldRule(dayOld);
    const id = uuidv7();
    await withFieldConflict(() =>
      this.prisma.$transaction(async (tx) => {
        await this.assertReferences(tx, dto);
        await tx.product.create({
          data: {
            id,
            categoryId: dto.categoryId,
            name: dto.name,
            description: dto.description ?? null,
            unit: dto.unit,
            photoId: dto.photoId ?? null,
            ivaRateId: dto.ivaRateId,
            iepsRateId: dto.iepsRateId ?? null,
            ...dayOld,
            sortOrder: dto.sortOrder ?? 0,
            variants: {
              create: dto.variants.map((v, i) => ({
                id: uuidv7(),
                name: v.name,
                sku: v.sku ?? null,
                barcode: v.barcode ?? null,
                priceCents: v.priceCents,
                sortOrder: v.sortOrder ?? i,
              })),
            },
          },
        });
        await this.audit(tx, user, 'catalog.product_created', 'product', id, {
          name: dto.name,
          variants: dto.variants.map((v) => ({
            name: v.name,
            priceCents: v.priceCents,
          })),
        });
      }),
    );
    return this.getProduct(id);
  }

  async updateProduct(
    user: AuthenticatedUser,
    id: string,
    dto: UpdateProductDto,
  ) {
    await this.prisma.$transaction(async (tx) => {
      const before = await lockProduct(tx, id);
      const changes = changedFields(before, { ...dto });
      if (Object.keys(changes).length === 0) return;
      assertDayOldRule({
        dayOldDiscountAfterDays:
          dto.dayOldDiscountAfterDays !== undefined
            ? dto.dayOldDiscountAfterDays
            : before.dayOldDiscountAfterDays,
        dayOldDiscountBp:
          dto.dayOldDiscountBp !== undefined
            ? dto.dayOldDiscountBp
            : before.dayOldDiscountBp,
        dayOldWasteAfterDays:
          dto.dayOldWasteAfterDays !== undefined
            ? dto.dayOldWasteAfterDays
            : before.dayOldWasteAfterDays,
      });
      await this.assertReferences(tx, {
        categoryId: changes.categoryId ? dto.categoryId : undefined,
        ivaRateId: changes.ivaRateId ? dto.ivaRateId : undefined,
        iepsRateId: changes.iepsRateId ? dto.iepsRateId : undefined,
        photoId: changes.photoId ? dto.photoId : undefined,
      });
      if (dto.isActive === true && !before.isActive) {
        const active = await tx.productVariant.count({
          where: { productId: id, isActive: true },
        });
        if (active === 0) throw conflict('Product has no active variant');
      }
      await tx.product.update({ where: { id }, data: { ...dto } });
      await this.audit(tx, user, 'catalog.product_updated', 'product', id, {
        changes,
      });
    });
    return this.getProduct(id);
  }

  // ── Variants and branch prices ─────────────────────────────────────────

  async createVariant(
    user: AuthenticatedUser,
    productId: string,
    dto: CreateVariantDto,
  ) {
    const variant = await withFieldConflict(() =>
      this.prisma.$transaction(async (tx) => {
        await lockProduct(tx, productId);
        const v = await tx.productVariant.create({
          data: {
            id: uuidv7(),
            productId,
            name: dto.name,
            sku: dto.sku ?? null,
            barcode: dto.barcode ?? null,
            priceCents: dto.priceCents,
            sortOrder: dto.sortOrder ?? 0,
          },
          include: { branchPrices: true },
        });
        await this.audit(tx, user, 'catalog.variant_created', 'variant', v.id, {
          productId,
          name: v.name,
          priceCents: v.priceCents,
        });
        return v;
      }),
    );
    return formatVariant(variant);
  }

  async updateVariant(
    user: AuthenticatedUser,
    id: string,
    dto: UpdateVariantDto,
  ) {
    const variant = await withFieldConflict(() =>
      this.prisma.$transaction(async (tx) => {
        const found = await tx.productVariant.findUnique({ where: { id } });
        if (!found) throw notFound('Variant');
        const product = await lockProduct(tx, found.productId);
        // Re-read under the product lock so two edits cannot both pass the
        // last-active-variant check.
        const before = await tx.productVariant.findUniqueOrThrow({
          where: { id },
        });
        const changes = changedFields(before, { ...dto });
        if (dto.isActive === false && before.isActive && product.isActive) {
          const others = await tx.productVariant.count({
            where: { productId: product.id, isActive: true, id: { not: id } },
          });
          if (others === 0) {
            throw conflict('An active product keeps at least one variant');
          }
        }
        if (Object.keys(changes).length > 0) {
          await tx.productVariant.update({ where: { id }, data: { ...dto } });
        }
        const { priceCents, costCents, ...rest } = changes;
        if (costCents) {
          await this.audit(tx, user, 'catalog.cost_changed', 'variant', id, {
            old: costCents.old,
            new: costCents.new,
          });
        }
        if (priceCents) {
          await this.audit(tx, user, 'catalog.price_changed', 'variant', id, {
            old: priceCents.old,
            new: priceCents.new,
          });
        }
        if (Object.keys(rest).length > 0) {
          await this.audit(tx, user, 'catalog.variant_updated', 'variant', id, {
            changes: rest,
          });
        }
        return tx.productVariant.findUniqueOrThrow({
          where: { id },
          include: { branchPrices: { where: { deletedAt: null } } },
        });
      }),
    );
    return formatVariant(variant);
  }

  async setBranchPrice(
    user: AuthenticatedUser,
    variantId: string,
    branchId: string,
    priceCents: number,
  ) {
    const price = await this.prisma.$transaction(async (tx) => {
      const before = await this.findBranchPrice(tx, variantId, branchId);
      const live = before && !before.deletedAt ? before : null;
      const saved = await tx.branchPrice.upsert({
        where: { variantId_branchId: { variantId, branchId } },
        create: { variantId, branchId, priceCents },
        update: { priceCents, deletedAt: null },
      });
      if (live?.priceCents !== priceCents) {
        await this.audit(
          tx,
          user,
          'catalog.branch_price_changed',
          'variant',
          variantId,
          {
            branchId,
            old: live?.priceCents ?? null,
            new: priceCents,
          },
        );
      }
      return saved;
    });
    return formatBranchPrice(price);
  }

  /** Idempotent: removing an override that is not there still succeeds. */
  async removeBranchPrice(
    user: AuthenticatedUser,
    variantId: string,
    branchId: string,
  ): Promise<void> {
    await this.prisma.$transaction(async (tx) => {
      const before = await this.findBranchPrice(tx, variantId, branchId);
      if (!before || before.deletedAt) return;
      const removed = await tx.branchPrice.updateMany({
        where: { variantId, branchId, deletedAt: null },
        data: { deletedAt: this.clock.now() },
      });
      if (removed.count === 0) return;
      await this.audit(
        tx,
        user,
        'catalog.branch_price_changed',
        'variant',
        variantId,
        {
          branchId,
          old: before.priceCents,
          new: null,
        },
      );
    });
  }

  private async findBranchPrice(tx: Tx, variantId: string, branchId: string) {
    const [variant, branch] = await Promise.all([
      tx.productVariant.findUnique({ where: { id: variantId } }),
      tx.branch.findUnique({ where: { id: branchId } }),
    ]);
    if (!variant) throw notFound('Variant');
    if (!branch) throw notFound('Branch');
    return tx.branchPrice.findUnique({
      where: { variantId_branchId: { variantId, branchId } },
    });
  }
}

/** Locks the product row so variant changes on it run one at a time. */
async function lockProduct(tx: Tx, id: string) {
  const locked = await tx.$queryRaw<{ id: string }[]>`
    SELECT id FROM product WHERE id = ${id}::uuid FOR UPDATE`;
  if (locked.length === 0) throw notFound('Product');
  return tx.product.findUniqueOrThrow({ where: { id } });
}

function encodeOffset(offset: number): string {
  return Buffer.from(`o:${offset}`, 'utf8').toString('base64url');
}

function decodeOffset(cursor?: string): number {
  if (!cursor) return 0;
  const match = /^o:(\d{1,7})$/.exec(
    Buffer.from(cursor, 'base64url').toString('utf8'),
  );
  if (!match) throw invalid('Unreadable cursor');
  return Number(match[1]);
}
