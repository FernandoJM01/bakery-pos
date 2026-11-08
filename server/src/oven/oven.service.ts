import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Device, OvenStatus, Prisma, TaxKind } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { ClockService } from '../common/clock.service';
import { localDay } from '../common/local-day';
import { PrismaService } from '../prisma/prisma.service';
import { OvenFeeRuleCreateDto, OvenFeeRuleUpdateDto } from './dto/oven.dto';

const SERVICE_CATEGORY = 'Servicio de horno';

const notFound = (what: string) =>
  new NotFoundException({ code: 'NOT_FOUND', message: `${what} not found` });

const RULE_INCLUDE = {
  variant: {
    include: {
      product: { include: { ivaRate: true, iepsRate: true } },
    },
  },
} satisfies Prisma.OvenFeeRuleInclude;

type RuleRow = Prisma.OvenFeeRuleGetPayload<{ include: typeof RULE_INCLUDE }>;

function formatRule(r: RuleRow) {
  const p = r.variant.product;
  return {
    id: r.id,
    name: r.name,
    baseCents: r.baseCents,
    perKgCents: r.perKgCents,
    isActive: r.isActive,
    sortOrder: r.sortOrder,
    variantId: r.variantId,
    productName: p.name,
    variantName: r.variant.name,
    ivaRateId: p.ivaRateId,
    ivaBp: p.ivaRate.rateBp,
    iepsRateId: p.iepsRateId,
    iepsBp: p.iepsRate?.rateBp ?? 0,
  };
}

export function formatOvenTicket(t: Prisma.OvenTicketGetPayload<object>) {
  const iso = (d: Date | null) => d?.toISOString() ?? null;
  return {
    id: t.id,
    branchId: t.branchId,
    tag: t.tag,
    customerName: t.customerName,
    phone: t.phone,
    description: t.description,
    ruleId: t.ruleId,
    weightGrams: t.weightGrams,
    feeCents: t.feeCents,
    requestedAt: t.requestedAt.toISOString(),
    status: t.status,
    receivedAt: t.receivedAt.toISOString(),
    inOvenAt: iso(t.inOvenAt),
    readyAt: iso(t.readyAt),
    pickedUpAt: iso(t.pickedUpAt),
    paid: t.feeSaleId != null,
  };
}

/** Oven service settings, the board feed and the back office list (M8). */
@Injectable()
export class OvenService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
  ) {}

  private audit(
    tx: Prisma.TransactionClient,
    user: AuthenticatedUser,
    action: string,
    entityType: string,
    entityId: string,
    data: Prisma.InputJsonValue,
  ) {
    return tx.auditLog.create({
      data: {
        id: uuidv7(),
        occurredAt: this.clock.now(),
        action,
        actorStaffId: user.staffId,
        entityType,
        entityId,
        data,
      },
    });
  }

  async listRules() {
    const rows = await this.prisma.ovenFeeRule.findMany({
      include: RULE_INCLUDE,
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
    });
    const branches = await this.prisma.branch.findMany({
      where: { isActive: true },
      orderBy: { name: 'asc' },
    });
    return {
      items: rows.map(formatRule),
      branches: branches.map((b) => ({
        branchId: b.id,
        name: b.name,
        enabled: b.ovenEnabled,
      })),
    };
  }

  /**
   * A dish type. Its fee is sold as a hidden service product, so receipts,
   * tax, shifts and the Z report treat it like any sale.
   */
  async createRule(user: AuthenticatedUser, dto: OvenFeeRuleCreateDto) {
    const id = uuidv7();
    await this.prisma.$transaction(async (tx) => {
      const rate = await tx.taxRate.findUnique({
        where: { id: dto.ivaRateId },
      });
      if (!rate || rate.kind !== TaxKind.IVA) {
        throw new BadRequestException({
          code: 'VALIDATION_FAILED',
          message: 'ivaRateId must be an IVA rate',
        });
      }
      const category =
        (await tx.category.findFirst({ where: { name: SERVICE_CATEGORY } })) ??
        (await tx.category.create({
          data: { id: uuidv7(), name: SERVICE_CATEGORY, isActive: false },
        }));
      // Inactive, so it never shows on the sale screen's grid.
      const product = await tx.product.create({
        data: {
          id: uuidv7(),
          categoryId: category.id,
          name: SERVICE_CATEGORY,
          unit: 'PIECE',
          ivaRateId: dto.ivaRateId,
          isActive: false,
        },
      });
      const variant = await tx.productVariant.create({
        data: {
          id: uuidv7(),
          productId: product.id,
          name: dto.name,
          priceCents: Math.max(dto.baseCents, 1),
        },
      });
      await tx.ovenFeeRule.create({
        data: {
          id,
          name: dto.name,
          baseCents: dto.baseCents,
          perKgCents: dto.perKgCents,
          variantId: variant.id,
          sortOrder: dto.sortOrder ?? 0,
        },
      });
      await this.audit(tx, user, 'oven.fee_changed', 'oven_fee_rule', id, {
        name: dto.name,
        baseCents: dto.baseCents,
        perKgCents: dto.perKgCents,
      });
    });
    return formatRule(
      await this.prisma.ovenFeeRule.findUniqueOrThrow({
        where: { id },
        include: RULE_INCLUDE,
      }),
    );
  }

  async updateRule(
    user: AuthenticatedUser,
    id: string,
    dto: OvenFeeRuleUpdateDto,
  ) {
    await this.prisma.$transaction(async (tx) => {
      const before = await tx.ovenFeeRule.findUnique({ where: { id } });
      if (!before) throw notFound('Oven fee rule');
      await tx.ovenFeeRule.update({ where: { id }, data: { ...dto } });
      if (dto.name !== undefined || dto.baseCents !== undefined) {
        await tx.productVariant.update({
          where: { id: before.variantId },
          data: {
            name: dto.name,
            priceCents:
              dto.baseCents === undefined
                ? undefined
                : Math.max(dto.baseCents, 1),
          },
        });
      }
      await this.audit(tx, user, 'oven.fee_changed', 'oven_fee_rule', id, {
        ...dto,
      });
    });
    return formatRule(
      await this.prisma.ovenFeeRule.findUniqueOrThrow({
        where: { id },
        include: RULE_INCLUDE,
      }),
    );
  }

  async setBranch(user: AuthenticatedUser, branchId: string, enabled: boolean) {
    const b = await this.prisma.$transaction(async (tx) => {
      const before = await tx.branch.findUnique({ where: { id: branchId } });
      if (!before) throw notFound('Branch');
      const row = await tx.branch.update({
        where: { id: branchId },
        data: { ovenEnabled: enabled },
      });
      await this.audit(tx, user, 'oven.branch_changed', 'branch', branchId, {
        enabled,
      });
      return row;
    });
    return { branchId: b.id, enabled: b.ovenEnabled };
  }

  /** What a till or the oven board needs, offline included (M8.2, M8.3). */
  async board(device: Device) {
    const branch = await this.prisma.branch.findUniqueOrThrow({
      where: { id: device.branchId },
    });
    const now = this.clock.now();
    const today = localDay(now, branch.timezone);
    const rules = await this.prisma.ovenFeeRule.findMany({
      where: { isActive: true },
      include: RULE_INCLUDE,
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
    });
    const open = await this.prisma.ovenTicket.findMany({
      where: {
        branchId: device.branchId,
        OR: [
          { status: { not: OvenStatus.PICKED_UP } },
          {
            pickedUpAt: {
              gte: new Date(now.getTime() - 36 * 3_600_000),
            },
          },
        ],
      },
      orderBy: [{ requestedAt: 'asc' }, { id: 'asc' }],
    });
    return {
      generatedAt: now.toISOString(),
      today,
      enabled: branch.ovenEnabled,
      rules: rules.map(formatRule),
      tickets: open
        .filter(
          (t) =>
            t.status !== OvenStatus.PICKED_UP ||
            localDay(t.pickedUpAt!, branch.timezone) === today,
        )
        .map(formatOvenTicket),
    };
  }

  async list(
    user: AuthenticatedUser,
    q: { branchId?: string; from: string; to: string },
  ) {
    const scope = user.permissions.includes('reports.all')
      ? null
      : user.branchIds;
    if (q.branchId && scope && !scope.includes(q.branchId)) {
      throw new ForbiddenException({
        code: 'PERMISSION_DENIED',
        message: 'You cannot see this branch',
      });
    }
    const branches = await this.prisma.branch.findMany({
      where: q.branchId
        ? { id: q.branchId }
        : scope
          ? { id: { in: scope } }
          : {},
    });
    const rows = await this.prisma.ovenTicket.findMany({
      where: {
        branchId: { in: branches.map((b) => b.id) },
        requestedAt: {
          gte: new Date(`${q.from}T00:00:00Z`),
          lt: new Date(
            new Date(`${q.to}T00:00:00Z`).getTime() + 2 * 86_400_000,
          ),
        },
      },
      orderBy: [{ requestedAt: 'asc' }, { id: 'asc' }],
    });
    const tz = new Map(branches.map((b) => [b.id, b.timezone]));
    return {
      branches: branches.map((b) => ({
        branchId: b.id,
        name: b.name,
        enabled: b.ovenEnabled,
      })),
      items: rows
        .filter((t) => {
          const day = localDay(t.requestedAt, tz.get(t.branchId)!);
          return day >= q.from && day <= q.to;
        })
        .map(formatOvenTicket),
    };
  }
}
