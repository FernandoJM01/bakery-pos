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

const IVA0 = '019a1e00-0000-7000-8000-000000000001';
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
  z: number;
}

const COUNT_1000 = [{ denominationCents: 50000, quantity: 2 }];

describe('Cash shifts (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  const prisma = new PrismaClient();
  let branchId: string;
  let otherBranchId: string;
  let ownerToken: string;
  let managerToken: string;
  let managerId: string;
  let cashierId: string;
  let bakerId: string;
  let variantId: string;
  let till: Till;

  const password = 'ShiftsPass123!';

  async function push(token: string, records: unknown[]) {
    const res = await request(server)
      .post('/v1/sync/push')
      .set('X-Device-Token', token)
      .send({ records });
    expect(res.status).toBe(200);
    return (res.body as { results: PushResult[] }).results;
  }

  const pushOne = async (t: Till, record: unknown) =>
    (await push(t.token, [record]))[0];

  const record = (
    type: string,
    payload: Record<string, unknown>,
    at = new Date(),
  ) => ({
    id: uuidv7(),
    type,
    occurredAt: at.toISOString(),
    payload,
  });

  const opened = (staffId = cashierId, floatCents = 100000) =>
    record('shift.opened', { staffId, floatCents, count: COUNT_1000 });

  const movement = (
    shiftId: string,
    extra: Record<string, unknown> = {},
    staffId = managerId,
  ) =>
    record('cash.movement', {
      shiftId,
      kind: 'IN',
      amountCents: 20000,
      reason: 'CHANGE_FUND',
      note: null,
      staffId,
      approverStaffId: null,
      ...extra,
    });

  function sale(t: Till, shiftId: string, priceCents = 1500) {
    const folioNumber = t.next++;
    const line = {
      lineNo: 1,
      unitPriceCents: priceCents,
      quantity: 1,
      ivaBp: 0,
      iepsBp: 0,
    };
    const totals = computeSaleTotals([line]);
    return record('sale.completed', {
      folio: `${t.prefix}-${String(folioNumber).padStart(6, '0')}`,
      folioNumber,
      cashierStaffId: cashierId,
      shiftId,
      lines: [
        {
          ...line,
          ...totals.lines[0],
          dayOld: false,
          fullPriceCents: priceCents,
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

  const refund = (saleId: string, shiftId: string, amount: number) =>
    record('sale.refunded', {
      saleId,
      shiftId,
      kind: 'REFUND',
      reason: 'CUSTOMER_RETURN',
      note: null,
      staffId: cashierId,
      approverStaffId: managerId,
      lines: [
        {
          lineNo: 1,
          quantity: 1,
          amountCents: amount,
          baseCents: amount,
          iepsCents: 0,
          ivaCents: 0,
          restock: false,
        },
      ],
      totalCents: amount,
    });

  /** A `shift.closed` for what the server should expect, counted as given. */
  const closed = (
    t: Till,
    shiftId: string,
    expectedCents: number,
    countedCents: number,
    extra: Record<string, unknown> = {},
  ) => {
    const varianceCents = countedCents - expectedCents;
    const rows = [
      {
        denominationCents: 100000,
        quantity: Math.floor(countedCents / 100000),
      },
      { denominationCents: 50, quantity: (countedCents % 100000) / 50 },
    ];
    return record('shift.closed', {
      shiftId,
      zNumber: t.z,
      staffId: cashierId,
      count: rows,
      countedCents,
      expectedCents,
      varianceCents,
      flagged: Math.abs(varianceCents) > 5000,
      note: null,
      ...extra,
    });
  };

  async function newTill(inBranch: string): Promise<Till> {
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
    return { token, id: device.id, prefix: device.folioPrefix!, next: 1, z: 1 };
  }

  async function openShift(t: Till) {
    const r = opened();
    expect((await pushOne(t, r)).status).toBe('APPLIED');
    return r.id;
  }

  beforeAll(async () => {
    branchId = (
      await prisma.branch.create({
        data: { id: uuidv7(), code: `T${tag().toUpperCase()}`, name: 'Turnos' },
      })
    ).id;
    otherBranchId = (
      await prisma.branch.create({
        data: { id: uuidv7(), code: `U${tag().toUpperCase()}`, name: 'Otra' },
      })
    ).id;
    const passwordHash = await hashPassword(password);
    const staff = async (role: Role, inBranch: string, withEmail = false) => {
      const { pinHash, offlinePinVerifier } = await hashPin('1234');
      return prisma.staff.create({
        data: {
          id: uuidv7(),
          fullName: `Turnos ${role}`,
          displayName: role,
          role,
          email: withEmail ? `${tag()}-turnos@bakery.local` : null,
          passwordHash: withEmail ? passwordHash : null,
          pinHash,
          offlinePinVerifier,
          pinUpdatedAt: new Date(),
          staffBranches: { create: [{ branchId: inBranch }] },
        },
      });
    };
    const owner = await staff(Role.OWNER, branchId, true);
    const manager = await staff(Role.BRANCH_MANAGER, branchId, true);
    const otherManager = await staff(Role.BRANCH_MANAGER, otherBranchId, true);
    managerId = manager.id;
    cashierId = (await staff(Role.CASHIER, branchId)).id;
    bakerId = (await staff(Role.BAKER, branchId)).id;
    till = await newTill(branchId);

    const category = await prisma.category.create({
      data: { id: uuidv7(), name: `Turnos ${tag()}` },
    });
    const product = await prisma.product.create({
      data: {
        id: uuidv7(),
        categoryId: category.id,
        name: `Pan ${tag()}`,
        unit: 'PIECE',
        ivaRateId: IVA0,
      },
    });
    variantId = (
      await prisma.productVariant.create({
        data: {
          id: uuidv7(),
          productId: product.id,
          name: 'Pieza',
          priceCents: 1500,
        },
      })
    ).id;

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
    managerToken = await login(manager.email);
    otherManagerToken = await login(otherManager.email);
  });
  let otherManagerToken: string;

  afterAll(async () => {
    await app?.close();
    await prisma.$disconnect();
  });

  it('E1: the server rejects a sale or refund with no shift, or another till’s', async () => {
    const t = await newTill(branchId);
    const shiftId = await openShift(t);
    const bad = sale(t, shiftId);
    delete bad.payload.shiftId;
    const res = await pushOne(t, bad);
    expect(res.status).toBe('QUARANTINED');
    expect(res.errorCode).toBe('SYNC_INVALID_PAYLOAD');

    const other = await newTill(branchId);
    const foreign = await pushOne(other, sale(other, shiftId));
    expect(foreign.status).toBe('QUARANTINED');
    expect(foreign.message).toContain('Shift not found');
  });

  it('E2: a second open is refused and a wrong count is rejected', async () => {
    const t = await newTill(branchId);
    await openShift(t);
    const again = await pushOne(t, opened());
    expect(again.status).toBe('QUARANTINED');
    expect(again.message).toContain('already has an open shift');

    const u = await newTill(branchId);
    const off = await pushOne(u, opened(cashierId, 99999));
    expect(off.message).toContain('does not add up');
    const baker = await pushOne(u, opened(bakerId));
    expect(baker.message).toContain('lacks cash.open_shift');
  });

  it('E4: a cashier needs a manager for a movement; every field is stored', async () => {
    const shiftId = await openShift(till);
    const alone = await pushOne(till, movement(shiftId, {}, cashierId));
    expect(alone.status).toBe('QUARANTINED');
    expect(alone.message).toContain('lacks cash.movement');

    const noNote = await pushOne(till, movement(shiftId, { reason: 'OTHER' }));
    expect(noNote.message).toContain('note is required');

    const ok = movement(
      shiftId,
      {
        kind: 'OUT',
        reason: 'BANK_DROP',
        amountCents: 5000,
        approverStaffId: managerId,
      },
      cashierId,
    );
    expect((await pushOne(till, ok)).status).toBe('APPLIED');
    const stored = await prisma.cashMovement.findUniqueOrThrow({
      where: { id: ok.id },
    });
    expect(stored).toMatchObject({
      kind: 'OUT',
      amountCents: 5000,
      reason: 'BANK_DROP',
      staffId: cashierId,
      approverStaffId: managerId,
    });
    const audit = await prisma.auditLog.findFirstOrThrow({
      where: { entityId: shiftId, action: 'cash.movement' },
    });
    expect(audit.actorStaffId).toBe(cashierId);
    expect(audit.approverStaffId).toBe(managerId);

    // Close it for the later tests: 1000.00 − 50.00.
    const res = await pushOne(till, closed(till, shiftId, 95000, 95000));
    expect(res.status).toBe('APPLIED');
    till.z += 1;
  });

  it('E6: a close that differs from the server, or a second one, is rejected', async () => {
    const t = await newTill(branchId);
    const shiftId = await openShift(t);
    expect((await pushOne(t, sale(t, shiftId))).status).toBe('APPLIED');

    const wrong = await pushOne(t, closed(t, shiftId, 100000, 100000));
    expect(wrong.status).toBe('QUARANTINED');
    expect(wrong.message).toContain('server has 101500');
    expect(
      await prisma.cashShift.findUniqueOrThrow({ where: { id: shiftId } }),
    ).toMatchObject({ status: 'OPEN' });

    expect((await pushOne(t, closed(t, shiftId, 101500, 101500))).status).toBe(
      'APPLIED',
    );
    t.z += 1;
    const twice = await pushOne(t, closed(t, shiftId, 101500, 101500));
    expect(twice.message).toContain('already closed');

    const late = sale(t, shiftId);
    late.occurredAt = new Date(Date.now() + 60_000).toISOString();
    expect((await pushOne(t, late)).message).toContain('already closed');
  });

  it.each([
    ['short by the limit', 95000, false],
    ['short past the limit', 94950, true],
    ['over by the limit', 105000, false],
    ['over past the limit', 105050, true],
  ])('E7: %s', async (_name, counted, flagged) => {
    const t = await newTill(branchId);
    const shiftId = await openShift(t);
    if (flagged) {
      const silent = await pushOne(t, closed(t, shiftId, 100000, counted));
      expect(silent.message).toContain('needs a note');
    }
    const res = await pushOne(
      t,
      closed(t, shiftId, 100000, counted, {
        note: flagged ? 'Faltante revisado' : null,
      }),
    );
    expect(res.status).toBe('APPLIED');
    const shift = await prisma.cashShift.findUniqueOrThrow({
      where: { id: shiftId },
    });
    expect(shift.flagged).toBe(flagged);
    expect(
      await prisma.auditLog.count({
        where: { entityId: shiftId, action: 'cash.variance_flagged' },
      }),
    ).toBe(flagged ? 1 : 0);
  });

  it('E9: a refund on another till comes out of that till and both balance', async () => {
    const a = await newTill(branchId);
    const b = await newTill(branchId);
    const shiftA = await openShift(a);
    const shiftB = await openShift(b);
    const s = sale(a, shiftA, 2000);
    expect((await pushOne(a, s)).status).toBe('APPLIED');
    expect((await pushOne(b, refund(s.id, shiftB, 2000))).status).toBe(
      'APPLIED',
    );
    expect((await pushOne(a, closed(a, shiftA, 102000, 102000))).status).toBe(
      'APPLIED',
    );
    expect((await pushOne(b, closed(b, shiftB, 98000, 98000))).status).toBe(
      'APPLIED',
    );
  });

  it('E10: two tills sync a whole shift twice with no duplicates', async () => {
    const tills = [await newTill(branchId), await newTill(branchId)];
    for (const t of tills) {
      const open = opened();
      const sales = [1, 2, 3].map(() => sale(t, open.id));
      const batch = [open, ...sales, closed(t, open.id, 104500, 104500)];
      const first = await push(t.token, batch);
      expect(first.every((r) => r.status === 'APPLIED')).toBe(true);
      const second = await push(t.token, batch);
      expect(second.every((r) => r.status === 'DUPLICATE')).toBe(true);
      expect(await prisma.cashShift.count({ where: { deviceId: t.id } })).toBe(
        1,
      );
      expect(await prisma.sale.count({ where: { shiftId: open.id } })).toBe(3);
    }
  });

  it('E8: 200 sales and refunds give a Z report matching the stored rows', async () => {
    const t = await newTill(branchId);
    const open = opened();
    expect((await pushOne(t, open)).status).toBe('APPLIED');
    const sold = Array.from({ length: 200 }, (_, i) =>
      sale(t, open.id, 500 + i * 7),
    );
    for (let i = 0; i < sold.length; i += 100) {
      const res = await push(t.token, sold.slice(i, i + 100));
      expect(res.every((r) => r.status === 'APPLIED')).toBe(true);
    }
    for (const i of [3, 50]) {
      const price = 500 + i * 7;
      expect(
        (await pushOne(t, refund(sold[i].id, open.id, price))).status,
      ).toBe('APPLIED');
    }
    await pushOne(t, movement(open.id));

    const stored = await prisma.sale.aggregate({
      where: { shiftId: open.id },
      _sum: { totalCents: true, grossCents: true },
      _count: true,
    });
    const returned = await prisma.refund.aggregate({
      where: { shiftId: open.id },
      _sum: { totalCents: true },
    });
    const net = stored._sum.totalCents!;
    const back = returned._sum.totalCents!;
    const expected = 100000 + net + 20000 - back;
    const close = closed(t, open.id, expected, expected - (expected % 50));
    const payload = close.payload;
    payload.varianceCents = -(expected % 50);
    expect((await pushOne(t, close)).status).toBe('APPLIED');

    const res = await request(server)
      .get(`/v1/shifts/${open.id}`)
      .set('Authorization', `Bearer ${ownerToken}`);
    const body = res.body as {
      expectedCents: number;
      zReport: {
        saleCount: number;
        netCents: number;
        grossCents: number;
        refundCents: number;
        taxes: { baseCents: number; taxCents: number }[];
      };
    };
    expect(body.expectedCents).toBe(expected);
    expect(body.zReport.saleCount).toBe(200);
    expect(body.zReport.netCents).toBe(net);
    expect(body.zReport.grossCents).toBe(stored._sum.grossCents);
    expect(body.zReport.refundCents).toBe(back);
    expect(
      body.zReport.taxes.reduce((a, x) => a + x.baseCents + x.taxCents, 0),
    ).toBe(net - back);
    // 200 sales each take stock under a lock; CI runners are slow.
  }, 30_000);

  it('E13: shifts list, flag filter, Z report, notes and scope', async () => {
    const t = await newTill(branchId);
    const open = opened();
    const s = sale(t, open.id);
    const batch = [
      open,
      s,
      movement(open.id),
      refund(s.id, open.id, 1500),
      closed(t, open.id, 120000, 113000, {
        note: 'Sobrante',
      }),
    ];
    const results = await push(t.token, batch);
    expect(results.map((r) => r.status)).toEqual(Array(5).fill('APPLIED'));

    const list = await request(server)
      .get('/v1/shifts')
      .query({ deviceId: t.id, flagged: true })
      .set('Authorization', `Bearer ${ownerToken}`);
    expect(list.status).toBe(200);
    expect(
      validateResponseAgainstContract({
        path: '/v1/shifts',
        method: 'GET',
        status: 200,
        body: list.body,
      }).errors ?? [],
    ).toEqual([]);
    const items = (list.body as { items: { id: string; zLabel: string }[] })
      .items;
    expect(items.map((i) => i.id)).toEqual([open.id]);
    expect(items[0].zLabel).toBe(`${t.prefix}-Z0001`);

    const detail = await request(server)
      .post(`/v1/shifts/${open.id}/notes`)
      .send({ note: 'Revisado con la cajera' })
      .set('Authorization', `Bearer ${managerToken}`);
    expect(detail.status).toBe(200);
    expect(
      validateResponseAgainstContract({
        path: '/v1/shifts/{shiftId}/notes',
        method: 'POST',
        status: 200,
        body: detail.body,
      }).errors ?? [],
    ).toEqual([]);
    const body = detail.body as {
      zReport: Record<string, unknown>;
      notes: unknown[];
      closeCount: unknown[];
    };
    expect(body.notes).toHaveLength(1);
    expect(body.zReport).toMatchObject({
      saleCount: 1,
      netCents: 1500,
      refundCount: 1,
      refundCents: 1500,
      cashInCents: 20000,
      cashOutCents: 0,
      prepaidCollectedCents: 0,
      taxes: [{ kind: 'IVA', rateBp: 0, baseCents: 0, taxCents: 0 }],
    });

    const hidden = await request(server)
      .get(`/v1/shifts/${open.id}`)
      .set('Authorization', `Bearer ${otherManagerToken}`);
    expect(hidden.status).toBe(404);
    const forbidden = await request(server)
      .get('/v1/shifts')
      .query({ branchId })
      .set('Authorization', `Bearer ${otherManagerToken}`);
    expect(forbidden.status).toBe(403);
  });

  it.each([
    'UPDATE "cash_count" SET "quantity" = 0',
    'DELETE FROM "cash_shift"',
    'UPDATE "cash_movement" SET "amount_cents" = 1',
    'DELETE FROM "sale"',
    'DELETE FROM "sale_line"',
    'UPDATE "payment" SET "amount_cents" = 1',
    'DELETE FROM "refund"',
    'DELETE FROM "sync_inbox"',
    'UPDATE "_prisma_migrations" SET "logs" = NULL',
  ])('E12: the app role is refused: %s', async (sql) => {
    await expect(prisma.$executeRawUnsafe(sql)).rejects.toThrow(
      /permission denied/,
    );
  });
});
