import { Injectable } from '@nestjs/common';
import { CustomerOrder, OrderSkip, Prisma, TicketStatus } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { localDay } from '../common/local-day';
import { computeSaleTotals } from '../sales/sale-totals';
import { daysBefore, dayOf } from '../stock/fifo-days';
import { isDue } from './schedule';

type Tx = Prisma.TransactionClient;

/** Tickets are kept for today and this many days ahead (M6 brief 2). */
export const TICKET_DAYS_AHEAD = 2;

const asDay = (d: Date | null) => (d ? dayOf(d) : null);
const asDate = (day: string) => new Date(`${day}T00:00:00Z`);

export function scheduleOf(o: CustomerOrder & { skips: OrderSkip[] }) {
  return {
    kind: o.kind,
    weekdays: o.weekdays,
    startDate: dayOf(o.startDate),
    endDate: asDay(o.endDate),
    status: o.status,
    pausedFrom: asDay(o.pausedFrom),
    pausedUntil: asDay(o.pausedUntil),
    skips: o.skips.map((s) => dayOf(s.date)),
  };
}

/**
 * Makes the order's tickets for today and the next days, priced as the
 * catalog is now. Pending tickets follow the order; picked-up and missed
 * ones never change (G9).
 */
@Injectable()
export class TicketsService {
  async rebuild(tx: Tx, orderId: string, now: Date): Promise<void> {
    await tx.$queryRaw`SELECT 1 FROM "customer_order" WHERE "id" = ${orderId}::uuid FOR UPDATE`;
    const order = await tx.customerOrder.findUniqueOrThrow({
      where: { id: orderId },
      include: {
        skips: true,
        branch: true,
        lines: {
          orderBy: { variantId: 'asc' },
          include: {
            variant: {
              include: {
                product: { include: { ivaRate: true, iepsRate: true } },
                branchPrices: true,
              },
            },
          },
        },
      },
    });
    const schedule = scheduleOf(order);
    const today = localDay(now, order.branch.timezone);
    const lines = order.lines.map((l, i) => {
      const bp = l.variant.branchPrices.find(
        (b) => b.branchId === order.branchId && b.deletedAt == null,
      );
      const p = l.variant.product;
      return {
        lineNo: i + 1,
        variantId: l.variantId,
        productName: p.name,
        variantName: l.variant.name,
        quantity: l.quantity,
        unitPriceCents: bp?.priceCents ?? l.variant.priceCents,
        ivaRateId: p.ivaRateId,
        ivaBp: p.ivaRate.rateBp,
        iepsRateId: p.iepsRateId,
        iepsBp: p.iepsRate?.rateBp ?? 0,
      };
    });
    const total = computeSaleTotals(lines).totalCents;

    for (let ahead = 0; ahead <= TICKET_DAYS_AHEAD; ahead++) {
      const day = daysBefore(today, -ahead);
      const existing = await tx.orderTicket.findUnique({
        where: { orderId_dueDate: { orderId, dueDate: asDate(day) } },
      });
      const due = isDue(schedule, day);
      if (existing && existing.status !== TicketStatus.PENDING) {
        // A skipped day can come back; the rest is history.
        if (existing.status !== TicketStatus.SKIPPED || !due) continue;
      }
      if (!due) {
        if (existing) {
          await tx.orderTicket.update({
            where: { id: existing.id },
            data: { status: TicketStatus.SKIPPED },
          });
        }
        continue;
      }
      const id = existing?.id ?? uuidv7();
      if (existing) {
        await tx.orderTicketLine.deleteMany({ where: { ticketId: id } });
        await tx.orderTicket.update({
          where: { id },
          data: {
            status: TicketStatus.PENDING,
            pickupTime: order.pickupTime,
            totalCents: total,
          },
        });
      } else {
        await tx.orderTicket.create({
          data: {
            id,
            orderId,
            branchId: order.branchId,
            customerId: order.customerId,
            dueDate: asDate(day),
            pickupTime: order.pickupTime,
            totalCents: total,
          },
        });
      }
      await tx.orderTicketLine.createMany({
        data: lines.map((l) => ({ ...l, ticketId: id })),
      });
    }
  }
}
