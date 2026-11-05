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
import { localDay } from '../src/common/local-day';
import { computeSaleTotals } from '../src/sales/sale-totals';
import { dayOldPrice, daysBefore } from '../src/stock/fifo';
import { StockService } from '../src/stock/stock.service';
import { validateResponseAgainstContract } from './contract-validator';

const IVA0 = '019a1e00-0000-7000-8000-000000000001';
const TZ = 'America/Mexico_City';
const tag = () => randomBytes(4).toString('hex');

interface PushResult {
  id: string;
  status: string;
  errorCode: string | null;
  message: string | null;
}

interface Till {
  token: string;
  id: string;
  prefix: string;
  next: number;
  shiftId: string;
}

describe('Stock (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  const prisma = new PrismaClient();
  let branchId: string;
  let otherBranchId: string;
  let ownerToken: string;
  let otherManagerToken: string;
  let managerId: string;
  let cashierId: string;
  let bakerId: string;
  let categoryId: string;
  let till: Till;
  let tillB: Till;
  let otherTill: Till;
  const password = 'StockPass123!';
  const today = () => localDay(new Date(), TZ);

  async function push(t: Till, records: unknown[]) {
    const res = await request(server)
      .post('/v1/sync/push')
      .set('X-Device-Token', t.token)
      .send({ records });
    expect(res.status).toBe(200);
    return (res.body as { results: PushResult[] }).results;
  }

  const pushOne = async (t: Till, r: unknown) => (await push(t, [r]))[0];

  const record = (type: string, payload: Record<string, unknown>) => ({
    id: uuidv7(),
    type,
    occurredAt: new Date().toISOString(),
    payload,
  });

  const produced = (variantId: string, quantity: number, producedOn: string) =>
    record('stock.produced', {
      variantId,
      quantity,
      producedOn,
      staffId: bakerId,
    });

  async function variant(
    rule: {
      dayOldDiscountAfterDays?: number;
      dayOldDiscountBp?: number;
      dayOldWasteAfterDays?: number;
    } = {},
    costCents: number | null = null,
  ) {
    const product = await prisma.product.create({
      data: {
        id: uuidv7(),
        categoryId,
        name: `Pan ${tag()}`,
        unit: 'PIECE',
        ivaRateId: IVA0,
        ...rule,
      },
    });
    const v = await prisma.productVariant.create({
      data: {
        id: uuidv7(),
        productId: product.id,
        name: 'Pieza',
        priceCents: 1000,
        costCents,
      },
    });
    return v.id;
  }

  function sale(
    t: Till,
    variantId: string,
    quantity: number,
    opts: { dayOldBp?: number } = {},
  ) {
    const folioNumber = t.next++;
    const dayOld = opts.dayOldBp != null;
    const price = dayOld ? dayOldPrice(1000, opts.dayOldBp!) : 1000;
    const line = {
      lineNo: 1,
      unitPriceCents: price,
      quantity,
      ivaBp: 0,
      iepsBp: 0,
    };
    const totals = computeSaleTotals([line]);
    return record('sale.completed', {
      folio: `${t.prefix}-${String(folioNumber).padStart(6, '0')}`,
      folioNumber,
      cashierStaffId: cashierId,
      shiftId: t.shiftId,
      lines: [
        {
          ...line,
          ...totals.lines[0],
          dayOld,
          fullPriceCents: 1000,
          variantId,
          productName: 'Pan',
          variantName: 'Pieza',
          ivaRateId: IVA0,
          iepsRateId: null,
          discount: null,
        },
      ],
      orderDiscount: null,
      voidedLines: [],
      grossCents: totals.grossCents,
      discountCents: totals.discountCents,
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

  const lotLeft = async (id: string) =>
    (await prisma.stockLot.findUniqueOrThrow({ where: { id } })).quantityLeft;

  const onHand = async (variantId: string, branch = branchId) =>
    (
      await prisma.stockEvent.aggregate({
        where: { branchId: branch, variantId },
        _sum: { quantity: true },
      })
    )._sum.quantity ?? 0;

  async function newTill(inBranch: string, opener: string): Promise<Till> {
    const token = randomBytes(32).toString('hex');
    const device = await prisma.device.create({
      data: {
        id: uuidv7(),
        branchId: inBranch,
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
        branchId: inBranch,
        openedAt: new Date(0),
        openedByStaffId: opener,
        floatCents: 0,
      },
    });
    return {
      token,
      id: device.id,
      prefix: device.folioPrefix!,
      next: 1,
      shiftId: shift.id,
    };
  }

  beforeAll(async () => {
    const branch = async (code: string) =>
      (
        await prisma.branch.create({
          data: { id: uuidv7(), code, name: 'Stock', timezone: TZ },
        })
      ).id;
    branchId = await branch(`S${tag().toUpperCase()}`);
    otherBranchId = await branch(`R${tag().toUpperCase()}`);
    const passwordHash = await hashPassword(password);
    const staff = async (role: Role, inBranch: string, withEmail = false) => {
      const { pinHash, offlinePinVerifier } = await hashPin('1234');
      return prisma.staff.create({
        data: {
          id: uuidv7(),
          fullName: `Stock ${role}`,
          displayName: role,
          role,
          email: withEmail ? `${tag()}-stock@bakery.local` : null,
          passwordHash: withEmail ? passwordHash : null,
          pinHash,
          offlinePinVerifier,
          pinUpdatedAt: new Date(),
          staffBranches: { create: [{ branchId: inBranch }] },
        },
      });
    };
    const owner = await staff(Role.OWNER, branchId, true);
    const otherManager = await staff(Role.BRANCH_MANAGER, otherBranchId, true);
    managerId = (await staff(Role.BRANCH_MANAGER, branchId)).id;
    cashierId = (await staff(Role.CASHIER, branchId)).id;
    bakerId = (await staff(Role.BAKER, branchId)).id;
    categoryId = (
      await prisma.category.create({
        data: { id: uuidv7(), name: `Stock ${tag()}` },
      })
    ).id;
    till = await newTill(branchId, cashierId);
    tillB = await newTill(branchId, cashierId);
    otherTill = await newTill(otherBranchId, otherManager.id);

    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleRef.createNestApplication();
    configureApp(app);
    await app.init();
    server = app.getHttpServer() as Server;
    const login = async (email: string | null) =>
      (
        (
          await request(server)
            .post('/v1/auth/password-login')
            .send({ email, password })
        ).body as { accessToken: string }
      ).accessToken;
    ownerToken = await login(owner.email);
    otherManagerToken = await login(otherManager.email);
  });

  afterAll(async () => {
    await app?.close();
    await prisma.$disconnect();
  });

  it('F1: production makes a dated lot; a cashier cannot enter it', async () => {
    const v = await variant();
    const r = produced(v, 12, today());
    expect((await pushOne(till, r)).status).toBe('APPLIED');
    const lot = await prisma.stockLot.findUniqueOrThrow({
      where: { id: r.id },
    });
    expect(lot.quantityLeft).toBe(12);
    expect(lot.producedOn.toISOString().slice(0, 10)).toBe(today());
    expect(await onHand(v)).toBe(12);

    const denied = record('stock.produced', {
      variantId: v,
      quantity: 1,
      producedOn: today(),
      staffId: cashierId,
    });
    expect((await pushOne(till, denied)).message).toContain(
      'lacks stock.production_entry',
    );
  });

  it('F3: a sale takes the oldest lot and past zero it still goes through', async () => {
    const v = await variant();
    const old = produced(v, 3, daysBefore(today(), 1));
    const fresh = produced(v, 2, today());
    await push(till, [fresh, old]);

    expect((await pushOne(till, sale(till, v, 4))).status).toBe('APPLIED');
    expect(await lotLeft(old.id)).toBe(0);
    expect(await lotLeft(fresh.id)).toBe(1);

    expect((await pushOne(till, sale(till, v, 5))).status).toBe('APPLIED');
    expect(await lotLeft(fresh.id)).toBe(0);
    expect(await onHand(v)).toBe(-4);
  });

  it('F3, F11: a day-old sale takes only aged lots and stores the full price', async () => {
    const v = await variant({
      dayOldDiscountAfterDays: 1,
      dayOldDiscountBp: 3000,
    });
    const old = produced(v, 2, daysBefore(today(), 1));
    const fresh = produced(v, 5, today());
    await push(till, [old, fresh]);

    const s = sale(till, v, 3, { dayOldBp: 3000 });
    expect((await pushOne(till, s)).status).toBe('APPLIED');
    expect(await lotLeft(old.id)).toBe(0);
    expect(await lotLeft(fresh.id)).toBe(5);
    const line = await prisma.saleLine.findFirstOrThrow({
      where: { saleId: s.id },
    });
    expect(line).toMatchObject({
      dayOld: true,
      fullPriceCents: 1000,
      unitPriceCents: 700,
    });

    const wrong = sale(till, v, 1, { dayOldBp: 1000 });
    expect((await pushOne(till, wrong)).message).toContain(
      'day-old price does not match',
    );
  });

  it('F4: two tills sell the last units offline; every sale stands and on-hand equals the ledger', async () => {
    const v = await variant();
    const lot = produced(v, 5, today());
    await pushOne(till, lot);
    const [a, b] = await Promise.all([
      push(till, [sale(till, v, 4), sale(till, v, 1)]),
      push(tillB, [sale(tillB, v, 4), sale(tillB, v, 1)]),
    ]);
    expect([...a, ...b].every((r) => r.status === 'APPLIED')).toBe(true);
    expect(await lotLeft(lot.id)).toBe(0);
    expect(await onHand(v)).toBe(-5);
    const check = await app.get(StockService).runCheck();
    expect(check.mismatches).toBe(0);
  });

  it('F5: waste needs a reason, lowers stock and reports its cost', async () => {
    const v = await variant({}, 400);
    const noCost = await variant();
    await push(till, [produced(v, 5, today()), produced(noCost, 5, today())]);
    const bad = record('stock.wasted', {
      variantId: v,
      quantity: 1,
      staffId: bakerId,
    });
    expect((await pushOne(till, bad)).errorCode).toBe('SYNC_INVALID_PAYLOAD');
    const waste = (variantId: string) =>
      record('stock.wasted', {
        variantId,
        quantity: 2,
        reason: 'BURNT',
        lotId: null,
        staffId: bakerId,
      });
    await push(till, [waste(v), waste(noCost)]);
    expect(await onHand(v)).toBe(3);

    const res = await request(server)
      .get('/v1/stock/waste')
      .query({ branchId, reason: 'BURNT' })
      .set('Authorization', `Bearer ${ownerToken}`);
    expect(res.status).toBe(200);
    expect(
      validateResponseAgainstContract({
        path: '/v1/stock/waste',
        method: 'GET',
        status: 200,
        body: res.body,
      }).errors ?? [],
    ).toEqual([]);
    const body = res.body as {
      items: { variantId: string; costCents: number | null }[];
      totalCostCents: number;
    };
    expect(body.items.find((i) => i.variantId === v)?.costCents).toBe(400);
    expect(
      body.items.find((i) => i.variantId === noCost)?.costCents,
    ).toBeNull();
    expect(body.totalCostCents).toBe(800);
  });

  it('F6: 10 sent, 9 received: both recorded, 9 added, flagged, date kept', async () => {
    const v = await variant();
    const day = daysBefore(today(), 1);
    await pushOne(till, produced(v, 12, day));
    const sent = await request(server)
      .post('/v1/stock/transfers')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        fromBranchId: branchId,
        toBranchId: otherBranchId,
        lines: [{ variantId: v, quantity: 10 }],
      });
    expect(sent.status).toBe(201);
    expect(
      validateResponseAgainstContract({
        path: '/v1/stock/transfers',
        method: 'POST',
        status: 201,
        body: sent.body,
      }).errors ?? [],
    ).toEqual([]);
    const t = sent.body as { id: string };
    expect(await onHand(v)).toBe(2);
    expect(await onHand(v, otherBranchId)).toBe(0);

    const tooMuch = await request(server)
      .post('/v1/stock/transfers')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        fromBranchId: branchId,
        toBranchId: otherBranchId,
        lines: [{ variantId: v, quantity: 3 }],
      });
    expect(tooMuch.status).toBe(409);
    expect(await onHand(v)).toBe(2);

    const received = await request(server)
      .post(`/v1/stock/transfers/${t.id}/receive`)
      .set('Authorization', `Bearer ${otherManagerToken}`)
      .send({
        lines: [{ variantId: v, producedOn: day, quantityReceived: 9 }],
      });
    expect(received.status).toBe(200);
    const body = received.body as {
      flagged: boolean;
      lines: { quantitySent: number; quantityReceived: number }[];
    };
    expect(body.flagged).toBe(true);
    expect(body.lines[0]).toMatchObject({
      quantitySent: 10,
      quantityReceived: 9,
    });
    expect(await onHand(v, otherBranchId)).toBe(9);
    const lot = await prisma.stockLot.findFirstOrThrow({
      where: { branchId: otherBranchId, variantId: v },
    });
    expect(lot.producedOn.toISOString().slice(0, 10)).toBe(day);
    expect(
      await prisma.auditLog.count({
        where: { entityId: t.id, action: 'stock.transfer_mismatch' },
      }),
    ).toBe(1);

    const twice = await request(server)
      .post(`/v1/stock/transfers/${t.id}/receive`)
      .set('Authorization', `Bearer ${otherManagerToken}`)
      .send({
        lines: [{ variantId: v, producedOn: day, quantityReceived: 9 }],
      });
    expect(twice.status).toBe(409);
  });

  it('F7: a count writes one adjustment per variant with the difference', async () => {
    const down = await variant();
    const up = await variant();
    const same = await variant();
    await push(till, [
      produced(down, 10, today()),
      produced(up, 2, today()),
      produced(same, 4, today()),
    ]);
    await pushOne(till, sale(till, up, 5));
    const count = record('stock.counted', {
      staffId: managerId,
      lines: [
        { variantId: down, counted: 7 },
        { variantId: up, counted: 6 },
        { variantId: same, counted: 4 },
      ],
    });
    expect((await pushOne(till, count)).status).toBe('APPLIED');
    expect(await onHand(down)).toBe(7);
    expect(await onHand(up)).toBe(6);
    expect(await onHand(same)).toBe(4);
    const audits = await prisma.auditLog.findMany({
      where: { entityId: count.id, action: 'stock.count_adjusted' },
    });
    expect(audits).toHaveLength(2);
    expect(audits.every((a) => a.actorStaffId === managerId)).toBe(true);
    const denied = record('stock.counted', {
      staffId: cashierId,
      lines: [{ variantId: down, counted: 1 }],
    });
    expect((await pushOne(till, denied)).message).toContain(
      'lacks stock.count_adjust',
    );
  });

  it('F13: a refund marked to return adds units to its lot; unmarked changes nothing', async () => {
    const v = await variant();
    const lot = produced(v, 3, today());
    await pushOne(till, lot);
    const s = sale(till, v, 3);
    await pushOne(till, s);
    const refund = (quantity: number, restock: boolean) =>
      record('sale.refunded', {
        saleId: s.id,
        shiftId: till.shiftId,
        kind: 'REFUND',
        reason: 'CUSTOMER_RETURN',
        note: null,
        staffId: cashierId,
        approverStaffId: managerId,
        lines: [
          {
            lineNo: 1,
            quantity,
            amountCents: quantity * 1000,
            baseCents: quantity * 1000,
            iepsCents: 0,
            ivaCents: 0,
            restock,
          },
        ],
        totalCents: quantity * 1000,
      });
    expect((await pushOne(till, refund(1, false))).status).toBe('APPLIED');
    expect(await onHand(v)).toBe(0);
    expect((await pushOne(till, refund(2, true))).status).toBe('APPLIED');
    expect(await onHand(v)).toBe(2);
    expect(await lotLeft(lot.id)).toBe(2);
  });

  it('M6: levels split fresh, day-old and waste due by age at the branch', async () => {
    const v = await variant({
      dayOldDiscountAfterDays: 1,
      dayOldDiscountBp: 3000,
      dayOldWasteAfterDays: 3,
    });
    await push(till, [
      produced(v, 4, today()),
      produced(v, 3, daysBefore(today(), 1)),
      produced(v, 2, daysBefore(today(), 3)),
    ]);
    const res = await request(server)
      .get('/v1/stock/levels')
      .query({ branchId })
      .set('Authorization', `Bearer ${ownerToken}`);
    expect(res.status).toBe(200);
    expect(
      validateResponseAgainstContract({
        path: '/v1/stock/levels',
        method: 'GET',
        status: 200,
        body: res.body,
      }).errors ?? [],
    ).toEqual([]);
    const row = (res.body as { items: { variantId: string }[] }).items.find(
      (i) => i.variantId === v,
    );
    expect(row).toMatchObject({
      onHand: 9,
      freshUnits: 4,
      dayOldUnits: 5,
      wasteDueUnits: 2,
    });

    const lots = await request(server)
      .get('/v1/stock/lots')
      .set('X-Device-Token', till.token);
    expect(lots.status).toBe(200);
    expect(
      validateResponseAgainstContract({
        path: '/v1/stock/lots',
        method: 'GET',
        status: 200,
        body: lots.body,
      }).errors ?? [],
    ).toEqual([]);
    const seen = (lots.body as { lots: { variantId: string }[] }).lots;
    expect(seen.filter((l) => l.variantId === v)).toHaveLength(3);
    const other = await request(server)
      .get('/v1/stock/levels')
      .query({ branchId })
      .set('Authorization', `Bearer ${otherManagerToken}`);
    expect(other.status).toBe(403);
    expect(otherTill.prefix).toBeDefined();
  });

  it('F9: the nightly check finds an altered lot, reports it and changes nothing', async () => {
    const v = await variant();
    const r = produced(v, 5, today());
    await pushOne(till, r);
    const clean = await app.get(StockService).runCheck();
    expect(clean.mismatches).toBe(0);

    await prisma.stockLot.update({
      where: { id: r.id },
      data: { quantityLeft: 4 },
    });
    const dirty = await app.get(StockService).runCheck();
    expect(dirty.mismatches).toBe(1);
    expect(await lotLeft(r.id)).toBe(4);
    expect(
      await prisma.auditLog.count({
        where: { entityId: r.id, action: 'stock.ledger_mismatch' },
      }),
    ).toBe(1);
    const latest = await request(server)
      .get('/v1/stock/checks/latest')
      .set('Authorization', `Bearer ${ownerToken}`);
    expect((latest.body as { mismatches: number }).mismatches).toBe(1);
    await prisma.stockLot.update({
      where: { id: r.id },
      data: { quantityLeft: 5 },
    });
  });

  it.each([
    'UPDATE "stock_event" SET "quantity" = 0',
    'DELETE FROM "stock_event"',
    'DELETE FROM "stock_lot"',
    'UPDATE "stock_waste" SET "quantity" = 0',
    'DELETE FROM "stock_transfer"',
  ])('F8: the app role is refused: %s', async (sql) => {
    await expect(prisma.$executeRawUnsafe(sql)).rejects.toThrow(
      /permission denied/,
    );
  });
});
