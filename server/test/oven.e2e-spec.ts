import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { PrismaClient, Role } from '@prisma/client';
import { randomBytes } from 'crypto';
import type { Server } from 'http';
import request from 'supertest';
import { v7 as uuidv7 } from 'uuid';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import {
  hashPassword,
  hashPin,
  hashTokenWithPepper,
} from '../src/common/crypto';
import { computeSaleTotals } from '../src/sales/sale-totals';
import { validateResponseAgainstContract } from './contract-validator';

const IVA16 = '019a1e00-0000-7000-8000-000000000002';
const tag = () => randomBytes(4).toString('hex');

interface Rule {
  id: string;
  variantId: string;
  ivaRateId: string;
  ivaBp: number;
}

describe('Oven service (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  const prisma = new PrismaClient();
  let branchId: string;
  let ownerToken: string;
  let cashierId: string;
  let bakerId: string;
  let rule: Rule;
  let till: { token: string; prefix: string; next: number; shiftId: string };
  const password = 'OvenPass123!';

  const valid = (path: string, method: string, res: request.Response) =>
    expect(
      validateResponseAgainstContract({
        path,
        method,
        status: res.status,
        body: res.body,
      }).errors ?? [],
    ).toEqual([]);

  async function pushOne(record: unknown) {
    const res = await request(server)
      .post('/v1/sync/push')
      .set('X-Device-Token', till.token)
      .send({ records: [record] });
    return (res.body as { results: { status: string; message: string }[] })
      .results[0];
  }

  const record = (type: string, payload: Record<string, unknown>) => ({
    id: uuidv7(),
    type,
    occurredAt: new Date().toISOString(),
    payload,
  });

  /** The fee as a sale of the rule's hidden service product. */
  function feeSale(feeCents: number) {
    const line = {
      lineNo: 1,
      unitPriceCents: feeCents,
      quantity: 1,
      ivaBp: rule.ivaBp,
      iepsBp: 0,
    };
    const totals = computeSaleTotals([line]);
    const folioNumber = till.next++;
    return record('sale.completed', {
      folio: `${till.prefix}-${String(folioNumber).padStart(6, '0')}`,
      folioNumber,
      cashierStaffId: cashierId,
      shiftId: till.shiftId,
      lines: [
        {
          ...line,
          ...totals.lines[0],
          dayOld: false,
          fullPriceCents: feeCents,
          variantId: rule.variantId,
          productName: 'Servicio de horno',
          variantName: 'Pierna',
          ivaRateId: rule.ivaRateId,
          iepsRateId: null,
          discount: null,
        },
      ],
      orderDiscount: null,
      voidedLines: [],
      grossCents: totals.grossCents,
      discountCents: 0,
      totalCents: totals.totalCents,
      payments: [
        {
          method: 'CASH',
          amountCents: totals.totalCents,
          tenderedCents: totals.totalCents,
          changeCents: 0,
        },
      ],
    });
  }

  const received = (extra: Record<string, unknown> = {}) =>
    record('oven.received', {
      tag: String(Math.floor(Math.random() * 900) + 100),
      customerName: 'Señora Pérez',
      phone: '5512345678',
      description: 'Pierna en charola de aluminio',
      ruleId: rule.id,
      weightGrams: 3200,
      feeCents: 20800,
      requestedAt: new Date(Date.now() + 3 * 3_600_000).toISOString(),
      staffId: cashierId,
      feeSaleId: null,
      ...extra,
    });

  beforeAll(async () => {
    branchId = (
      await prisma.branch.create({
        data: { id: uuidv7(), code: `H${tag().toUpperCase()}`, name: 'Horno' },
      })
    ).id;
    const passwordHash = await hashPassword(password);
    const staff = async (role: Role) => {
      const { pinHash, offlinePinVerifier } = await hashPin('1234');
      return prisma.staff.create({
        data: {
          id: uuidv7(),
          fullName: `Horno ${role}`,
          displayName: role,
          role,
          email: `${tag()}-horno@bakery.local`,
          passwordHash,
          pinHash,
          offlinePinVerifier,
          pinUpdatedAt: new Date(),
          staffBranches: { create: [{ branchId }] },
        },
      });
    };
    const owner = await staff(Role.OWNER);
    cashierId = (await staff(Role.CASHIER)).id;
    bakerId = (await staff(Role.BAKER)).id;
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
        openedAt: new Date(0),
        openedByStaffId: cashierId,
        floatCents: 0,
      },
    });
    till = { token, prefix: device.folioPrefix!, next: 1, shiftId: shift.id };

    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleRef.createNestApplication();
    configureApp(app);
    await app.init();
    server = app.getHttpServer() as Server;
    ownerToken = (
      (
        await request(server)
          .post('/v1/auth/password-login')
          .send({ email: owner.email, password })
      ).body as { accessToken: string }
    ).accessToken;

    const created = await request(server)
      .post('/v1/oven/fees')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        name: `Pierna ${tag()}`,
        baseCents: 8000,
        perKgCents: 4000,
        ivaRateId: IVA16,
      });
    expect(created.status).toBe(201);
    valid('/v1/oven/fees', 'POST', created);
    rule = created.body as Rule;
  });

  afterAll(async () => {
    await app?.close();
    await prisma.$disconnect();
  });

  it('M8.5: dishes are refused until the branch turns the service on', async () => {
    const off = await pushOne(received());
    expect(off.status).toBe('QUARANTINED');
    expect(off.message).toContain('Oven service is off');
    const on = await request(server)
      .put(`/v1/oven/branches/${branchId}`)
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ enabled: true });
    expect(on.status).toBe(200);
  });

  it('M8.1: the fee is base plus price per kilo, and a wrong one is refused', async () => {
    const wrong = await pushOne(received({ feeCents: 20000 }));
    expect(wrong.message).toContain('expected 20800');
    const sale = feeSale(20800);
    expect((await pushOne(sale)).status).toBe('APPLIED');
    const ok = received({ feeSaleId: sale.id });
    expect((await pushOne(ok)).status).toBe('APPLIED');
    // A fee is a service: it takes no stock.
    expect(
      await prisma.stockEvent.count({ where: { variantId: rule.variantId } }),
    ).toBe(0);
    const reuse = await pushOne(received({ feeSaleId: sale.id }));
    expect(reuse.message).toContain('already pays a dish');
  });

  it('M8.2, M8.3: the board marks in oven and ready, and a late step never goes back', async () => {
    const dish = received({ feeSaleId: null });
    expect((await pushOne(dish)).status).toBe('APPLIED');
    const step = (status: string) =>
      record('oven.status', { ticketId: dish.id, status, staffId: bakerId });
    const late = step('IN_OVEN');
    expect((await pushOne(step('READY'))).status).toBe('APPLIED');
    expect((await pushOne(late)).status).toBe('APPLIED');
    const t = await prisma.ovenTicket.findUniqueOrThrow({
      where: { id: dish.id },
    });
    expect(t.status).toBe('READY');
    expect(t.readyAt).not.toBeNull();

    const board = await request(server)
      .get('/v1/oven/board')
      .set('X-Device-Token', till.token);
    expect(board.status).toBe(200);
    valid('/v1/oven/board', 'GET', board);
    const b = board.body as { enabled: boolean; tickets: { id: string }[] };
    expect(b.enabled).toBe(true);
    expect(b.tickets.map((x) => x.id)).toContain(dish.id);

    const cashierStep = record('oven.status', {
      ticketId: dish.id,
      status: 'READY',
      staffId: cashierId,
    });
    expect((await pushOne(cashierStep)).message).toContain('lacks oven.board');
  });

  it('M8.4: the fee is paid exactly once, at drop-off or at pickup', async () => {
    const unpaid = received();
    await pushOne(unpaid);
    const pickup = (feeSaleId: string | null) =>
      record('oven.picked_up', {
        ticketId: unpaid.id,
        staffId: cashierId,
        feeSaleId,
      });
    expect((await pushOne(pickup(null))).message).toContain('not paid');
    const sale = feeSale(20800);
    await pushOne(sale);
    expect((await pushOne(pickup(sale.id))).status).toBe('APPLIED');
    expect((await pushOne(pickup(null))).message).toContain(
      'already picked up',
    );
    const t = await prisma.ovenTicket.findUniqueOrThrow({
      where: { id: unpaid.id },
    });
    expect(t.feeSaleId).toBe(sale.id);

    const list = await request(server)
      .get('/v1/oven/tickets')
      .query({
        branchId,
        from: new Date(Date.now() - 86_400_000).toISOString().slice(0, 10),
        to: new Date(Date.now() + 86_400_000).toISOString().slice(0, 10),
      })
      .set('Authorization', `Bearer ${ownerToken}`);
    expect(list.status).toBe(200);
    valid('/v1/oven/tickets', 'GET', list);
  });
});
