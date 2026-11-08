import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { PrismaClient, Role } from '@prisma/client';
import { execFileSync } from 'child_process';
import { randomBytes } from 'crypto';
import { mkdtempSync, writeFileSync } from 'fs';
import type { Server } from 'http';
import { tmpdir } from 'os';
import { join } from 'path';
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
import { splitTax } from '../src/catalog/tax-split';
import { computeSaleTotals } from '../src/sales/sale-totals';
import { validateResponseAgainstContract } from './contract-validator';

const IVA0 = '019a1e00-0000-7000-8000-000000000001';
const IVA16 = '019a1e00-0000-7000-8000-000000000002';
const TZ = 'America/Mexico_City';
const tag = () => randomBytes(4).toString('hex');
// Monday 9 Nov 2026 at 09:00 and 13:00 in Mexico City.
const MORNING = new Date('2026-11-09T15:00:00Z');
const AFTERNOON = new Date('2026-11-09T19:00:00Z');

interface Row {
  key: string;
  label: string;
  saleCount: number;
  quantity: number | null;
  netCents: number;
  refundCents: number;
  cashCents: number;
  baseCents: number | null;
  taxCents: number | null;
}

describe('Reports (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  let clock: ClockService;
  const prisma = new PrismaClient();
  let branchId: string;
  let ownerToken: string;
  let otherManagerToken: string;
  let cashierId: string;
  let managerId: string;
  let bread: { id: string; price: number; iva: number };
  let cake: { id: string; price: number; iva: number };
  let till: { token: string; prefix: string; next: number; shiftId: string };
  const password = 'ReportsPass123!';

  const valid = (path: string, res: request.Response) =>
    expect(
      validateResponseAgainstContract({
        path,
        method: 'GET',
        status: res.status,
        body: res.body,
      }).errors ?? [],
    ).toEqual([]);

  async function push(records: unknown[]) {
    const res = await request(server)
      .post('/v1/sync/push')
      .set('X-Device-Token', till.token)
      .send({ records });
    const results = (res.body as { results: { status: string }[] }).results;
    expect(results.map((r) => r.status)).toEqual(records.map(() => 'APPLIED'));
  }

  function sale(at: Date, items: { v: typeof bread; quantity: number }[]) {
    const lines = items.map((x, i) => ({
      lineNo: i + 1,
      unitPriceCents: x.v.price,
      quantity: x.quantity,
      ivaBp: x.v.iva,
      iepsBp: 0,
    }));
    const totals = computeSaleTotals(lines);
    const folioNumber = till.next++;
    return {
      id: uuidv7(),
      type: 'sale.completed',
      occurredAt: at.toISOString(),
      payload: {
        folio: `${till.prefix}-${String(folioNumber).padStart(6, '0')}`,
        folioNumber,
        cashierStaffId: cashierId,
        shiftId: till.shiftId,
        lines: items.map((x, i) => ({
          ...lines[i],
          ...totals.lines[i],
          dayOld: false,
          fullPriceCents: x.v.price,
          variantId: x.v.id,
          productName: 'P',
          variantName: 'Pieza',
          ivaRateId: x.v.iva ? IVA16 : IVA0,
          iepsRateId: null,
          discount: null,
        })),
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
      },
    };
  }

  beforeAll(async () => {
    branchId = (
      await prisma.branch.create({
        data: {
          id: uuidv7(),
          code: `X${tag().toUpperCase()}`,
          name: 'Reportes',
          timezone: TZ,
        },
      })
    ).id;
    const other = (
      await prisma.branch.create({
        data: { id: uuidv7(), code: `Y${tag().toUpperCase()}`, name: 'Otra' },
      })
    ).id;
    const passwordHash = await hashPassword(password);
    const staff = async (role: Role, inBranch: string) => {
      const { pinHash, offlinePinVerifier } = await hashPin('1234');
      return prisma.staff.create({
        data: {
          id: uuidv7(),
          fullName: `Reportes ${role}`,
          displayName: `${role} ${tag()}`,
          role,
          email: `${tag()}-reportes@bakery.local`,
          passwordHash,
          pinHash,
          offlinePinVerifier,
          pinUpdatedAt: new Date(),
          staffBranches: { create: [{ branchId: inBranch }] },
        },
      });
    };
    const owner = await staff(Role.OWNER, branchId);
    const otherManager = await staff(Role.BRANCH_MANAGER, other);
    cashierId = (await staff(Role.CASHIER, branchId)).id;
    managerId = (await staff(Role.BRANCH_MANAGER, branchId)).id;
    const categoryId = (
      await prisma.category.create({
        data: { id: uuidv7(), name: `Reportes ${tag()}` },
      })
    ).id;
    const variant = async (name: string, price: number, iva: number) => {
      const p = await prisma.product.create({
        data: {
          id: uuidv7(),
          categoryId,
          name,
          unit: 'PIECE',
          ivaRateId: iva ? IVA16 : IVA0,
        },
      });
      const v = await prisma.productVariant.create({
        data: {
          id: uuidv7(),
          productId: p.id,
          name: 'Pieza',
          priceCents: price,
          costCents: 300,
        },
      });
      return { id: v.id, price, iva };
    };
    bread = await variant(`Bolillo ${tag()}`, 250, 0);
    cake = await variant(`Pastel ${tag()}`, 35000, 1600);

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
        openedAt: new Date('2026-11-09T13:00:00Z'),
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
    clock = app.get(ClockService);
    clock.setNow(new Date('2026-11-09T23:00:00Z'));
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

    const s1 = sale(MORNING, [{ v: bread, quantity: 10 }]);
    const s2 = sale(MORNING, [
      { v: bread, quantity: 4 },
      { v: cake, quantity: 1 },
    ]);
    const s3 = sale(AFTERNOON, [{ v: cake, quantity: 1 }]);
    await push([s1, s2, s3]);
    const amount = 35000;
    const t = splitTax(amount, 1600, 0);
    await push([
      {
        id: uuidv7(),
        type: 'sale.refunded',
        occurredAt: AFTERNOON.toISOString(),
        payload: {
          saleId: s3.id,
          shiftId: till.shiftId,
          kind: 'REFUND',
          reason: 'QUALITY',
          note: null,
          staffId: cashierId,
          approverStaffId: managerId,
          lines: [
            {
              lineNo: 1,
              quantity: 1,
              amountCents: amount,
              ...t,
              restock: false,
            },
          ],
          totalCents: amount,
        },
      },
    ]);
    // 2500 + 1000 + 35000 + 35000 sold, 35000 back.
    await push([
      {
        id: uuidv7(),
        type: 'shift.closed',
        occurredAt: new Date('2026-11-09T22:00:00Z').toISOString(),
        payload: {
          shiftId: till.shiftId,
          zNumber: 1,
          staffId: cashierId,
          count: [{ denominationCents: 50, quantity: 770 }],
          countedCents: 38500,
          expectedCents: 38500,
          varianceCents: 0,
          flagged: false,
          note: null,
        },
      },
    ]);
  });

  afterAll(async () => {
    clock?.setNow(null);
    await app?.close();
    await prisma.$disconnect();
  });

  const get = (path: string, query: Record<string, string>) =>
    request(server)
      .get(path)
      .query(query)
      .set('Authorization', `Bearer ${ownerToken}`);

  it('M9.1: the day matches the Z report of its shift to the centavo', async () => {
    const res = await get('/v1/reports/sales', {
      from: '2026-11-09',
      to: '2026-11-09',
      branchId,
      groupBy: 'day',
    });
    expect(res.status).toBe(200);
    valid('/v1/reports/sales', res);
    const [day] = (res.body as { items: Row[] }).items;
    const z = await request(server)
      .get(`/v1/shifts/${till.shiftId}`)
      .set('Authorization', `Bearer ${ownerToken}`);
    const zr = (
      z.body as {
        zReport: { netCents: number; refundCents: number; saleCount: number };
      }
    ).zReport;
    expect(day.netCents).toBe(zr.netCents);
    expect(day.netCents).toBe(73500);
    expect(day.refundCents).toBe(zr.refundCents);
    expect(day.saleCount).toBe(zr.saleCount);
    expect(day.cashCents).toBe(73500);
  });

  it('groups by hour, product and tax rate, with tax net of refunds', async () => {
    const q = { from: '2026-11-09', to: '2026-11-09', branchId };
    const hours = (await get('/v1/reports/sales', { ...q, groupBy: 'hour' }))
      .body as { items: Row[] };
    expect(hours.items.map((r) => [r.key, r.netCents])).toEqual([
      ['09', 38500],
      ['13', 35000],
    ]);
    const products = (
      await get('/v1/reports/sales', { ...q, groupBy: 'product' })
    ).body as { items: Row[] };
    const breadRow = products.items.find((r) => r.key === bread.id)!;
    expect(breadRow.quantity).toBe(14);
    expect(breadRow.netCents).toBe(3500);
    expect(products.items.find((r) => r.key === cake.id)!.refundCents).toBe(
      35000,
    );
    const taxes = await get('/v1/reports/sales', { ...q, groupBy: 'taxRate' });
    valid('/v1/reports/sales', taxes);
    const items = (taxes.body as { items: Row[] }).items;
    const sum = items.reduce(
      (a, r) => a + (r.baseCents ?? 0) + (r.taxCents ?? 0),
      0,
    );
    expect(sum).toBe(73500 - 35000);
    expect(items.map((r) => r.label)).toEqual(['IVA 0%', 'IVA 16%']);
  });

  it('exports CSV and Excel files that open', async () => {
    const q = {
      from: '2026-11-09',
      to: '2026-11-09',
      branchId,
      groupBy: 'product',
    };
    const c = await get('/v1/reports/sales/export', { ...q, format: 'csv' });
    expect(c.status).toBe(200);
    expect(c.headers['content-type']).toContain('text/csv');
    expect(c.text).toContain('Producto,Ventas,Piezas,Bruto');
    expect(c.text).toContain('Total');

    const x = await get('/v1/reports/sales/export', { ...q, format: 'xlsx' })
      .buffer(true)
      .parse((res, done) => {
        const chunks: Buffer[] = [];
        res.on('data', (d: Buffer) => chunks.push(d));
        res.on('end', () => done(null, Buffer.concat(chunks)));
      });
    expect(x.status).toBe(200);
    const file = join(mkdtempSync(join(tmpdir(), 'xlsx-')), 'r.xlsx');
    writeFileSync(file, x.body as Buffer);
    // The zip must be valid and every part well-formed XML.
    const check = execFileSync('python3', [
      '-I',
      '-c',
      'import sys,zipfile,xml.dom.minidom as m\nz=zipfile.ZipFile(sys.argv[1])\nassert z.testzip() is None\n[m.parseString(z.read(n)) for n in z.namelist()]\nprint(len(z.namelist()))',
      file,
    ]).toString();
    expect(check.trim()).toBe('6');
  });

  it('M9.2 and M9.3: stock and orders reports answer and validate', async () => {
    const q = { from: '2026-11-09', to: '2026-11-09', branchId };
    const stock = await get('/v1/reports/stock', q);
    expect(stock.status).toBe(200);
    valid('/v1/reports/stock', stock);
    const orders = await get('/v1/reports/orders', q);
    expect(orders.status).toBe(200);
    valid('/v1/reports/orders', orders);
    const csvStock = await get('/v1/reports/stock/export', {
      ...q,
      format: 'csv',
    });
    expect(csvStock.text).toContain('Existencia al cierre');
  });

  it('the dashboard compares with last week, and a manager sees only their branches', async () => {
    const res = await get('/v1/reports/dashboard', {
      date: '2026-11-09',
      branchId,
    });
    expect(res.status).toBe(200);
    valid('/v1/reports/dashboard', res);
    const d = res.body as {
      netCents: number;
      saleCount: number;
      averageTicketCents: number;
      compareDate: string;
      hours: { hour: number }[];
      topProducts: { variantId: string }[];
    };
    expect(d.netCents).toBe(38500);
    expect(d.saleCount).toBe(3);
    expect(d.averageTicketCents).toBe(24500);
    expect(d.compareDate).toBe('2026-11-02');
    expect(d.hours.map((h) => h.hour)).toEqual([9, 13]);
    expect(d.topProducts[0].variantId).toBe(cake.id);

    const other = await request(server)
      .get('/v1/reports/sales')
      .query({ from: '2026-11-09', to: '2026-11-09', branchId, groupBy: 'day' })
      .set('Authorization', `Bearer ${otherManagerToken}`);
    expect(other.status).toBe(403);
    const tooLong = await get('/v1/reports/sales', {
      from: '2024-01-01',
      to: '2026-11-09',
      groupBy: 'day',
    });
    expect(tooLong.status).toBe(400);
  });
});
