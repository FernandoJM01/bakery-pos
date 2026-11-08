import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { PrismaClient, Role } from '@prisma/client';
import { randomBytes } from 'crypto';
import type { Server } from 'http';
import request from 'supertest';
import { v7 as uuidv7 } from 'uuid';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import { ClockService } from '../src/common/clock.service';
import {
  hashPassword,
  hashPin,
  hashTokenWithPepper,
} from '../src/common/crypto';
import { OrdersService } from '../src/orders/orders.service';
import { computeSaleTotals } from '../src/sales/sale-totals';
import { validateResponseAgainstContract } from './contract-validator';

const IVA0 = '019a1e00-0000-7000-8000-000000000001';
const TZ = 'America/Mexico_City';
const tag = () => randomBytes(4).toString('hex');
// Monday 9 Nov 2026, noon in Mexico City.
const MONDAY = new Date('2026-11-09T18:00:00Z');

interface PushResult {
  id: string;
  status: string;
  errorCode: string | null;
  message: string | null;
}

interface Ticket {
  id: string;
  dueDate: string;
  status: string;
  totalCents: number;
  customerId: string;
  lines: {
    lineNo: number;
    variantId: string;
    productName: string;
    variantName: string;
    quantity: number;
    unitPriceCents: number;
    ivaRateId: string;
    ivaBp: number;
    iepsRateId: string | null;
    iepsBp: number;
  }[];
}

describe('Orders (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  let clock: ClockService;
  const prisma = new PrismaClient();
  let branchId: string;
  let managerToken: string;
  let cashierToken: string;
  let cashierId: string;
  let bakerId: string;
  let bolillo: string;
  let concha: string;
  let till: {
    token: string;
    id: string;
    prefix: string;
    next: number;
    shiftId: string;
  };
  const password = 'OrdersPass123!';

  const valid = (path: string, method: string, res: request.Response) =>
    expect(
      validateResponseAgainstContract({
        path,
        method,
        status: res.status,
        body: res.body,
      }).errors ?? [],
    ).toEqual([]);

  const as = (token: string) => ({ Authorization: `Bearer ${token}` });

  async function push(records: unknown[]) {
    const res = await request(server)
      .post('/v1/sync/push')
      .set('X-Device-Token', till.token)
      .send({ records });
    expect(res.status).toBe(200);
    return (res.body as { results: PushResult[] }).results;
  }

  const pushOne = async (r: unknown) => (await push([r]))[0];

  async function customer(name: string, phone: string | null = null) {
    const res = await request(server)
      .post('/v1/customers')
      .set(as(managerToken))
      .send({ name, phone });
    expect(res.status).toBe(201);
    return (res.body as { id: string }).id;
  }

  async function order(body: Record<string, unknown>) {
    const res = await request(server)
      .post('/v1/orders')
      .set(as(managerToken))
      .send({
        branchId,
        kind: 'STANDING',
        weekdays: 31,
        startDate: '2026-11-09',
        pickupTime: '07:30',
        missedRule: 'CHARGE',
        ...body,
      });
    expect(res.status).toBe(201);
    valid('/v1/orders', 'POST', res);
    return (res.body as { id: string }).id;
  }

  async function tickets(): Promise<Ticket[]> {
    const res = await request(server)
      .get('/v1/orders/tickets')
      .set('X-Device-Token', till.token);
    expect(res.status).toBe(200);
    valid('/v1/orders/tickets', 'GET', res);
    return (res.body as { items: Ticket[] }).items;
  }

  const balance = async (id: string) =>
    (
      await prisma.prepaidEntry.aggregate({
        where: { customerId: id },
        _sum: { amountCents: true },
      })
    )._sum.amountCents ?? 0;

  const record = (type: string, payload: Record<string, unknown>) => ({
    id: uuidv7(),
    type,
    occurredAt: clock.now().toISOString(),
    payload,
  });

  const prepaid = (customerId: string, amountCents: number) =>
    record('order.prepaid', {
      customerId,
      shiftId: till.shiftId,
      amountCents,
      staffId: cashierId,
    });

  /** The pickup a till writes from a ticket: a sale paid from the balance. */
  function pickup(
    t: Ticket,
    tweak?: (lines: Record<string, unknown>[]) => void,
  ) {
    const input = t.lines.map((l) => ({
      lineNo: l.lineNo,
      unitPriceCents: l.unitPriceCents,
      quantity: l.quantity,
      ivaBp: l.ivaBp,
      iepsBp: l.iepsBp,
    }));
    const totals = computeSaleTotals(input);
    const lines: Record<string, unknown>[] = t.lines.map((l, i) => ({
      ...l,
      ...totals.lines[i],
      dayOld: false,
      fullPriceCents: l.unitPriceCents,
      discount: null,
    }));
    tweak?.(lines);
    const folioNumber = till.next++;
    return record('sale.completed', {
      folio: `${till.prefix}-${String(folioNumber).padStart(6, '0')}`,
      folioNumber,
      cashierStaffId: cashierId,
      shiftId: till.shiftId,
      orderTicketId: t.id,
      lines,
      orderDiscount: null,
      voidedLines: [],
      grossCents: totals.grossCents,
      discountCents: totals.discountCents,
      totalCents: totals.totalCents,
      payments: [
        {
          method: 'PREPAID',
          amountCents: totals.totalCents,
          tenderedCents: 0,
          changeCents: 0,
        },
      ],
    });
  }

  beforeAll(async () => {
    branchId = (
      await prisma.branch.create({
        data: {
          id: uuidv7(),
          code: `O${tag().toUpperCase()}`,
          name: 'Pedidos',
          timezone: TZ,
        },
      })
    ).id;
    const passwordHash = await hashPassword(password);
    const staff = async (role: Role) => {
      const { pinHash, offlinePinVerifier } = await hashPin('1234');
      return prisma.staff.create({
        data: {
          id: uuidv7(),
          fullName: `Pedidos ${role}`,
          displayName: role,
          role,
          email: `${tag()}-pedidos@bakery.local`,
          passwordHash,
          pinHash,
          offlinePinVerifier,
          pinUpdatedAt: new Date(),
          staffBranches: { create: [{ branchId }] },
        },
      });
    };
    const manager = await staff(Role.BRANCH_MANAGER);
    const cashier = await staff(Role.CASHIER);
    cashierId = cashier.id;
    bakerId = (await staff(Role.BAKER)).id;
    const categoryId = (
      await prisma.category.create({
        data: { id: uuidv7(), name: `Pedidos ${tag()}` },
      })
    ).id;
    const variant = async (name: string, priceCents: number) => {
      const p = await prisma.product.create({
        data: {
          id: uuidv7(),
          categoryId,
          name,
          unit: 'PIECE',
          ivaRateId: IVA0,
        },
      });
      return (
        await prisma.productVariant.create({
          data: { id: uuidv7(), productId: p.id, name: 'Pieza', priceCents },
        })
      ).id;
    };
    bolillo = await variant(`Bolillo ${tag()}`, 250);
    concha = await variant(`Concha ${tag()}`, 1500);

    const token = randomBytes(32).toString('hex');
    const device = await prisma.device.create({
      data: {
        id: uuidv7(),
        branchId,
        name: `Caja ${tag()}`,
        type: 'TILL',
        status: 'ACTIVE',
        tokenHash: hashTokenWithPepper(token, process.env.DEVICE_TOKEN_PEPPER!),
      },
    });
    const shift = await prisma.cashShift.create({
      data: {
        id: uuidv7(),
        deviceId: device.id,
        branchId,
        openedAt: new Date('2026-11-09T12:00:00Z'),
        openedByStaffId: cashierId,
        floatCents: 0,
      },
    });
    till = {
      token,
      id: device.id,
      prefix: device.folioPrefix!,
      next: 1,
      shiftId: shift.id,
    };

    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleRef.createNestApplication();
    configureApp(app);
    await app.init();
    server = app.getHttpServer() as Server;
    clock = app.get(ClockService);
    clock.setNow(MONDAY);
    const login = async (email: string | null) =>
      (
        (
          await request(server)
            .post('/v1/auth/password-login')
            .send({ email, password })
        ).body as { accessToken: string }
      ).accessToken;
    managerToken = await login(manager.email);
    cashierToken = await login(cashier.email);
  });

  afterAll(async () => {
    clock?.setNow(null);
    await app?.close();
    await prisma.$disconnect();
  });

  it('G1: a customer is found by part of the name or the phone', async () => {
    await customer(`Señora Lupita ${tag()}`, `55${Date.now() % 100000000}`);
    const phone = `55${(Date.now() + 7) % 100000000}`;
    await customer(`Don Beto ${tag()}`, phone);
    const byName = await request(server)
      .get('/v1/customers')
      .query({ q: 'lupi' })
      .set(as(cashierToken));
    expect(byName.status).toBe(200);
    valid('/v1/customers', 'GET', byName);
    expect(
      (byName.body as { items: { name: string }[] }).items.some((c) =>
        c.name.startsWith('Señora Lupita'),
      ),
    ).toBe(true);
    const byPhone = await request(server)
      .get('/v1/customers')
      .query({ q: phone.slice(-6) })
      .set(as(cashierToken));
    expect(
      (byPhone.body as { items: { phone: string }[] }).items.map(
        (c) => c.phone,
      ),
    ).toContain(phone);
    const cashierCreates = await request(server)
      .post('/v1/customers')
      .set(as(cashierToken))
      .send({ name: 'Nadie' });
    expect(cashierCreates.status).toBe(403);
  });

  it('G3, G4, G6: weekday tickets, a prepayment, and a pickup from the balance', async () => {
    const c = await customer(`Fonda ${tag()}`);
    await order({
      customerId: c,
      lines: [{ variantId: bolillo, quantity: 30 }],
    });
    // Monday to Friday from Monday: Mon, Tue, Wed are kept (today + 2).
    const mine = (await tickets()).filter((t) => t.customerId === c);
    expect(mine.map((t) => t.dueDate)).toEqual([
      '2026-11-09',
      '2026-11-10',
      '2026-11-11',
    ]);
    expect(mine[0].totalCents).toBe(7500);

    expect((await pushOne(prepaid(c, 37500))).status).toBe('APPLIED');
    expect(await balance(c)).toBe(37500);

    const lot = record('stock.produced', {
      variantId: bolillo,
      quantity: 100,
      producedOn: '2026-11-09',
      staffId: bakerId,
    });
    expect((await pushOne(lot)).status).toBe('APPLIED');

    const res = await pushOne(pickup(mine[0]));
    expect(res.status).toBe('APPLIED');
    expect(await balance(c)).toBe(30000);
    const t = await prisma.orderTicket.findUniqueOrThrow({
      where: { id: mine[0].id },
    });
    expect(t.status).toBe('PICKED_UP');
    expect(
      (await prisma.stockLot.findUniqueOrThrow({ where: { id: lot.id } }))
        .quantityLeft,
    ).toBe(70);

    // Expected cash counts the prepayment and not the pickup.
    const close = record('shift.closed', {
      shiftId: till.shiftId,
      zNumber: 1,
      staffId: cashierId,
      count: [{ denominationCents: 50, quantity: 750 }],
      countedCents: 37500,
      expectedCents: 37500,
      varianceCents: 0,
      flagged: false,
      note: null,
    });
    expect((await pushOne(close)).status).toBe('APPLIED');
    const shift = await prisma.cashShift.findUniqueOrThrow({
      where: { id: till.shiftId },
    });
    expect(shift.expectedCents).toBe(37500);
    // A new shift for the tests after this one.
    till.shiftId = (
      await prisma.cashShift.create({
        data: {
          id: uuidv7(),
          deviceId: till.id,
          branchId,
          openedAt: MONDAY,
          openedByStaffId: cashierId,
          floatCents: 0,
        },
      })
    ).id;
  });

  it('G7: a changed pickup or a second pickup of a ticket is quarantined', async () => {
    const c = await customer(`Cafe ${tag()}`);
    await order({
      customerId: c,
      lines: [{ variantId: concha, quantity: 2 }],
    });
    const [t] = (await tickets()).filter((x) => x.customerId === c);
    const more = await pushOne(
      pickup(t, (lines) => {
        lines[0].quantity = 3;
        lines[0].grossCents = 4500;
        lines[0].netCents = 4500;
        lines[0].baseCents = 4500;
      }),
    );
    expect(more.status).toBe('QUARANTINED');

    expect((await pushOne(pickup(t))).status).toBe('APPLIED');
    const twice = await pushOne(pickup(t));
    expect(twice.status).toBe('QUARANTINED');
    expect(twice.message).toContain('already PICKED_UP');
    expect(await balance(c)).toBe(-3000);
  });

  it('G8: a missed ticket is charged with CHARGE, not with NO_CHARGE, and no stock moves', async () => {
    const charged = await customer(`Hotel ${tag()}`);
    const free = await customer(`Escuela ${tag()}`);
    await order({
      customerId: charged,
      lines: [{ variantId: concha, quantity: 1 }],
    });
    await order({
      customerId: free,
      missedRule: 'NO_CHARGE',
      lines: [{ variantId: concha, quantity: 1 }],
    });
    const events = await prisma.stockEvent.count({
      where: { variantId: concha },
    });
    clock.setNow(new Date('2026-11-10T18:00:00Z'));
    try {
      await app.get(OrdersService).runNightly();
    } finally {
      clock.setNow(MONDAY);
    }
    expect(await balance(charged)).toBe(-1500);
    expect(await balance(free)).toBe(0);
    const statuses = await prisma.orderTicket.findMany({
      where: {
        customerId: { in: [charged, free] },
        dueDate: new Date('2026-11-09'),
      },
    });
    expect(statuses.map((t) => t.status)).toEqual(['MISSED', 'MISSED']);
    expect(
      await prisma.stockEvent.count({ where: { variantId: concha } }),
    ).toBe(events);
  });

  it('G3, G9: skipping, pausing and changing rebuild only pending tickets', async () => {
    const c = await customer(`Tienda ${tag()}`);
    const id = await order({
      customerId: c,
      weekdays: 127,
      lines: [{ variantId: bolillo, quantity: 10 }],
    });
    const mine = async () =>
      (await tickets()).filter((t) => t.customerId === c);
    expect((await mine()).map((t) => t.dueDate)).toEqual([
      '2026-11-09',
      '2026-11-10',
      '2026-11-11',
    ]);
    expect((await pushOne(pickup((await mine())[0]))).status).toBe('APPLIED');

    const skipped = await request(server)
      .post(`/v1/orders/${id}/skips`)
      .set(as(managerToken))
      .send({ date: '2026-11-10' });
    expect(skipped.status).toBe(200);
    valid('/v1/orders/{orderId}/skips', 'POST', skipped);
    expect((await mine()).map((t) => t.dueDate)).toEqual([
      '2026-11-09',
      '2026-11-11',
    ]);

    const changed = await request(server)
      .put(`/v1/orders/${id}`)
      .set(as(managerToken))
      .send({
        weekdays: 127,
        startDate: '2026-11-09',
        pickupTime: '08:00',
        missedRule: 'CHARGE',
        lines: [{ variantId: bolillo, quantity: 20 }],
      });
    expect(changed.status).toBe(200);
    const after = await mine();
    expect(after.find((t) => t.dueDate === '2026-11-09')!.totalCents).toBe(
      2500,
    );
    expect(after.find((t) => t.dueDate === '2026-11-11')!.totalCents).toBe(
      5000,
    );

    const paused = await request(server)
      .post(`/v1/orders/${id}/pause`)
      .set(as(managerToken))
      .send({ from: '2026-11-11', until: null });
    expect(paused.status).toBe(200);
    expect((await mine()).map((t) => t.dueDate)).toEqual(['2026-11-09']);
  });

  it('G10: a cake for Wednesday with a deposit makes one ticket', async () => {
    const c = await customer(`Boda ${tag()}`);
    await order({
      customerId: c,
      kind: 'ONE_OFF',
      weekdays: 0,
      startDate: '2026-11-11',
      lines: [{ variantId: concha, quantity: 1 }],
    });
    await pushOne(prepaid(c, 500));
    const mine = (await tickets()).filter((t) => t.customerId === c);
    expect(mine.map((t) => t.dueDate)).toEqual(['2026-11-11']);
    const early = await pushOne(pickup(mine[0]));
    expect(early.message).toContain('not due yet');

    const detail = await request(server)
      .get(`/v1/customers/${c}`)
      .set(as(cashierToken));
    expect(detail.status).toBe(200);
    valid('/v1/customers/{customerId}', 'GET', detail);
    expect((detail.body as { balanceCents: number }).balanceCents).toBe(500);
  });

  it('M7.4: the pick list adds the day up', async () => {
    const res = await request(server)
      .get('/v1/orders/pick-list')
      .query({ branchId, date: '2026-11-10' })
      .set(as(cashierToken));
    expect(res.status).toBe(200);
    valid('/v1/orders/pick-list', 'GET', res);
    const body = res.body as {
      totals: { variantId: string; quantity: number }[];
      tickets: Ticket[];
    };
    const sum = body.tickets
      .flatMap((t) => t.lines)
      .filter((l) => l.variantId === bolillo)
      .reduce((a, l) => a + l.quantity, 0);
    expect(body.totals.find((t) => t.variantId === bolillo)?.quantity).toBe(
      sum,
    );
  });

  it.each([
    'UPDATE "prepaid_entry" SET "amount_cents" = 0',
    'DELETE FROM "prepaid_entry"',
    'DELETE FROM "order_ticket"',
  ])('G11: the app role is refused: %s', async (sql) => {
    await expect(prisma.$executeRawUnsafe(sql)).rejects.toThrow(
      /permission denied/,
    );
  });
});
