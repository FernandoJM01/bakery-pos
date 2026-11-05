import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { ClockService } from '../common/clock.service';
import { PrismaService } from '../prisma/prisma.service';
import { assertDayOldRule } from './catalog.service';
import { DayOldRuleSetDto } from './dto/rules.dto';

const RULE_FIELDS = [
  'dayOldDiscountAfterDays',
  'dayOldDiscountBp',
  'dayOldWasteAfterDays',
] as const;

const notFound = (what: string) =>
  new NotFoundException({ code: 'NOT_FOUND', message: `${what} not found` });

type RuleRow = Prisma.ProductGetPayload<{
  include: { category: { select: { name: true; sortOrder: true } } };
}>;

function formatRule(p: RuleRow) {
  return {
    productId: p.id,
    categoryId: p.categoryId,
    categoryName: p.category.name,
    productName: p.name,
    isActive: p.isActive,
    dayOldDiscountAfterDays: p.dayOldDiscountAfterDays,
    dayOldDiscountBp: p.dayOldDiscountBp,
    dayOldWasteAfterDays: p.dayOldWasteAfterDays,
  };
}

/**
 * Day-old rules for many products at once, and costs that branch managers
 * enter (M5 brief 2, decided 4 Nov 2026).
 */
@Injectable()
export class CatalogRulesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
  ) {}

  private async rules(where: Prisma.ProductWhereInput = {}) {
    const rows = await this.prisma.product.findMany({
      where,
      include: { category: { select: { name: true, sortOrder: true } } },
    });
    rows.sort(
      (a, b) =>
        a.category.sortOrder - b.category.sortOrder ||
        a.category.name.localeCompare(b.category.name) ||
        a.name.localeCompare(b.name),
    );
    return { items: rows.map(formatRule) };
  }

  listRules() {
    return this.rules();
  }

  async setRules(user: AuthenticatedUser, dto: DayOldRuleSetDto) {
    const rule = {
      dayOldDiscountAfterDays: dto.dayOldDiscountAfterDays,
      dayOldDiscountBp: dto.dayOldDiscountBp,
      dayOldWasteAfterDays: dto.dayOldWasteAfterDays,
    };
    assertDayOldRule(rule);
    const ids = [...new Set(dto.productIds)];
    await this.prisma.$transaction(async (tx) => {
      const products = await tx.product.findMany({
        where: { id: { in: ids } },
      });
      if (products.length !== ids.length) throw notFound('Product');
      const now = this.clock.now();
      for (const p of products) {
        const changes = Object.fromEntries(
          RULE_FIELDS.filter((f) => p[f] !== rule[f]).map((f) => [
            f,
            { old: p[f], new: rule[f] },
          ]),
        );
        if (Object.keys(changes).length === 0) continue;
        await tx.product.update({ where: { id: p.id }, data: rule });
        await tx.auditLog.create({
          data: {
            id: uuidv7(),
            occurredAt: now,
            action: 'catalog.product_updated',
            actorStaffId: user.staffId,
            entityType: 'product',
            entityId: p.id,
            data: { changes },
          },
        });
      }
    });
    return this.rules({ id: { in: ids } });
  }

  private costRow(
    v: Prisma.ProductVariantGetPayload<{
      include: { product: { include: { category: true } } };
    }>,
  ) {
    return {
      variantId: v.id,
      productName: v.product.name,
      variantName: v.name,
      categoryName: v.product.category.name,
      priceCents: v.priceCents,
      costCents: v.costCents,
    };
  }

  async listCosts() {
    const rows = await this.prisma.productVariant.findMany({
      where: { isActive: true, product: { isActive: true } },
      include: { product: { include: { category: true } } },
    });
    rows.sort(
      (a, b) =>
        a.product.category.sortOrder - b.product.category.sortOrder ||
        a.product.name.localeCompare(b.product.name) ||
        a.sortOrder - b.sortOrder,
    );
    return { items: rows.map((v) => this.costRow(v)) };
  }

  async setCost(
    user: AuthenticatedUser,
    variantId: string,
    costCents: number | null,
  ) {
    const v = await this.prisma.$transaction(async (tx) => {
      const before = await tx.productVariant.findUnique({
        where: { id: variantId },
      });
      if (!before) throw notFound('Variant');
      if (before.costCents !== costCents) {
        await tx.productVariant.update({
          where: { id: variantId },
          data: { costCents },
        });
        await tx.auditLog.create({
          data: {
            id: uuidv7(),
            occurredAt: this.clock.now(),
            action: 'catalog.cost_changed',
            actorStaffId: user.staffId,
            entityType: 'variant',
            entityId: variantId,
            data: { old: before.costCents, new: costCents },
          },
        });
      }
      return tx.productVariant.findUniqueOrThrow({
        where: { id: variantId },
        include: { product: { include: { category: true } } },
      });
    });
    return this.costRow(v);
  }
}
