import { Injectable } from '@nestjs/common';
import { Device, Prisma, PrepaidKind, TicketStatus } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { ClockService } from '../common/clock.service';
import { localDay } from '../common/local-day';
import { PrismaService } from '../prisma/prisma.service';
import { SaleLineInputDto } from '../sales/dto/sale-sync.dto';
import { dayOf } from '../stock/fifo-days';
import { SyncRecordDto } from '../sync/dto/sync.dto';
import {
  checkShift,
  findStaff,
  holds,
  inBranch,
  isRejection,
  parsePayload,
  Plan,
  rejected,
  Rejection,
} from '../sync/sync-plan';
import { OrderPrepaidPayloadDto } from './dto/orders.dto';

type Tx = Prisma.TransactionClient;
const DAY_MS = 86_400_000;

/**
 * Till records for orders (M6 brief 4.6): prepayments, and the ticket side
 * of a pickup, which is a sale paid from the balance.
 */
@Injectable()
export class OrderSyncService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
  ) {}

  async planPrepaid(device: Device, record: SyncRecordDto): Promise<Plan> {
    const parsed = parsePayload(OrderPrepaidPayloadDto, record.payload);
    if (isRejection(parsed)) return parsed;
    const p = parsed.value;
    const occurredAt = new Date(record.occurredAt);
    if (occurredAt.getTime() > this.clock.now().getTime() + DAY_MS) {
      return rejected('occurredAt is more than a day in the future');
    }
    const shift = await checkShift(
      this.prisma,
      device.id,
      p.shiftId,
      occurredAt,
    );
    if (isRejection(shift)) return shift;
    const staff = await findStaff(this.prisma, p.staffId);
    if (!staff) return rejected('Unknown staffId');
    if (!inBranch(staff, device.branchId)) {
      return rejected('Staff member is not assigned to this branch');
    }
    if (!(await holds(this.prisma, staff, 'orders.pickup'))) {
      return rejected('Staff member lacks orders.pickup');
    }
    const customer = await this.prisma.customer.findUnique({
      where: { id: p.customerId },
    });
    if (!customer) return rejected('Unknown customerId');

    return {
      ok: true,
      apply: async (tx) => {
        await tx.prepaidEntry.create({
          data: {
            id: record.id,
            customerId: p.customerId,
            kind: PrepaidKind.PAYMENT,
            amountCents: p.amountCents,
            shiftId: p.shiftId,
            deviceId: device.id,
            staffId: p.staffId,
            occurredAt,
          },
        });
        await tx.auditLog.create({
          data: {
            id: uuidv7(),
            occurredAt,
            action: 'order.prepaid',
            branchId: device.branchId,
            deviceId: device.id,
            actorStaffId: p.staffId,
            entityType: 'customer',
            entityId: p.customerId,
            data: { amountCents: p.amountCents },
          },
        });
      },
    };
  }

  /**
   * The ticket a pickup sale names, checked under a lock so two tills
   * cannot hand over the same ticket (G7). Call before writing anything.
   */
  async checkPickup(
    tx: Tx,
    device: Device,
    ticketId: string,
    occurredAt: Date,
    lines: SaleLineInputDto[],
    totalCents: number,
  ): Promise<Rejection | { customerId: string }> {
    await tx.$queryRaw`SELECT 1 FROM "order_ticket" WHERE "id" = ${ticketId}::uuid FOR UPDATE`;
    const t = await tx.orderTicket.findUnique({
      where: { id: ticketId },
      include: { lines: true },
    });
    if (!t || t.branchId !== device.branchId) {
      return rejected('Order ticket not found in this branch');
    }
    if (t.status !== TicketStatus.PENDING) {
      return rejected(`Order ticket is already ${t.status}`);
    }
    const branch = await tx.branch.findUniqueOrThrow({
      where: { id: device.branchId },
    });
    if (dayOf(t.dueDate) > localDay(occurredAt, branch.timezone)) {
      return rejected('Order ticket is not due yet');
    }
    const same =
      t.lines.length === lines.length &&
      t.lines.every((tl) => {
        const l = lines.find((x) => x.lineNo === tl.lineNo);
        return (
          l != null &&
          l.variantId === tl.variantId &&
          l.quantity === tl.quantity &&
          l.unitPriceCents === tl.unitPriceCents &&
          !l.discount &&
          !l.dayOld
        );
      });
    if (!same || totalCents !== t.totalCents) {
      return rejected('Pickup lines or amount differ from the order ticket');
    }
    return { customerId: t.customerId };
  }

  async recordPickup(
    tx: Tx,
    device: Device,
    ticketId: string,
    saleId: string,
    customerId: string,
    totalCents: number,
    staffId: string,
    occurredAt: Date,
  ) {
    await tx.orderTicket.update({
      where: { id: ticketId },
      data: { status: TicketStatus.PICKED_UP, saleId },
    });
    await tx.prepaidEntry.create({
      data: {
        id: uuidv7(),
        customerId,
        kind: PrepaidKind.PICKUP,
        amountCents: -totalCents,
        ticketId,
        deviceId: device.id,
        staffId,
        occurredAt,
      },
    });
    await tx.auditLog.create({
      data: {
        id: uuidv7(),
        occurredAt,
        action: 'order.picked_up',
        branchId: device.branchId,
        deviceId: device.id,
        actorStaffId: staffId,
        entityType: 'order_ticket',
        entityId: ticketId,
        data: { saleId, totalCents },
      },
    });
  }

  /** A refund of a pickup goes back to the balance, not the drawer. */
  async creditRefund(
    tx: Tx,
    saleId: string,
    totalCents: number,
    staffId: string,
    occurredAt: Date,
    deviceId: string,
  ) {
    const ticket = await tx.orderTicket.findUnique({ where: { saleId } });
    if (!ticket) return;
    await tx.prepaidEntry.create({
      data: {
        id: uuidv7(),
        customerId: ticket.customerId,
        kind: PrepaidKind.ADJUSTMENT,
        amountCents: totalCents,
        ticketId: ticket.id,
        deviceId,
        staffId,
        occurredAt,
      },
    });
  }
}
