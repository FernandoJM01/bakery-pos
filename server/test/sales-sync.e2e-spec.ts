import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { PrismaClient, Role } from '@prisma/client';
import { randomBytes } from 'crypto';
import type { Server } from 'http';
import request from 'supertest';
import { v7 as uuidv7 } from 'uuid';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import { splitTax } from '../src/catalog/tax-split';
import {
  hashPassword,
  hashPin,
  hashTokenWithPepper,
} from '../src/common/crypto';
import {
  computeSaleTotals,
  refundAmountCents,
  TotalsDiscount,
} from '../src/sales/sale-totals';
import { validateResponseAgainstContract } from './contract-validator';

const IVA0 = '019a1e00-0000-7000-8000-000000000001';
const IVA16 = '019a1e00-0000-7000-8000-000000000002';
const IEPS8 = '019a1e00-0000-7000-8000-000000000003';
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

interface LineSpec {
  variant: { id: string; priceCents: number; ivaBp: number; iepsBp: number };
  quantity: number;
  discount?: TotalsDiscount & { approverStaffId?: string };
}

describe('Sales sync (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  const prisma = new PrismaClient();
  let branchId: string;
  let branchCode: string;
  let otherBranchId: string;
  let ownerToken: string;
  let managerId: string;
  let cashierId: string;
  let otherBranchCashierId: string;
  let tillA: Till;
  let tillB: Till;
  let tillOther: Till;
  let concha: LineSpec['variant'];
  let pastel: LineSpec['variant'];
  let galletas: LineSpec['variant'];

  const password = 'SalesPass123!';

  async function push(token: string, records: unknown[]) {
    // A refund comes out of the shift of the till that pushes it.
    const shiftId = [tillA, tillB, tillOther].find(
      (t) => t.token === token,
    )?.shiftId;
    for (const r of records as { payload?: Record<string, unknown> }[]) {
      if (r.payload?.shiftId === 'of-this-till') r.payload.shiftId = shiftId;
    }
    const res = await request(server)
      .post('/v1/sync/push')
      .set('X-Device-Token', token)
      .send({ records });
    expect(res.status).toBe(200);
    expect(
      validateResponseAgainstContract({
        path: '/v1/sync/push',
        method: 'POST',
        status: res.status,
        body: res.body,
      }).errors ?? [],
    ).toEqual([]);
    return (res.body as { results: PushResult[] }).results;
  }

  async function pushOne(token: string, record: unknown) {
    const [result] = await push(token, [record]);
    return result;
  }

  /** A valid `sale.completed` record; `tweak` may break it on purpose. */
  function sale(
    till: Till,
    lines: LineSpec[],
    opts: {
      orderDiscount?: TotalsDiscount & { approverStaffId?: string };
      cashier?: string;
      occurredAt?: Date;
      folioNumber?: number;
      tendered?: number;
      tweak?: (p: Record<string, unknown>) => void;
    } = {},
  ) {
    const folioNumber = opts.folioNumber ?? till.next++;
    const input = lines.map((l, i) => ({
      lineNo: i + 1,
      unitPriceCents: l.variant.priceCents,
      quantity: l.quantity,
      ivaBp: l.variant.ivaBp,
      iepsBp: l.variant.iepsBp,
      discount: l.discount,
    }));
    const totals = computeSaleTotals(input, opts.orderDiscount);
    const discountInput = (d?: LineSpec['discount']) =>
      d
        ? {
            kind: d.kind,
            value: d.value,
            reason: 'PROMOTION',
            note: null,
            approverStaffId: d.approverStaffId ?? null,
          }
        : null;
    const tendered = opts.tendered ?? totals.totalCents;
    const payload: Record<string, unknown> = {
      folio: `${till.prefix}-${String(folioNumber).padStart(6, '0')}`,
      folioNumber,
      cashierStaffId: opts.cashier ?? cashierId,
      shiftId: till.shiftId,
      lines: lines.map((l, i) => ({
        variantId: l.variant.id,
        productName: 'Producto',
        variantName: 'Pieza',
        quantity: l.quantity,
        unitPriceCents: l.variant.priceCents,
        dayOld: false,
        fullPriceCents: l.variant.priceCents,
        ivaRateId: l.variant.ivaBp ? IVA16 : IVA0,
        ivaBp: l.variant.ivaBp,
        iepsRateId: l.variant.iepsBp ? IEPS8 : null,
        iepsBp: l.variant.iepsBp,
        discount: discountInput(l.discount),
        ...totals.lines[i],
      })),
      orderDiscount: discountInput(opts.orderDiscount),
      voidedLines: [],
      grossCents: totals.grossCents,
      discountCents: totals.discountCents,
      totalCents: totals.totalCents,
      payments: [
        {
          method: 'CASH',
          amountCents: totals.totalCents,
          tenderedCents: tendered,
          changeCents: tendered - totals.totalCents,
        },
      ],
    };
    opts.tweak?.(payload);
    return {
      id: uuidv7(),
      type: 'sale.completed',
      occurredAt: (opts.occurredAt ?? new Date()).toISOString(),
      actorStaffId: opts.cashier ?? cashierId,
      payload,
    };
  }

  /** A valid `sale.refunded` record from the stored sale. */
  async function refund(
    saleId: string,
    units: Record<number, number>,
    opts: {
      kind?: 'REFUND' | 'VOID';
      staffId?: string;
      approverStaffId?: string | null;
      occurredAt?: Date;
      tweak?: (p: Record<string, unknown>) => void;
    } = {},
  ) {
    const lines = await prisma.saleLine.findMany({ where: { saleId } });
    const out = Object.entries(units).map(([no, k]) => {
      const l = lines.find((x) => x.lineNo === Number(no))!;
      const amount = refundAmountCents(
        l.netCents,
        l.quantity,
        l.refundedQuantity,
        Math.min(k, l.quantity),
      );
      const t = splitTax(amount, l.ivaBp, l.iepsBp);
      return {
        lineNo: l.lineNo,
        quantity: k,
        amountCents: amount,
        ...t,
        restock: false,
      };
    });
    const payload: Record<string, unknown> = {
      saleId,
      shiftId: 'of-this-till',
      kind: opts.kind ?? 'REFUND',
      reason: 'CUSTOMER_RETURN',
      note: null,
      staffId: opts.staffId ?? cashierId,
      approverStaffId:
        opts.approverStaffId === undefined ? managerId : opts.approverStaffId,
      lines: out,
      totalCents: out.reduce((a, l) => a + l.amountCents, 0),
    };
    opts.tweak?.(payload);
    return {
      id: uuidv7(),
      type: 'sale.refunded',
      occurredAt: (opts.occurredAt ?? new Date()).toISOString(),
      payload,
    };
  }

  beforeAll(async () => {
    branchCode = `V${tag().toUpperCase()}`;
    branchId = (
      await prisma.branch.create({
        data: { id: uuidv7(), code: branchCode, name: 'Ventas SUC' },
      })
    ).id;
    const otherBranch = (otherBranchId = (
      await prisma.branch.create({
        data: { id: uuidv7(), code: `W${tag().toUpperCase()}`, name: 'Otra' },
      })
    ).id);
    const passwordHash = await hashPassword(password);
    const staff = async (role: Role, inBranch: string, withEmail = false) => {
      const { pinHash, offlinePinVerifier } = await hashPin('1234');
      return prisma.staff.create({
        data: {
          id: uuidv7(),
          fullName: `Ventas ${role}`,
          displayName: role,
          role,
          email: withEmail ? `${tag()}-ventas@bakery.local` : null,
          passwordHash: withEmail ? passwordHash : null,
          pinHash,
          offlinePinVerifier,
          pinUpdatedAt: new Date(),
          staffBranches: { create: [{ branchId: inBranch }] },
        },
      });
    };
    const owner = await staff(Role.OWNER, branchId, true);
    managerId = (await staff(Role.BRANCH_MANAGER, branchId)).id;
    cashierId = (await staff(Role.CASHIER, branchId)).id;
    otherBranchCashierId = (await staff(Role.CASHIER, otherBranch)).id;

    const till = async (inBranch: string, opener: string): Promise<Till> => {
      const token = randomBytes(32).toString('hex');
      const device = await prisma.device.create({
        data: {
          id: uuidv7(),
          branchId: inBranch,
          name: `Caja ${tag()}`,
          type: 'TILL',
          status: 'ACTIVE',
          tokenHash: hashTokenWithPepper(
            token,
            process.env.DEVICE_TOKEN_PEPPER!,
          ),
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
    };
    tillA = await till(branchId, cashierId);
    tillB = await till(branchId, cashierId);
    tillOther = await till(otherBranch, otherBranchCashierId);

    const category = await prisma.category.create({
      data: { id: uuidv7(), name: `Ventas ${tag()}` },
    });
    const variant = async (
      priceCents: number,
      ivaBp: number,
      iepsBp: number,
    ) => {
      const product = await prisma.product.create({
        data: {
          id: uuidv7(),
          categoryId: category.id,
          name: `Pan ${tag()}`,
          unit: 'PIECE',
          ivaRateId: ivaBp ? IVA16 : IVA0,
          iepsRateId: iepsBp ? IEPS8 : null,
        },
      });
      const v = await prisma.productVariant.create({
        data: {
          id: uuidv7(),
          productId: product.id,
          name: 'Pieza',
          priceCents,
        },
      });
      return { id: v.id, priceCents, ivaBp, iepsBp };
    };
    concha = await variant(1500, 0, 0);
    pastel = await variant(2200, 1600, 800);
    galletas = await variant(800, 1600, 0);

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
  });

  afterAll(async () => {
    await app?.close();
    await prisma.$disconnect();
  });

  it('numbers tills per branch and sends the folio prefix in the staff bundle', async () => {
    expect(tillA.prefix).toBe(`${branchCode}-01`);
    expect(tillB.prefix).toBe(`${branchCode}-02`);
    expect(tillOther.prefix).toMatch(/-01$/);

    const created = await request(server)
      .post('/v1/devices')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ branchId, name: 'Caja 3', type: 'TILL' });
    expect(created.status).toBe(201);
    const device = (created.body as { device: Record<string, unknown> }).device;
    expect(device.tillNumber).toBe(3);
    expect(device.folioPrefix).toBe(`${branchCode}-03`);

    const production = await request(server)
      .post('/v1/devices')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ branchId, name: 'Producción', type: 'PRODUCTION' });
    expect(production.status).toBe(201);
    expect(
      (production.body as { device: Record<string, unknown> }).device
        .tillNumber,
    ).toBeNull();

    const bundle = await request(server)
      .get('/v1/devices/me/staff')
      .set('X-Device-Token', tillB.token);
    expect(bundle.status).toBe(200);
    expect(bundle.body).toMatchObject({
      folioPrefix: `${branchCode}-02`,
      saleSettings: { discountLimitBp: 1000, cashVarianceFlagCents: 5000 },
    });
    expect(
      validateResponseAgainstContract({
        path: '/v1/devices/me/staff',
        method: 'GET',
        status: 200,
        body: bundle.body,
      }).errors ?? [],
    ).toEqual([]);
  });

  it('D4: stores a sale with a 10% line discount and a $5.00 ticket discount', async () => {
    const record = sale(
      tillA,
      [
        {
          variant: concha,
          quantity: 2,
          discount: { kind: 'PERCENT', value: 1000 },
        },
        { variant: galletas, quantity: 3 },
        { variant: pastel, quantity: 1 },
      ],
      { orderDiscount: { kind: 'AMOUNT', value: 500 }, tendered: 10000 },
    );
    const result = await pushOne(tillA.token, record);
    expect(result).toMatchObject({ status: 'APPLIED', errorCode: null });

    const stored = await prisma.sale.findUniqueOrThrow({
      where: { id: record.id },
      include: { lines: true, discounts: true, payments: true },
    });
    expect(stored).toMatchObject({
      folio: `${tillA.prefix}-000001`,
      grossCents: 7600,
      discountCents: 800,
      totalCents: 6800,
      status: 'COMPLETED',
    });
    expect(stored.lines.map((l) => l.orderDiscountCents)).toEqual([
      185, 164, 151,
    ]);
    expect(
      stored.discounts.map((d) => [d.lineNo, d.kind, d.cents]).sort(),
    ).toEqual(
      [
        [1, 'PERCENT', 300],
        [null, 'AMOUNT', 500],
      ].sort(),
    );
    expect(stored.payments[0]).toMatchObject({
      tenderedCents: 10000,
      changeCents: 3200,
    });

    // The same record again is a duplicate, not a second sale.
    expect((await pushOne(tillA.token, record)).status).toBe('DUPLICATE');
    expect(await prisma.sale.count({ where: { id: record.id } })).toBe(1);
  });

  it('D5: a discount over the limit needs a manager approval', async () => {
    const over = { kind: 'PERCENT' as const, value: 1500 };
    const without = await pushOne(
      tillA.token,
      sale(tillA, [{ variant: pastel, quantity: 2, discount: over }]),
    );
    expect(without).toMatchObject({
      status: 'QUARANTINED',
      errorCode: 'SYNC_REJECTED',
    });
    expect(without.message).toMatch(/limit/);

    const selfApproved = await pushOne(
      tillA.token,
      sale(tillA, [
        {
          variant: pastel,
          quantity: 2,
          discount: { ...over, approverStaffId: cashierId },
        },
      ]),
    );
    expect(selfApproved.errorCode).toBe('SYNC_REJECTED');

    const record = sale(tillA, [
      {
        variant: pastel,
        quantity: 2,
        discount: { ...over, approverStaffId: managerId },
      },
    ]);
    expect((await pushOne(tillA.token, record)).status).toBe('APPLIED');
    const audit = await prisma.auditLog.findMany({
      where: { action: 'sale.discount_over_limit', entityId: record.id },
    });
    expect(audit).toHaveLength(1);
    expect(audit[0]).toMatchObject({
      actorStaffId: cashierId,
      approverStaffId: managerId,
      entityType: 'sale',
    });

    // The exact limit needs nobody.
    const atLimit = await pushOne(
      tillA.token,
      sale(tillA, [
        {
          variant: pastel,
          quantity: 1,
          discount: { kind: 'PERCENT', value: 1000 },
        },
      ]),
    );
    expect(atLimit.status).toBe('APPLIED');
  });

  it('D9: rejects a repeated folio number, another till prefix and wrong arithmetic', async () => {
    const first = sale(tillB, [{ variant: concha, quantity: 1 }]);
    expect((await pushOne(tillB.token, first)).status).toBe('APPLIED');
    const used = (first.payload as { folioNumber: number }).folioNumber;

    const cases: [string, ReturnType<typeof sale>, string][] = [
      [
        'repeated folio number',
        sale(tillB, [{ variant: concha, quantity: 2 }], { folioNumber: used }),
        'SYNC_REJECTED',
      ],
      [
        "another till's prefix",
        sale(tillB, [{ variant: concha, quantity: 1 }], {
          tweak: (p) => {
            p.folio = `${tillA.prefix}-000999`;
            p.folioNumber = 999;
          },
        }),
        'SYNC_REJECTED',
      ],
      [
        'total off by a centavo',
        sale(tillB, [{ variant: galletas, quantity: 1 }], {
          tweak: (p) => {
            p.totalCents = (p.totalCents as number) + 1;
          },
        }),
        'SYNC_REJECTED',
      ],
      [
        'line tax split off',
        sale(tillB, [{ variant: pastel, quantity: 1 }], {
          tweak: (p) => {
            const [l] = p.lines as Record<string, number>[];
            l.ivaCents += 1;
            l.baseCents -= 1;
          },
        }),
        'SYNC_REJECTED',
      ],
      [
        'IVA rate that is not the one claimed',
        sale(tillB, [{ variant: galletas, quantity: 1 }], {
          tweak: (p) => {
            (p.lines as Record<string, unknown>[])[0].ivaRateId = IVA0;
          },
        }),
        'SYNC_REJECTED',
      ],
      [
        'cash below the total',
        sale(tillB, [{ variant: concha, quantity: 1 }], {
          tweak: (p) => {
            const [pay] = p.payments as Record<string, number>[];
            pay.tenderedCents = 1000;
            pay.changeCents = 0;
          },
        }),
        'SYNC_REJECTED',
      ],
      [
        'cashier from another branch',
        sale(tillB, [{ variant: concha, quantity: 1 }], {
          cashier: otherBranchCashierId,
        }),
        'SYNC_REJECTED',
      ],
      [
        'unknown variant',
        sale(tillB, [{ variant: { ...concha, id: uuidv7() }, quantity: 1 }]),
        'SYNC_REJECTED',
      ],
      [
        'missing lines',
        sale(tillB, [{ variant: concha, quantity: 1 }], {
          tweak: (p) => {
            p.lines = [];
          },
        }),
        'SYNC_INVALID_PAYLOAD',
      ],
      [
        'unknown field',
        sale(tillB, [{ variant: concha, quantity: 1 }], {
          tweak: (p) => {
            p.priceOverride = 1;
          },
        }),
        'SYNC_INVALID_PAYLOAD',
      ],
    ];
    const results = await push(
      tillB.token,
      cases.map(([, r]) => r),
    );
    expect(results.map((r, i) => [cases[i][0], r.status, r.errorCode])).toEqual(
      cases.map(([name, , code]) => [name, 'QUARANTINED', code]),
    );
    expect(
      await prisma.sale.count({
        where: { id: { in: cases.map(([, r]) => r.id) } },
      }),
    ).toBe(0);
    const quarantined = await prisma.syncQuarantine.count({
      where: { recordId: { in: cases.map(([, r]) => r.id) } },
    });
    expect(quarantined).toBe(cases.length);

    // A production device cannot sell.
    const token = randomBytes(32).toString('hex');
    await prisma.device.create({
      data: {
        id: uuidv7(),
        branchId,
        name: 'Horno',
        type: 'PRODUCTION',
        status: 'ACTIVE',
        tokenHash: hashTokenWithPepper(token, process.env.DEVICE_TOKEN_PEPPER!),
      },
    });
    const fromOven = await pushOne(
      token,
      sale({ ...tillB, next: 500 }, [{ variant: concha, quantity: 1 }]),
    );
    expect(fromOven.errorCode).toBe('SYNC_REJECTED');
  });

  it('D7: partial refunds add up, cannot exceed what is left, and end REFUNDED', async () => {
    const record = sale(tillA, [
      { variant: pastel, quantity: 3 },
      { variant: concha, quantity: 1 },
    ]);
    expect((await pushOne(tillA.token, record)).status).toBe('APPLIED');

    const noApproval = await pushOne(
      tillA.token,
      await refund(record.id, { 1: 1 }, { approverStaffId: null }),
    );
    expect(noApproval.errorCode).toBe('SYNC_REJECTED');

    const wrongAmount = await pushOne(
      tillA.token,
      await refund(
        record.id,
        { 1: 1 },
        {
          tweak: (p) => {
            p.totalCents = (p.totalCents as number) + 1;
          },
        },
      ),
    );
    expect(wrongAmount.errorCode).toBe('SYNC_REJECTED');

    const one = await refund(record.id, { 1: 1 });
    expect((await pushOne(tillA.token, one)).status).toBe('APPLIED');
    let stored = await prisma.sale.findUniqueOrThrow({
      where: { id: record.id },
      include: { lines: true },
    });
    expect(stored.status).toBe('PARTIALLY_REFUNDED');
    // Net 6600 over 3 units: 2200 for the first.
    expect(stored.lines[0]).toMatchObject({
      refundedQuantity: 1,
      refundedCents: 2200,
    });

    // Refunded from the other till after an online lookup.
    const tooMany = await pushOne(
      tillB.token,
      await refund(record.id, { 1: 3 }),
    );
    expect(tooMany.errorCode).toBe('SYNC_REJECTED');
    expect(tooMany.message).toMatch(/left/);

    const rest = await refund(
      record.id,
      { 1: 2, 2: 1 },
      { staffId: managerId, approverStaffId: null },
    );
    expect((await pushOne(tillB.token, rest)).status).toBe('APPLIED');
    stored = await prisma.sale.findUniqueOrThrow({
      where: { id: record.id },
      include: { lines: true },
    });
    expect(stored.status).toBe('REFUNDED');
    expect(stored.refundedCents).toBe(stored.totalCents);
    expect(stored.lines.map((l) => l.refundedCents)).toEqual(
      stored.lines.map((l) => l.netCents),
    );

    const fromOtherBranch = await pushOne(
      tillOther.token,
      await refund(record.id, { 2: 1 }),
    );
    expect(fromOtherBranch.errorCode).toBe('SYNC_REJECTED');

    const audit = await prisma.auditLog.count({
      where: { action: 'sale.refunded', entityId: record.id },
    });
    expect(audit).toBe(2);
  });

  it('D8: cancelling a sale needs the same till, the same day and every unit', async () => {
    const today = sale(tillA, [
      { variant: pastel, quantity: 2 },
      { variant: galletas, quantity: 1 },
    ]);
    const old = sale(tillA, [{ variant: concha, quantity: 1 }], {
      occurredAt: new Date(Date.now() - 2 * 86_400_000),
    });
    expect(
      (await push(tillA.token, [today, old])).map((r) => r.status),
    ).toEqual(['APPLIED', 'APPLIED']);

    const cases: [string, string, unknown][] = [
      [
        'another till',
        tillB.token,
        await refund(today.id, { 1: 2, 2: 1 }, { kind: 'VOID' }),
      ],
      [
        'a past day',
        tillA.token,
        await refund(old.id, { 1: 1 }, { kind: 'VOID' }),
      ],
      [
        'some units only',
        tillA.token,
        await refund(today.id, { 1: 1, 2: 1 }, { kind: 'VOID' }),
      ],
      [
        'cashier without a manager',
        tillA.token,
        await refund(
          today.id,
          { 1: 2, 2: 1 },
          { kind: 'VOID', approverStaffId: null },
        ),
      ],
    ];
    for (const [name, token, r] of cases) {
      const result = await pushOne(token, r);
      expect([name, result.errorCode]).toEqual([name, 'SYNC_REJECTED']);
    }

    const ok = await refund(today.id, { 1: 2, 2: 1 }, { kind: 'VOID' });
    expect((await pushOne(tillA.token, ok)).status).toBe('APPLIED');
    const stored = await prisma.sale.findUniqueOrThrow({
      where: { id: today.id },
    });
    expect(stored.status).toBe('VOIDED');
    expect(stored.refundedCents).toBe(stored.totalCents);
    const audit = await prisma.auditLog.findFirstOrThrow({
      where: { action: 'sale.voided', entityId: today.id },
    });
    expect(audit.approverStaffId).toBe(managerId);

    // Nothing is left to refund after a cancel.
    const after = await pushOne(tillA.token, await refund(today.id, { 1: 1 }));
    expect(after.errorCode).toBe('SYNC_REJECTED');
  });

  it('records a discarded ticket as an offline audit event', async () => {
    const id = uuidv7();
    const result = await pushOne(tillA.token, {
      id,
      type: 'audit.offline_event',
      occurredAt: new Date().toISOString(),
      payload: {
        action: 'sale.ticket_discarded',
        staffId: cashierId,
        ticket: { lineCount: 2, amountCents: 3700 },
      },
    });
    expect(result.status).toBe('APPLIED');
    const audit = await prisma.auditLog.findFirstOrThrow({
      where: { entityId: id },
    });
    expect(audit.action).toBe('sale.ticket_discarded');
    expect(audit.data).toMatchObject({
      ticket: { lineCount: 2, amountCents: 3700 },
    });

    const missing = await pushOne(tillA.token, {
      id: uuidv7(),
      type: 'audit.offline_event',
      occurredAt: new Date().toISOString(),
      payload: { action: 'sale.ticket_discarded', staffId: cashierId },
    });
    expect(missing.errorCode).toBe('SYNC_INVALID_PAYLOAD');
  });

  it('D11: the owner and managers read sales; cashiers cannot; tills look up by folio', async () => {
    const record = sale(
      tillB,
      [
        {
          variant: pastel,
          quantity: 3,
          discount: { kind: 'PERCENT', value: 1000 },
        },
        { variant: concha, quantity: 2 },
      ],
      { orderDiscount: { kind: 'AMOUNT', value: 500 }, tendered: 20000 },
    );
    expect((await pushOne(tillB.token, record)).status).toBe('APPLIED');
    expect(
      (await pushOne(tillB.token, await refund(record.id, { 2: 1 }))).status,
    ).toBe('APPLIED');
    const elsewhere = sale(tillOther, [{ variant: concha, quantity: 1 }], {
      cashier: otherBranchCashierId,
    });
    expect((await pushOne(tillOther.token, elsewhere)).status).toBe('APPLIED');

    const pinLogin = async (staffId: string) =>
      (
        (
          await request(server)
            .post('/v1/auth/pin-login')
            .set('X-Device-Token', tillA.token)
            .send({ staffId, pin: '1234' })
        ).body as { accessToken: string }
      ).accessToken;
    const managerToken = await pinLogin(managerId);
    const cashierToken = await pinLogin(cashierId);
    const as = (token: string) => ({ Authorization: `Bearer ${token}` });
    const contract = (path: string, res: request.Response) =>
      expect(
        validateResponseAgainstContract({
          path,
          method: 'GET',
          status: res.status,
          body: res.body,
        }).errors ?? [],
      ).toEqual([]);

    // Owner: by branch and date, then the detail.
    const from = new Date(Date.now() - 3_600_000).toISOString();
    const list = await request(server)
      .get('/v1/sales')
      .query({ branchId, from, limit: 200 })
      .set(as(ownerToken));
    expect(list.status).toBe(200);
    contract('/v1/sales', list);
    const items = (list.body as { items: { id: string; branchId: string }[] })
      .items;
    expect(items.map((i) => i.id)).toContain(record.id);
    expect(items.every((i) => i.branchId === branchId)).toBe(true);

    const byFolio = await request(server)
      .get('/v1/sales')
      .query({ folio: (record.payload as { folio: string }).folio })
      .set(as(ownerToken));
    expect((byFolio.body as { items: unknown[] }).items).toHaveLength(1);

    const detail = await request(server)
      .get(`/v1/sales/${record.id}`)
      .set(as(ownerToken));
    expect(detail.status).toBe(200);
    contract('/v1/sales/{saleId}', detail);
    const body = detail.body as {
      status: string;
      discounts: unknown[];
      taxes: { kind: string; rateBp: number }[];
      payments: { changeCents: number }[];
      refunds: { lines: unknown[] }[];
      cashierName: string;
    };
    expect(body.status).toBe('PARTIALLY_REFUNDED');
    expect(body.discounts).toHaveLength(2);
    expect(body.taxes.map((t) => `${t.kind}:${t.rateBp}`)).toEqual([
      'IEPS:800',
      'IVA:0',
      'IVA:1600',
    ]);
    expect(body.refunds).toHaveLength(1);
    expect(body.cashierName).toBe('CASHIER');

    // Pages follow the cursor without repeats.
    const seen = new Set<string>();
    let cursor: string | null = null;
    do {
      const page = await request(server)
        .get('/v1/sales')
        .query({ branchId, limit: 7, ...(cursor ? { cursor } : {}) })
        .set(as(ownerToken));
      const b = page.body as {
        items: { id: string }[];
        nextCursor: string | null;
      };
      for (const i of b.items) {
        expect(seen.has(i.id)).toBe(false);
        seen.add(i.id);
      }
      cursor = b.nextCursor;
    } while (cursor);
    expect(seen.size).toBe(await prisma.sale.count({ where: { branchId } }));

    // Manager: their branches only.
    const mine = await request(server).get('/v1/sales').set(as(managerToken));
    expect(mine.status).toBe(200);
    expect(
      (mine.body as { items: { branchId: string }[] }).items.every(
        (i) => i.branchId === branchId,
      ),
    ).toBe(true);
    const other = await request(server)
      .get('/v1/sales')
      .query({ branchId: otherBranchId })
      .set(as(managerToken));
    expect(other.status).toBe(403);
    const otherDetail = await request(server)
      .get(`/v1/sales/${elsewhere.id}`)
      .set(as(managerToken));
    expect(otherDetail.status).toBe(404);

    // Cashier: no back office sales.
    const denied = await request(server).get('/v1/sales').set(as(cashierToken));
    expect(denied.status).toBe(403);

    // Till lookup: this branch's sales, by folio.
    const lookup = await request(server)
      .get('/v1/sales/lookup')
      .query({ folio: (record.payload as { folio: string }).folio })
      .set(as(cashierToken))
      .set('X-Device-Token', tillA.token);
    expect(lookup.status).toBe(200);
    contract('/v1/sales/lookup', lookup);
    expect((lookup.body as { id: string }).id).toBe(record.id);
    const foreign = await request(server)
      .get('/v1/sales/lookup')
      .query({ folio: (elsewhere.payload as { folio: string }).folio })
      .set(as(cashierToken))
      .set('X-Device-Token', tillA.token);
    expect(foreign.status).toBe(404);
  });

  it('D10: two tills sell 200 sales each offline and the server holds exactly 400', async () => {
    const [c, p, g] = [concha, pastel, galletas];
    const batch = (till: Till) =>
      Array.from({ length: 200 }, (_, i) =>
        sale(
          till,
          [
            { variant: [c, p, g][i % 3], quantity: 1 + (i % 4) },
            { variant: g, quantity: 1 },
          ],
          { cashier: i % 2 ? cashierId : managerId },
        ),
      );
    const tillC: Till = { ...tillA, next: 1000 };
    const tillD: Till = { ...tillB, next: 1000 };
    const a = batch(tillC);
    const b = batch(tillD);
    const send = async (till: Till, records: unknown[]) => {
      const results: PushResult[] = [];
      for (let i = 0; i < records.length; i += 100) {
        const chunk = records.slice(i, i + 100);
        // Each batch twice, as after a lost response.
        const [first, again] = await Promise.all([
          push(till.token, chunk),
          push(till.token, chunk),
        ]);
        results.push(...first);
        for (const [j, r] of again.entries()) {
          expect([first[j].status, r.status].sort()).toEqual([
            'APPLIED',
            'DUPLICATE',
          ]);
        }
      }
      return results;
    };
    await Promise.all([send(tillC, a), send(tillD, b)]);

    const ids = [...a, ...b].map((r) => r.id);
    expect(await prisma.sale.count({ where: { id: { in: ids } } })).toBe(400);
    const folios = await prisma.sale.findMany({
      where: { id: { in: ids } },
      select: { folio: true },
    });
    expect(new Set(folios.map((f) => f.folio)).size).toBe(400);
    expect(
      await prisma.syncQuarantine.count({ where: { recordId: { in: ids } } }),
    ).toBe(0);
  }, 60_000);
});
