import { Injectable } from '@nestjs/common';
import { Prisma, StockEventKind } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { localDay } from '../common/local-day';
import { assignLots, daysBefore, FifoResult } from './fifo';

type Tx = Prisma.TransactionClient;

export const dayOf = (d: Date) => d.toISOString().slice(0, 10);

export interface Move {
  branchId: string;
  variantId: string;
  quantity: number;
  kind: StockEventKind;
  referenceType: string;
  referenceId: string;
  staffId: string | null;
  occurredAt: Date;
}

/**
 * The only writer of stock. Every change is one or more ledger rows, and
 * `quantity_left` moves with them in the caller's transaction (M5.6).
 */
@Injectable()
export class StockLedgerService {
  /** One writer per variant and branch, so two sales cannot take one unit. */
  async lock(tx: Tx, branchId: string, variantId: string) {
    const key = `stock:${branchId}:${variantId}`;
    await tx.$executeRaw`SELECT pg_advisory_xact_lock(hashtext(${key}))`;
  }

  private async openLots(tx: Tx, branchId: string, variantId: string) {
    const rows = await tx.stockLot.findMany({
      where: { branchId, variantId, quantityLeft: { gt: 0 } },
    });
    return rows.map((l) => ({
      id: l.id,
      producedOn: dayOf(l.producedOn),
      left: l.quantityLeft,
    }));
  }

  private event(m: Move, quantity: number, lotId: string | null) {
    return {
      id: uuidv7(),
      branchId: m.branchId,
      variantId: m.variantId,
      lotId,
      kind: m.kind,
      quantity,
      referenceType: m.referenceType,
      referenceId: m.referenceId,
      staffId: m.staffId,
      occurredAt: m.occurredAt,
    };
  }

  /**
   * Takes units oldest first; the caller holds the lock. Units with no lot
   * left write a row with no lot, so on-hand goes negative (M5 brief 2).
   */
  async take(
    tx: Tx,
    m: Move,
    opts: { agedOnOrBefore?: string | null; lotId?: string | null } = {},
  ): Promise<FifoResult> {
    let lots = await this.openLots(tx, m.branchId, m.variantId);
    if (opts.lotId) lots = lots.filter((l) => l.id === opts.lotId);
    const result = assignLots(lots, m.quantity, opts.agedOnOrBefore);
    for (const t of result.takes) {
      await tx.stockLot.update({
        where: { id: t.lotId },
        data: { quantityLeft: { decrement: t.quantity } },
      });
      await tx.stockEvent.create({
        data: this.event(m, -t.quantity, t.lotId),
      });
    }
    if (result.unassigned > 0) {
      await tx.stockEvent.create({
        data: this.event(m, -result.unassigned, null),
      });
    }
    return result;
  }

  /** Adds a new dated lot; `id` comes from the device when it has one. */
  async addLot(
    tx: Tx,
    m: Move,
    producedOn: string,
    id: string = uuidv7(),
  ): Promise<void> {
    await tx.stockLot.create({
      data: {
        id,
        branchId: m.branchId,
        variantId: m.variantId,
        producedOn: new Date(`${producedOn}T00:00:00Z`),
        quantityLeft: m.quantity,
      },
    });
    await tx.stockEvent.create({ data: this.event(m, m.quantity, id) });
  }

  /** Sum of the ledger: what is on hand, whatever the lots say. */
  async onHand(tx: Tx, branchId: string, variantId: string): Promise<number> {
    const row = await tx.stockEvent.aggregate({
      where: { branchId, variantId },
      _sum: { quantity: true },
    });
    return row._sum.quantity ?? 0;
  }

  /** What a whole shortage is, the units sold with no lot. */
  async shortage(tx: Tx, branchId: string, variantId: string): Promise<number> {
    const row = await tx.stockEvent.aggregate({
      where: { branchId, variantId, lotId: null },
      _sum: { quantity: true },
    });
    return Math.max(0, -(row._sum.quantity ?? 0));
  }

  /** Raises stock: repays a shortage first, then a new lot dated today. */
  async raise(tx: Tx, m: Move, today: string): Promise<void> {
    const short = await this.shortage(tx, m.branchId, m.variantId);
    const repay = Math.min(short, m.quantity);
    if (repay > 0) {
      await tx.stockEvent.create({ data: this.event(m, repay, null) });
    }
    if (m.quantity > repay) {
      await this.addLot(tx, { ...m, quantity: m.quantity - repay }, today);
    }
  }

  /** Oldest-first takes for a stored sale (M5.2). */
  async takeForSale(
    tx: Tx,
    sale: {
      saleId: string;
      branchId: string;
      timeZone: string;
      staffId: string;
      occurredAt: Date;
      lines: { variantId: string; quantity: number; dayOld: boolean }[];
    },
  ): Promise<void> {
    // Same order everywhere, so two sales never wait on each other in a ring.
    const lines = [...sale.lines].sort((a, b) =>
      a.variantId.localeCompare(b.variantId),
    );
    const today = localDay(sale.occurredAt, sale.timeZone);
    for (const l of lines) {
      await this.lock(tx, sale.branchId, l.variantId);
      let agedOnOrBefore: string | null = null;
      if (l.dayOld) {
        const v = await tx.productVariant.findUniqueOrThrow({
          where: { id: l.variantId },
          select: { product: { select: { dayOldDiscountAfterDays: true } } },
        });
        agedOnOrBefore = daysBefore(
          today,
          v.product.dayOldDiscountAfterDays ?? 0,
        );
      }
      await this.take(
        tx,
        {
          branchId: sale.branchId,
          variantId: l.variantId,
          quantity: l.quantity,
          kind: StockEventKind.SALE,
          referenceType: 'sale',
          referenceId: sale.saleId,
          staffId: sale.staffId,
          occurredAt: sale.occurredAt,
        },
        { agedOnOrBefore },
      );
    }
  }

  /**
   * Units a refund puts back go to the lots the sale took them from, newest
   * first; units sold with no lot come back with no lot (F13).
   */
  async returnForRefund(
    tx: Tx,
    r: {
      saleId: string;
      refundId: string;
      branchId: string;
      staffId: string;
      occurredAt: Date;
      lines: { variantId: string; quantity: number }[];
    },
  ): Promise<void> {
    for (const line of [...r.lines].sort((a, b) =>
      a.variantId.localeCompare(b.variantId),
    )) {
      await this.lock(tx, r.branchId, line.variantId);
      const events = await tx.stockEvent.findMany({
        where: {
          referenceId: r.saleId,
          variantId: line.variantId,
          kind: { in: [StockEventKind.SALE, StockEventKind.REFUND_RETURN] },
        },
        orderBy: { id: 'desc' },
      });
      // What each lot gave to this sale and has not had back.
      const open = new Map<string | null, number>();
      for (const e of events) {
        open.set(e.lotId, (open.get(e.lotId) ?? 0) - e.quantity);
      }
      let rest = line.quantity;
      const move = {
        branchId: r.branchId,
        variantId: line.variantId,
        kind: StockEventKind.REFUND_RETURN,
        referenceType: 'sale',
        referenceId: r.saleId,
        staffId: r.staffId,
        occurredAt: r.occurredAt,
      };
      for (const [lotId, owed] of open) {
        if (rest === 0) break;
        const back = Math.min(owed, rest);
        if (back <= 0) continue;
        if (lotId) {
          await tx.stockLot.update({
            where: { id: lotId },
            data: { quantityLeft: { increment: back } },
          });
        }
        await tx.stockEvent.create({
          data: this.event({ ...move, quantity: back }, back, lotId),
        });
        rest -= back;
      }
    }
  }
}
