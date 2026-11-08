import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  OnApplicationBootstrap,
  OnApplicationShutdown,
} from '@nestjs/common';
import {
  Device,
  MissedRule,
  OrderStatus,
  Prisma,
  PrepaidKind,
  TicketStatus,
} from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { ClockService } from '../common/clock.service';
import { localDay } from '../common/local-day';
import { PrismaService } from '../prisma/prisma.service';
import { daysBefore, dayOf } from '../stock/fifo-days';
import {
  CustomerDto,
  CustomerUpdateDto,
  OrderCreateDto,
  OrderPauseDto,
  OrderUpdateDto,
} from './dto/orders.dto';
import { TICKET_DAYS_AHEAD, TicketsService } from './tickets.service';

type Tx = Prisma.TransactionClient;

const HOUR_MS = 3_600_000;
const NIGHTLY_HOUR = 3;
const asDate = (day: string) => new Date(`${day}T00:00:00Z`);

const notFound = (what: string) =>
  new NotFoundException({ code: 'NOT_FOUND', message: `${what} not found` });
const invalid = (message: string) =>
  new BadRequestException({ code: 'VALIDATION_FAILED', message });

const ORDER_INCLUDE = {
  customer: { select: { name: true } },
  lines: {
    orderBy: { variantId: 'asc' },
    include: {
      variant: { select: { name: true, product: { select: { name: true } } } },
    },
  },
  skips: { orderBy: { date: 'asc' } },
} satisfies Prisma.CustomerOrderInclude;

type OrderRow = Prisma.CustomerOrderGetPayload<{
  include: typeof ORDER_INCLUDE;
}>;

const TICKET_INCLUDE = {
  customer: { select: { name: true, phone: true } },
  lines: { orderBy: { lineNo: 'asc' } },
} satisfies Prisma.OrderTicketInclude;

type TicketRow = Prisma.OrderTicketGetPayload<{
  include: typeof TICKET_INCLUDE;
}>;

function formatOrder(o: OrderRow) {
  return {
    id: o.id,
    customerId: o.customerId,
    customerName: o.customer.name,
    branchId: o.branchId,
    kind: o.kind,
    weekdays: o.weekdays,
    startDate: dayOf(o.startDate),
    endDate: o.endDate ? dayOf(o.endDate) : null,
    pickupTime: o.pickupTime,
    missedRule: o.missedRule,
    status: o.status,
    pausedFrom: o.pausedFrom ? dayOf(o.pausedFrom) : null,
    pausedUntil: o.pausedUntil ? dayOf(o.pausedUntil) : null,
    note: o.note,
    lines: o.lines.map((l) => ({
      variantId: l.variantId,
      productName: l.variant.product.name,
      variantName: l.variant.name,
      quantity: l.quantity,
    })),
    skips: o.skips.map((s) => dayOf(s.date)),
  };
}

export function formatTicket(t: TicketRow, balanceCents: number) {
  return {
    id: t.id,
    orderId: t.orderId,
    branchId: t.branchId,
    customerId: t.customerId,
    customerName: t.customer.name,
    customerPhone: t.customer.phone,
    balanceCents,
    dueDate: dayOf(t.dueDate),
    pickupTime: t.pickupTime,
    status: t.status,
    totalCents: t.totalCents,
    saleId: t.saleId,
    lines: t.lines.map((l) => ({
      lineNo: l.lineNo,
      variantId: l.variantId,
      productName: l.productName,
      variantName: l.variantName,
      quantity: l.quantity,
      unitPriceCents: l.unitPriceCents,
      ivaRateId: l.ivaRateId,
      ivaBp: l.ivaBp,
      iepsRateId: l.iepsRateId,
      iepsBp: l.iepsBp,
    })),
  };
}

/** Customers, orders and their tickets (M6 brief 4). */
@Injectable()
export class OrdersService
  implements OnApplicationBootstrap, OnApplicationShutdown
{
  private timer: NodeJS.Timeout | null = null;

  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
    private readonly tickets: TicketsService,
  ) {}

  onApplicationBootstrap() {
    if (process.env.NODE_ENV === 'test') return;
    // Hourly tick; the nightly work runs once, at 03:00.
    this.timer = setInterval(() => void this.tick(), HOUR_MS);
    this.timer.unref();
  }

  onApplicationShutdown() {
    if (this.timer) clearInterval(this.timer);
  }

  private async tick() {
    if (this.clock.now().getHours() === NIGHTLY_HOUR) await this.runNightly();
  }

  private scope(user: AuthenticatedUser): string[] | null {
    return user.permissions.includes('reports.all') ? null : user.branchIds;
  }

  private assertBranch(user: AuthenticatedUser, branchId: string) {
    const scope = this.scope(user);
    if (scope && !scope.includes(branchId)) {
      throw new ForbiddenException({
        code: 'PERMISSION_DENIED',
        message: 'You cannot manage orders of this branch',
      });
    }
  }

  private audit(
    tx: Tx,
    user: AuthenticatedUser,
    action: string,
    entityType: string,
    entityId: string,
    data: Prisma.InputJsonValue,
    branchId: string | null = null,
  ) {
    return tx.auditLog.create({
      data: {
        id: uuidv7(),
        occurredAt: this.clock.now(),
        action,
        branchId,
        actorStaffId: user.staffId,
        entityType,
        entityId,
        data,
      },
    });
  }

  async balances(customerIds: string[]): Promise<Map<string, number>> {
    const rows = await this.prisma.prepaidEntry.groupBy({
      by: ['customerId'],
      where: { customerId: { in: customerIds } },
      _sum: { amountCents: true },
      orderBy: { customerId: 'asc' },
    });
    return new Map(
      rows.map((r) => [r.customerId, r._sum?.amountCents ?? 0] as const),
    );
  }

  private formatCustomer(
    c: Prisma.CustomerGetPayload<object>,
    balanceCents: number,
  ) {
    return {
      id: c.id,
      name: c.name,
      phone: c.phone,
      rfc: c.rfc,
      notes: c.notes,
      isActive: c.isActive,
      balanceCents,
    };
  }

  // ── Customers ─────────────────────────────────────────────────────────

  async listCustomers(q?: string) {
    const text = q?.trim();
    const rows = await this.prisma.customer.findMany({
      where: text
        ? {
            OR: [
              { name: { contains: text, mode: 'insensitive' } },
              { phone: { contains: text.replace(/\s/g, '') } },
            ],
          }
        : {},
      orderBy: { name: 'asc' },
      take: 100,
    });
    const balances = await this.balances(rows.map((c) => c.id));
    return {
      items: rows.map((c) => this.formatCustomer(c, balances.get(c.id) ?? 0)),
    };
  }

  private async withUniquePhone<T>(fn: () => Promise<T>): Promise<T> {
    try {
      return await fn();
    } catch (e) {
      if (
        e instanceof Prisma.PrismaClientKnownRequestError &&
        e.code === 'P2002'
      ) {
        throw new ConflictException({
          code: 'CONFLICT',
          message: 'That phone is already used by another customer',
          details: { field: 'phone' },
        });
      }
      throw e;
    }
  }

  async createCustomer(user: AuthenticatedUser, dto: CustomerDto) {
    const id = uuidv7();
    const c = await this.withUniquePhone(() =>
      this.prisma.$transaction(async (tx) => {
        const row = await tx.customer.create({
          data: {
            id,
            name: dto.name.trim(),
            phone: dto.phone?.replace(/\s/g, '') ?? null,
            rfc: dto.rfc ?? null,
            notes: dto.notes ?? null,
          },
        });
        await this.audit(tx, user, 'customer.created', 'customer', id, {
          name: row.name,
        });
        return row;
      }),
    );
    return this.formatCustomer(c, 0);
  }

  async updateCustomer(
    user: AuthenticatedUser,
    id: string,
    dto: CustomerUpdateDto,
  ) {
    const c = await this.withUniquePhone(() =>
      this.prisma.$transaction(async (tx) => {
        const before = await tx.customer.findUnique({ where: { id } });
        if (!before) throw notFound('Customer');
        const row = await tx.customer.update({
          where: { id },
          data: {
            name: dto.name?.trim(),
            phone:
              dto.phone === undefined
                ? undefined
                : (dto.phone?.replace(/\s/g, '') ?? null),
            rfc: dto.rfc,
            notes: dto.notes,
            isActive: dto.isActive,
          },
        });
        await this.audit(tx, user, 'customer.updated', 'customer', id, {
          fields: Object.keys(dto),
        });
        return row;
      }),
    );
    return this.formatCustomer(c, (await this.balances([id])).get(id) ?? 0);
  }

  /** A customer with balance, orders and the last entries of the ledger. */
  async getCustomer(id: string) {
    const c = await this.prisma.customer.findUnique({ where: { id } });
    if (!c) throw notFound('Customer');
    const [orders, entries, balances] = await Promise.all([
      this.prisma.customerOrder.findMany({
        where: { customerId: id },
        include: ORDER_INCLUDE,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.prepaidEntry.findMany({
        where: { customerId: id },
        orderBy: [{ occurredAt: 'desc' }, { id: 'desc' }],
        take: 100,
      }),
      this.balances([id]),
    ]);
    return {
      ...this.formatCustomer(c, balances.get(id) ?? 0),
      orders: orders.map(formatOrder),
      entries: entries.map((e) => ({
        id: e.id,
        kind: e.kind,
        amountCents: e.amountCents,
        ticketId: e.ticketId,
        occurredAt: e.occurredAt.toISOString(),
      })),
    };
  }

  // ── Orders ────────────────────────────────────────────────────────────

  private async checkFields(
    tx: Tx,
    kind: 'STANDING' | 'ONE_OFF',
    dto: OrderUpdateDto,
  ) {
    if (kind === 'STANDING' && dto.weekdays === 0) {
      throw invalid('A standing order needs at least one weekday');
    }
    if (kind === 'ONE_OFF') {
      if (dto.weekdays !== 0) throw invalid('A pre-order has no weekdays');
      if (dto.endDate != null && dto.endDate !== dto.startDate) {
        throw invalid('A pre-order is for one date');
      }
    }
    if (dto.endDate && dto.endDate < dto.startDate) {
      throw invalid('The end date is before the start date');
    }
    const ids = dto.lines.map((l) => l.variantId);
    if (new Set(ids).size !== ids.length) throw invalid('A product repeats');
    const known = await tx.productVariant.count({
      where: { id: { in: ids }, isActive: true },
    });
    if (known !== ids.length) throw notFound('Variant');
  }

  private fields(kind: 'STANDING' | 'ONE_OFF', dto: OrderUpdateDto) {
    return {
      weekdays: dto.weekdays,
      startDate: asDate(dto.startDate),
      endDate:
        kind === 'ONE_OFF'
          ? asDate(dto.startDate)
          : dto.endDate
            ? asDate(dto.endDate)
            : null,
      pickupTime: dto.pickupTime,
      missedRule: dto.missedRule,
      note: dto.note ?? null,
    };
  }

  private async load(id: string) {
    const o = await this.prisma.customerOrder.findUnique({
      where: { id },
      include: ORDER_INCLUDE,
    });
    if (!o) throw notFound('Order');
    return formatOrder(o);
  }

  async listOrders(
    user: AuthenticatedUser,
    q: { customerId?: string; branchId?: string },
  ) {
    if (q.branchId) this.assertBranch(user, q.branchId);
    const scope = this.scope(user);
    const rows = await this.prisma.customerOrder.findMany({
      where: {
        ...(q.customerId ? { customerId: q.customerId } : {}),
        ...(q.branchId
          ? { branchId: q.branchId }
          : scope
            ? { branchId: { in: scope } }
            : {}),
      },
      include: ORDER_INCLUDE,
      orderBy: [{ status: 'asc' }, { pickupTime: 'asc' }, { id: 'asc' }],
      take: 500,
    });
    return { items: rows.map(formatOrder) };
  }

  async getOrder(user: AuthenticatedUser, id: string) {
    const o = await this.load(id);
    this.assertBranch(user, o.branchId);
    return o;
  }

  async createOrder(user: AuthenticatedUser, dto: OrderCreateDto) {
    this.assertBranch(user, dto.branchId);
    const id = uuidv7();
    await this.prisma.$transaction(async (tx) => {
      const customer = await tx.customer.findUnique({
        where: { id: dto.customerId },
      });
      if (!customer?.isActive) throw notFound('Customer');
      const branch = await tx.branch.findUnique({
        where: { id: dto.branchId },
      });
      if (!branch) throw notFound('Branch');
      await this.checkFields(tx, dto.kind, dto);
      await tx.customerOrder.create({
        data: {
          id,
          customerId: dto.customerId,
          branchId: dto.branchId,
          kind: dto.kind,
          createdByStaffId: user.staffId,
          ...this.fields(dto.kind, dto),
          lines: {
            createMany: {
              data: dto.lines.map((l) => ({
                variantId: l.variantId,
                quantity: l.quantity,
              })),
            },
          },
        },
      });
      await this.tickets.rebuild(tx, id, this.clock.now());
      await this.audit(
        tx,
        user,
        'order.created',
        'customer_order',
        id,
        { kind: dto.kind, customerId: dto.customerId },
        dto.branchId,
      );
    });
    return this.load(id);
  }

  private async mutate(
    user: AuthenticatedUser,
    id: string,
    action: string,
    data: Prisma.InputJsonValue,
    change: (
      tx: Tx,
      order: Prisma.CustomerOrderGetPayload<object>,
    ) => Promise<void>,
  ) {
    await this.prisma.$transaction(async (tx) => {
      const order = await tx.customerOrder.findUnique({ where: { id } });
      if (!order) throw notFound('Order');
      this.assertBranch(user, order.branchId);
      if (order.status === OrderStatus.ENDED) {
        throw new ConflictException({
          code: 'CONFLICT',
          message: 'This order has ended',
        });
      }
      await change(tx, order);
      await this.tickets.rebuild(tx, id, this.clock.now());
      await this.audit(
        tx,
        user,
        action,
        'customer_order',
        id,
        data,
        order.branchId,
      );
    });
    return this.load(id);
  }

  updateOrder(user: AuthenticatedUser, id: string, dto: OrderUpdateDto) {
    return this.mutate(
      user,
      id,
      'order.updated',
      { lines: dto.lines.length },
      async (tx, order) => {
        await this.checkFields(tx, order.kind, dto);
        await tx.customerOrder.update({
          where: { id },
          data: this.fields(order.kind, dto),
        });
        await tx.customerOrderLine.deleteMany({ where: { orderId: id } });
        await tx.customerOrderLine.createMany({
          data: dto.lines.map((l) => ({
            orderId: id,
            variantId: l.variantId,
            quantity: l.quantity,
          })),
        });
      },
    );
  }

  skip(user: AuthenticatedUser, id: string, date: string) {
    return this.mutate(user, id, 'order.skipped', { date }, async (tx) => {
      await tx.orderSkip.upsert({
        where: { orderId_date: { orderId: id, date: asDate(date) } },
        create: { orderId: id, date: asDate(date) },
        update: {},
      });
    });
  }

  unskip(user: AuthenticatedUser, id: string, date: string) {
    return this.mutate(user, id, 'order.updated', { unskip: date }, (tx) =>
      tx.orderSkip
        .deleteMany({ where: { orderId: id, date: asDate(date) } })
        .then(() => undefined),
    );
  }

  pause(user: AuthenticatedUser, id: string, dto: OrderPauseDto) {
    if (dto.until && dto.until < dto.from) {
      throw invalid('The pause ends before it starts');
    }
    return this.mutate(user, id, 'order.paused', { ...dto }, async (tx) => {
      await tx.customerOrder.update({
        where: { id },
        data: {
          status: OrderStatus.PAUSED,
          pausedFrom: asDate(dto.from),
          pausedUntil: dto.until ? asDate(dto.until) : null,
        },
      });
    });
  }

  resume(user: AuthenticatedUser, id: string) {
    return this.mutate(user, id, 'order.updated', { resumed: true }, (tx) =>
      tx.customerOrder
        .update({
          where: { id },
          data: {
            status: OrderStatus.ACTIVE,
            pausedFrom: null,
            pausedUntil: null,
          },
        })
        .then(() => undefined),
    );
  }

  end(user: AuthenticatedUser, id: string) {
    return this.mutate(user, id, 'order.updated', { ended: true }, (tx) =>
      tx.customerOrder
        .update({ where: { id }, data: { status: OrderStatus.ENDED } })
        .then(() => undefined),
    );
  }

  // ── Tickets ───────────────────────────────────────────────────────────

  private async ticketsWhere(where: Prisma.OrderTicketWhereInput) {
    const rows = await this.prisma.orderTicket.findMany({
      where,
      include: TICKET_INCLUDE,
      orderBy: [{ dueDate: 'asc' }, { pickupTime: 'asc' }, { id: 'asc' }],
    });
    const balances = await this.balances([
      ...new Set(rows.map((t) => t.customerId)),
    ]);
    return rows.map((t) => formatTicket(t, balances.get(t.customerId) ?? 0));
  }

  /** The device's branch: yesterday to the last day kept, for offline pickup. */
  async branchTickets(device: Device) {
    const branch = await this.prisma.branch.findUniqueOrThrow({
      where: { id: device.branchId },
    });
    const now = this.clock.now();
    const today = localDay(now, branch.timezone);
    return {
      generatedAt: now.toISOString(),
      today,
      items: await this.ticketsWhere({
        branchId: device.branchId,
        dueDate: {
          gte: asDate(daysBefore(today, 1)),
          lte: asDate(daysBefore(today, -TICKET_DAYS_AHEAD)),
        },
        status: { not: TicketStatus.SKIPPED },
      }),
    };
  }

  /** Baker's totals and the counter's list for one day (M7.4). */
  async pickList(user: AuthenticatedUser, branchId: string, date: string) {
    this.assertBranch(user, branchId);
    const tickets = await this.ticketsWhere({
      branchId,
      dueDate: asDate(date),
      status: { not: TicketStatus.SKIPPED },
    });
    const totals = new Map<
      string,
      {
        variantId: string;
        productName: string;
        variantName: string;
        quantity: number;
      }
    >();
    for (const t of tickets) {
      for (const l of t.lines) {
        const e = totals.get(l.variantId) ?? {
          variantId: l.variantId,
          productName: l.productName,
          variantName: l.variantName,
          quantity: 0,
        };
        e.quantity += l.quantity;
        totals.set(l.variantId, e);
      }
    }
    return {
      date,
      totals: [...totals.values()].sort((a, b) =>
        a.productName.localeCompare(b.productName),
      ),
      tickets,
    };
  }

  /**
   * Nightly (M6 brief 2): yesterday's pending tickets are missed, and charged
   * unless the order says not to; then every order gets its tickets ahead.
   */
  async runNightly() {
    const now = this.clock.now();
    const branches = await this.prisma.branch.findMany();
    let missed = 0;
    for (const b of branches) {
      const today = localDay(now, b.timezone);
      const due = await this.prisma.orderTicket.findMany({
        where: {
          branchId: b.id,
          status: TicketStatus.PENDING,
          dueDate: { lt: asDate(today) },
        },
        include: { order: { select: { missedRule: true } } },
      });
      for (const t of due) {
        await this.prisma.$transaction(async (tx) => {
          const { count } = await tx.orderTicket.updateMany({
            where: { id: t.id, status: TicketStatus.PENDING },
            data: { status: TicketStatus.MISSED },
          });
          if (count === 0) return;
          missed++;
          if (t.order.missedRule === MissedRule.CHARGE) {
            await tx.prepaidEntry.create({
              data: {
                id: uuidv7(),
                customerId: t.customerId,
                kind: PrepaidKind.MISSED,
                amountCents: -t.totalCents,
                ticketId: t.id,
                occurredAt: now,
              },
            });
          }
          await tx.auditLog.create({
            data: {
              id: uuidv7(),
              occurredAt: now,
              action: 'order.missed',
              branchId: t.branchId,
              entityType: 'order_ticket',
              entityId: t.id,
              data: {
                charged: t.order.missedRule === MissedRule.CHARGE,
                totalCents: t.totalCents,
              },
            },
          });
        });
      }
    }
    const orders = await this.prisma.customerOrder.findMany({
      where: { status: { not: OrderStatus.ENDED } },
      select: { id: true },
    });
    for (const o of orders) {
      await this.prisma.$transaction((tx) =>
        this.tickets.rebuild(tx, o.id, now),
      );
    }
    return { missed, orders: orders.length };
  }
}
