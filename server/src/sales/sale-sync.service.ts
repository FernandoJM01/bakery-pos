import { Injectable } from '@nestjs/common';
import {
  Device,
  DeviceType,
  Prisma,
  RefundKind,
  SaleStatus,
  TaxKind,
} from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { splitTax } from '../catalog/tax-split';
import { ClockService } from '../common/clock.service';
import { PrismaService } from '../prisma/prisma.service';
import { SyncRecordDto } from '../sync/dto/sync.dto';
import {
  checkApprover,
  findStaff,
  holds,
  inBranch,
  isRejection,
  parsePayload,
  Plan,
  rejected,
  Rejection,
} from '../sync/sync-plan';
import {
  DiscountInputDto,
  SaleCompletedPayloadDto,
  SaleRefundedPayloadDto,
} from './dto/sale-sync.dto';
import { SALE_SETTINGS } from './sale-settings';
import {
  computeSaleTotals,
  overLimit,
  refundAmountCents,
  TotalsError,
} from './sale-totals';

const DAY_MS = 86_400_000;

/** The folio a till writes: `<prefix>-<number, 6 digits>`. */
export function folioFor(prefix: string, folioNumber: number): string {
  return `${prefix}-${String(folioNumber).padStart(6, '0')}`;
}

/** Calendar day (YYYY-MM-DD) of an instant in a time zone. */
export function localDay(at: Date, timeZone: string): string {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(at);
}

/**
 * Sync handlers for sales made on a till (M3 brief 4.5). The till is the
 * source of the sale; the server checks every rule again and stores it.
 */
@Injectable()
export class SaleSyncService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
  ) {}

  async planCompleted(device: Device, record: SyncRecordDto): Promise<Plan> {
    const parsed = parsePayload(SaleCompletedPayloadDto, record.payload);
    if (isRejection(parsed)) return parsed;
    const p = parsed.value;
    const saleId = record.id;
    const occurredAt = new Date(record.occurredAt);

    if (occurredAt.getTime() > this.clock.now().getTime() + DAY_MS) {
      return rejected('occurredAt is more than a day in the future');
    }
    if (device.type !== DeviceType.TILL || !device.folioPrefix) {
      return rejected('Only a sales till can record sales');
    }

    // Folio: this till's prefix, a number it has not used.
    if (p.folio !== folioFor(device.folioPrefix, p.folioNumber)) {
      return rejected(
        `Folio ${p.folio} does not match this till (${device.folioPrefix}) and number ${p.folioNumber}`,
      );
    }
    const used = await this.prisma.sale.findFirst({
      where: {
        OR: [
          { deviceId: device.id, folioNumber: p.folioNumber },
          { folio: p.folio },
        ],
      },
      select: { id: true },
    });
    if (used) return rejected(`Folio ${p.folio} was already used`);

    const cashier = await findStaff(this.prisma, p.cashierStaffId);
    if (!cashier) return rejected('Unknown cashierStaffId');
    if (!inBranch(cashier, device.branchId)) {
      return rejected('Cashier is not assigned to this branch');
    }
    if (!(await holds(this.prisma, cashier, 'sale.create'))) {
      return rejected('Cashier lacks permission sale.create');
    }

    // Lines: numbered once each, known variants, the tax rates they claim.
    const lineNos = new Set(p.lines.map((l) => l.lineNo));
    if (lineNos.size !== p.lines.length) {
      return rejected('Line numbers repeat');
    }
    const variantIds = [
      ...new Set([
        ...p.lines.map((l) => l.variantId),
        ...p.voidedLines.map((v) => v.variantId),
      ]),
    ];
    const variants = await this.prisma.productVariant.count({
      where: { id: { in: variantIds } },
    });
    if (variants !== variantIds.length) return rejected('Unknown variantId');

    const rateIds = [
      ...new Set(
        p.lines.flatMap((l) =>
          l.iepsRateId ? [l.ivaRateId, l.iepsRateId] : [l.ivaRateId],
        ),
      ),
    ];
    const rates = new Map(
      (
        await this.prisma.taxRate.findMany({ where: { id: { in: rateIds } } })
      ).map((r) => [r.id, r]),
    );
    for (const l of p.lines) {
      const iva = rates.get(l.ivaRateId);
      if (!iva || iva.kind !== TaxKind.IVA || iva.rateBp !== l.ivaBp) {
        return rejected(`Line ${l.lineNo}: IVA rate does not match`);
      }
      if (l.iepsRateId) {
        const ieps = rates.get(l.iepsRateId);
        if (!ieps || ieps.kind !== TaxKind.IEPS || ieps.rateBp !== l.iepsBp) {
          return rejected(`Line ${l.lineNo}: IEPS rate does not match`);
        }
      } else if (l.iepsBp !== 0) {
        return rejected(`Line ${l.lineNo}: iepsBp without iepsRateId`);
      }
    }

    // Totals: recompute and compare every amount (brief 4.2).
    let totals: ReturnType<typeof computeSaleTotals>;
    try {
      totals = computeSaleTotals(p.lines, p.orderDiscount);
    } catch (e) {
      if (e instanceof TotalsError) return rejected(e.message);
      throw e;
    }
    const fields = [
      'grossCents',
      'lineDiscountCents',
      'orderDiscountCents',
      'netCents',
      'baseCents',
      'iepsCents',
      'ivaCents',
    ] as const;
    for (const [i, l] of p.lines.entries()) {
      for (const f of fields) {
        if (l[f] !== totals.lines[i][f]) {
          return rejected(
            `Line ${l.lineNo}: ${f} is ${l[f]}, expected ${totals.lines[i][f]}`,
          );
        }
      }
    }
    for (const f of ['grossCents', 'discountCents', 'totalCents'] as const) {
      if (p[f] !== totals[f]) {
        return rejected(`${f} is ${p[f]}, expected ${totals[f]}`);
      }
    }

    const [pay] = p.payments;
    if (pay.amountCents !== totals.totalCents) {
      return rejected('Payment amount does not match the total');
    }
    if (pay.tenderedCents < pay.amountCents) {
      return rejected('Cash received is less than the total');
    }
    if (pay.changeCents !== pay.tenderedCents - pay.amountCents) {
      return rejected('Change does not match cash received minus total');
    }

    // Discounts over the cashier limit need a manager (brief 4.2 step 7).
    const limitBp = SALE_SETTINGS.discountLimitBp;
    const cashierMayExceed = await holds(
      this.prisma,
      cashier,
      'sale.discount_over_limit',
    );
    const discounts: {
      lineNo: number | null;
      d: DiscountInputDto;
      cents: number;
      over: boolean;
    }[] = [];
    for (const [i, l] of p.lines.entries()) {
      if (!l.discount) continue;
      const cents = totals.lines[i].lineDiscountCents;
      discounts.push({
        lineNo: l.lineNo,
        d: l.discount,
        cents,
        over: overLimit(cents, totals.lines[i].grossCents, limitBp),
      });
    }
    if (p.orderDiscount) {
      const base = totals.lines.reduce(
        (a, l) => a + l.grossCents - l.lineDiscountCents,
        0,
      );
      const cents = totals.lines.reduce((a, l) => a + l.orderDiscountCents, 0);
      discounts.push({
        lineNo: null,
        d: p.orderDiscount,
        cents,
        over: overLimit(cents, base, limitBp),
      });
    }
    for (const x of discounts) {
      const where =
        x.lineNo == null ? 'Ticket discount' : `Line ${x.lineNo} discount`;
      if (x.d.approverStaffId) {
        const approver = await checkApprover(
          this.prisma,
          x.d.approverStaffId,
          cashier.id,
          device.branchId,
          'sale.discount_over_limit',
        );
        if (isRejection(approver))
          return rejected(`${where}: ${approver.message}`);
      } else if (x.over && !cashierMayExceed) {
        return rejected(
          `${where} is above the ${limitBp / 100}% limit and has no manager approval`,
        );
      }
    }

    const receivedAt = this.clock.now();
    const sale: Prisma.SaleUncheckedCreateInput = {
      id: saleId,
      deviceId: device.id,
      branchId: device.branchId,
      folio: p.folio,
      folioNumber: p.folioNumber,
      cashierStaffId: cashier.id,
      shiftId: p.shiftId ?? null,
      occurredAt,
      receivedAt,
      grossCents: totals.grossCents,
      discountCents: totals.discountCents,
      totalCents: totals.totalCents,
    };
    const lines: Prisma.SaleLineCreateManyInput[] = p.lines.map((l, i) => ({
      saleId,
      variantId: l.variantId,
      productName: l.productName,
      variantName: l.variantName,
      quantity: l.quantity,
      unitPriceCents: l.unitPriceCents,
      ivaRateId: l.ivaRateId,
      ivaBp: l.ivaBp,
      iepsRateId: l.iepsRateId ?? null,
      iepsBp: l.iepsBp,
      ...totals.lines[i],
    }));
    const discountRows: Prisma.SaleDiscountCreateManyInput[] = discounts.map(
      (x) => ({
        id: uuidv7(),
        saleId,
        lineNo: x.lineNo,
        kind: x.d.kind,
        value: x.d.value,
        cents: x.cents,
        reason: x.d.reason,
        note: x.d.note ?? null,
        approverStaffId: x.d.approverStaffId ?? null,
      }),
    );
    const voided: Prisma.SaleVoidedLineCreateManyInput[] = p.voidedLines.map(
      (v, i) => ({
        saleId,
        seq: i + 1,
        variantId: v.variantId,
        quantity: v.quantity,
        unitPriceCents: v.unitPriceCents,
        voidedAt: new Date(v.voidedAt),
        staffId: v.staffId,
      }),
    );
    const audits: Prisma.AuditLogCreateManyInput[] = discounts
      .filter((x) => x.over)
      .map((x) => ({
        id: uuidv7(),
        occurredAt,
        action: 'sale.discount_over_limit',
        branchId: device.branchId,
        deviceId: device.id,
        actorStaffId: cashier.id,
        approverStaffId: x.d.approverStaffId ?? null,
        entityType: 'sale',
        entityId: saleId,
        data: {
          folio: p.folio,
          lineNo: x.lineNo,
          kind: x.d.kind,
          value: x.d.value,
          cents: x.cents,
          reason: x.d.reason,
        },
      }));

    return {
      ok: true,
      apply: async (tx) => {
        await tx.sale.create({ data: sale });
        await tx.saleLine.createMany({ data: lines });
        if (discountRows.length) {
          await tx.saleDiscount.createMany({ data: discountRows });
        }
        if (voided.length) await tx.saleVoidedLine.createMany({ data: voided });
        await tx.payment.create({
          data: {
            id: uuidv7(),
            saleId,
            method: pay.method,
            amountCents: pay.amountCents,
            tenderedCents: pay.tenderedCents,
            changeCents: pay.changeCents,
          },
        });
        if (audits.length) await tx.auditLog.createMany({ data: audits });
      },
    };
  }

  async planRefunded(device: Device, record: SyncRecordDto): Promise<Plan> {
    const parsed = parsePayload(SaleRefundedPayloadDto, record.payload);
    if (isRejection(parsed)) return parsed;
    const p = parsed.value;
    const refundId = record.id;
    const occurredAt = new Date(record.occurredAt);

    if (occurredAt.getTime() > this.clock.now().getTime() + DAY_MS) {
      return rejected('occurredAt is more than a day in the future');
    }
    if (device.type !== DeviceType.TILL) {
      return rejected('Only a sales till can record refunds');
    }
    if (new Set(p.lines.map((l) => l.lineNo)).size !== p.lines.length) {
      return rejected('Line numbers repeat');
    }

    const sale = await this.prisma.sale.findUnique({
      where: { id: p.saleId },
      include: { branch: true },
    });
    if (!sale || sale.branchId !== device.branchId) {
      return rejected('Sale not found in this branch');
    }
    if (p.kind === RefundKind.VOID) {
      if (sale.deviceId !== device.id) {
        return rejected(
          'A sale can only be cancelled on the till that made it',
        );
      }
      const tz = sale.branch.timezone;
      if (localDay(sale.occurredAt, tz) !== localDay(occurredAt, tz)) {
        return rejected('A sale can only be cancelled on the day it was made');
      }
    }

    const key =
      p.kind === RefundKind.VOID ? 'sale.void_after_payment' : 'sale.refund';
    const staff = await findStaff(this.prisma, p.staffId);
    if (!staff) return rejected('Unknown staffId');
    if (!inBranch(staff, device.branchId)) {
      return rejected('Staff member is not assigned to this branch');
    }
    if (p.approverStaffId) {
      const approver = await checkApprover(
        this.prisma,
        p.approverStaffId,
        staff.id,
        device.branchId,
        key,
      );
      if (isRejection(approver)) return approver;
    } else if (!(await holds(this.prisma, staff, key))) {
      return rejected(`Staff member lacks ${key} and has no manager approval`);
    }

    return {
      ok: true,
      apply: (tx) => this.applyRefund(tx, device, refundId, occurredAt, p),
    };
  }

  /** Checks units and amounts against the locked sale, then writes. */
  private async applyRefund(
    tx: Prisma.TransactionClient,
    device: Device,
    refundId: string,
    occurredAt: Date,
    p: SaleRefundedPayloadDto,
  ): Promise<Rejection | void> {
    // Two refunds of one sale at once must not both take the last unit.
    await tx.$queryRaw`SELECT 1 FROM "sale" WHERE "id" = ${p.saleId}::uuid FOR UPDATE`;
    const sale = await tx.sale.findUniqueOrThrow({
      where: { id: p.saleId },
      include: { lines: true },
    });
    if (
      sale.status === SaleStatus.REFUNDED ||
      sale.status === SaleStatus.VOIDED
    ) {
      return rejected(`Sale ${sale.folio} is already ${sale.status}`);
    }
    const byNo = new Map(sale.lines.map((l) => [l.lineNo, l]));
    let total = 0;
    for (const r of p.lines) {
      const line = byNo.get(r.lineNo);
      if (!line) return rejected(`Sale has no line ${r.lineNo}`);
      const left = line.quantity - line.refundedQuantity;
      if (r.quantity > left) {
        return rejected(
          `Line ${r.lineNo}: ${r.quantity} units asked, ${left} left`,
        );
      }
      const amount = refundAmountCents(
        line.netCents,
        line.quantity,
        line.refundedQuantity,
        r.quantity,
      );
      const t = splitTax(amount, line.ivaBp, line.iepsBp);
      if (
        r.amountCents !== amount ||
        r.baseCents !== t.baseCents ||
        r.iepsCents !== t.iepsCents ||
        r.ivaCents !== t.ivaCents
      ) {
        return rejected(
          `Line ${r.lineNo}: amount ${r.amountCents}, expected ${amount} (base ${t.baseCents}, IEPS ${t.iepsCents}, IVA ${t.ivaCents})`,
        );
      }
      total += amount;
    }
    if (p.totalCents !== total) {
      return rejected(`totalCents is ${p.totalCents}, expected ${total}`);
    }
    const asked = new Map(p.lines.map((r) => [r.lineNo, r.quantity]));
    const allGone = sale.lines.every(
      (l) => l.quantity - l.refundedQuantity === (asked.get(l.lineNo) ?? 0),
    );
    if (p.kind === RefundKind.VOID && !allGone) {
      return rejected('Cancelling a sale must return every unit left');
    }

    await tx.refund.create({
      data: {
        id: refundId,
        saleId: sale.id,
        kind: p.kind,
        reason: p.reason,
        note: p.note ?? null,
        deviceId: device.id,
        staffId: p.staffId,
        approverStaffId: p.approverStaffId ?? null,
        occurredAt,
        totalCents: total,
        lines: {
          createMany: {
            data: p.lines.map((r) => ({
              lineNo: r.lineNo,
              quantity: r.quantity,
              amountCents: r.amountCents,
              baseCents: r.baseCents,
              iepsCents: r.iepsCents,
              ivaCents: r.ivaCents,
              restock: r.restock,
            })),
          },
        },
      },
    });
    for (const r of p.lines) {
      await tx.saleLine.update({
        where: { saleId_lineNo: { saleId: sale.id, lineNo: r.lineNo } },
        data: {
          refundedQuantity: { increment: r.quantity },
          refundedCents: { increment: r.amountCents },
        },
      });
    }
    const status =
      p.kind === RefundKind.VOID
        ? SaleStatus.VOIDED
        : allGone
          ? SaleStatus.REFUNDED
          : SaleStatus.PARTIALLY_REFUNDED;
    await tx.sale.update({
      where: { id: sale.id },
      data: { status, refundedCents: { increment: total } },
    });
    await tx.auditLog.create({
      data: {
        id: uuidv7(),
        occurredAt,
        action: p.kind === RefundKind.VOID ? 'sale.voided' : 'sale.refunded',
        branchId: device.branchId,
        deviceId: device.id,
        actorStaffId: p.staffId,
        approverStaffId: p.approverStaffId ?? null,
        entityType: 'sale',
        entityId: sale.id,
        data: {
          folio: sale.folio,
          refundId,
          reason: p.reason,
          totalCents: total,
          lines: p.lines.map((r) => ({
            lineNo: r.lineNo,
            quantity: r.quantity,
          })),
        },
      },
    });
  }
}
