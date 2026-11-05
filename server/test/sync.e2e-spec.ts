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
import { validateResponseAgainstContract } from './contract-validator';

const IVA16 = '019a1e00-0000-7000-8000-000000000002';
const tag = () => randomBytes(4).toString('hex');

interface Feed {
  nextSince: number;
  hasMore: boolean;
  products: { id: string; name: string; isActive: boolean }[];
  variants: { id: string; productId: string; priceCents: number }[];
  branchPrices: {
    variantId: string;
    priceCents: number | null;
    removed: boolean;
  }[];
  taxRates: unknown[];
  categories: { id: string }[];
}
interface PushResult {
  id: string;
  status: string;
  errorCode: string | null;
}

describe('Sync (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  const prisma = new PrismaClient();
  let ownerToken: string;
  let managerToken: string;
  let suc1: string;
  let suc2: string;
  let till1: string;
  let till1Id: string;
  let till2: string;
  let cashierId: string;
  let managerId: string;
  let otherBranchCashierId: string;
  let categoryId: string;

  const password = 'SyncPass123!';
  const asOwner = () => ({ Authorization: `Bearer ${ownerToken}` });

  function expectContract(path: string, method: string, res: request.Response) {
    expect(
      validateResponseAgainstContract({
        path,
        method,
        status: res.status,
        body: res.body,
      }).errors ?? [],
    ).toEqual([]);
  }

  async function pull(token: string, since: number, limit?: number) {
    const res = await request(server)
      .get('/v1/sync/catalog')
      .query(limit ? { since, limit } : { since })
      .set('X-Device-Token', token);
    expect(res.status).toBe(200);
    expectContract('/v1/sync/catalog', 'GET', res);
    return res.body as Feed;
  }

  /** Pulls page after page until the till is up to date. */
  async function drain(token: string, since: number) {
    const all: Feed[] = [];
    let next = since;
    for (;;) {
      const page = await pull(token, next, 1000);
      all.push(page);
      expect(page.nextSince).toBeGreaterThanOrEqual(next);
      next = page.nextSince;
      if (!page.hasMore) break;
    }
    return {
      nextSince: next,
      products: all.flatMap((p) => p.products),
      variants: all.flatMap((p) => p.variants),
      branchPrices: all.flatMap((p) => p.branchPrices),
    };
  }

  async function push(token: string, records: unknown[]) {
    const res = await request(server)
      .post('/v1/sync/push')
      .set('X-Device-Token', token)
      .send({ records });
    expect(res.status).toBe(200);
    expectContract('/v1/sync/push', 'POST', res);
    return (res.body as { results: PushResult[] }).results;
  }

  const login = (staffId: string, extra: Record<string, unknown> = {}) => ({
    id: uuidv7(),
    type: 'audit.offline_event',
    occurredAt: new Date(Date.now() - 3_600_000).toISOString(),
    actorStaffId: staffId,
    payload: { action: 'auth.login_success', staffId, ...extra },
  });

  beforeAll(async () => {
    const branch = async (name: string) =>
      (
        await prisma.branch.create({
          data: { id: uuidv7(), code: `S${tag().toUpperCase()}`, name },
        })
      ).id;
    suc1 = await branch('Sync SUC1');
    suc2 = await branch('Sync SUC2');
    const passwordHash = await hashPassword(password);
    const staff = async (role: Role, branchId: string, withEmail: boolean) => {
      const { pinHash, offlinePinVerifier } = await hashPin('1234');
      return prisma.staff.create({
        data: {
          id: uuidv7(),
          fullName: `Sync ${role}`,
          displayName: role,
          role,
          email: withEmail ? `${tag()}-sync@bakery.local` : null,
          passwordHash: withEmail ? passwordHash : null,
          pinHash,
          offlinePinVerifier,
          pinUpdatedAt: new Date(),
          staffBranches: { create: [{ branchId }] },
        },
      });
    };
    const owner = await staff(Role.OWNER, suc1, true);
    const manager = await staff(Role.BRANCH_MANAGER, suc1, true);
    managerId = manager.id;
    cashierId = (await staff(Role.CASHIER, suc1, false)).id;
    otherBranchCashierId = (await staff(Role.CASHIER, suc2, false)).id;

    const till = async (branchId: string) => {
      const token = randomBytes(32).toString('hex');
      const device = await prisma.device.create({
        data: {
          id: uuidv7(),
          branchId,
          name: `Till ${tag()}`,
          type: 'TILL',
          status: 'ACTIVE',
          tokenHash: hashTokenWithPepper(
            token,
            process.env.DEVICE_TOKEN_PEPPER!,
          ),
        },
      });
      return { token, id: device.id };
    };
    const t1 = await till(suc1);
    till1 = t1.token;
    till1Id = t1.id;
    till2 = (await till(suc2)).token;

    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleRef.createNestApplication();
    configureApp(app);
    await app.init();
    server = app.getHttpServer() as Server;

    const passwordLogin = async (email: string) =>
      (
        (
          await request(server)
            .post('/v1/auth/password-login')
            .send({ email, password })
        ).body as { accessToken: string }
      ).accessToken;
    ownerToken = await passwordLogin(owner.email!);
    managerToken = await passwordLogin(manager.email!);

    const category = await request(server)
      .post('/v1/categories')
      .set(asOwner())
      .send({ name: `Sync ${tag()}`, color: '#C46A2B' });
    expect(category.status).toBe(201);
    categoryId = (category.body as { id: string }).id;
  });

  afterAll(async () => {
    await app?.close();
    await prisma.$disconnect();
  });

  async function createProduct(name: string, priceCents: number) {
    const res = await request(server)
      .post('/v1/products')
      .set(asOwner())
      .send({
        categoryId,
        name,
        unit: 'PIECE',
        ivaRateId: IVA16,
        variants: [{ name: 'Normal', priceCents }],
      });
    expect(res.status).toBe(201);
    return res.body as { id: string; variants: { id: string }[] };
  }

  it('C3: a full pull gets a new product, the next pull does not repeat it, an edit sends only the edited rows', async () => {
    const product = await createProduct(`Concha ${tag()}`, 1200);
    const variantId = product.variants[0].id;

    const first = await drain(till1, 0);
    expect(first.products.map((p) => p.id)).toContain(product.id);
    expect(first.variants.map((v) => v.id)).toContain(variantId);

    // Other test files may be writing catalog rows in parallel, so this
    // checks our rows; the unit test checks an empty page exactly.
    const again = await drain(till1, first.nextSince);
    expect(again.products.map((p) => p.id)).not.toContain(product.id);
    expect(again.variants.map((v) => v.id)).not.toContain(variantId);

    const edit = await request(server)
      .patch(`/v1/products/${product.id}`)
      .set(asOwner())
      .send({ name: 'Concha de vainilla' });
    expect(edit.status).toBe(200);

    const afterEdit = await drain(till1, again.nextSince);
    const mine = afterEdit.products.filter((p) => p.id === product.id);
    expect(mine).toEqual([
      expect.objectContaining({ name: 'Concha de vainilla' }),
    ]);
    // Only the product row changed, so its variant is not sent again.
    expect(afterEdit.variants.map((v) => v.id)).not.toContain(variantId);
  });

  it('C4: a till gets only its own branch prices, and a removed override reaches it', async () => {
    const product = await createProduct(`Bolillo ${tag()}`, 300);
    const variantId = product.variants[0].id;
    const start1 = (await drain(till1, 0)).nextSince;
    const start2 = (await drain(till2, 0)).nextSince;

    for (const [branchId, priceCents] of [
      [suc1, 350],
      [suc2, 400],
    ] as const) {
      const res = await request(server)
        .put(`/v1/variants/${variantId}/branch-prices/${branchId}`)
        .set(asOwner())
        .send({ priceCents });
      expect(res.status).toBe(200);
    }

    const t1 = await drain(till1, start1);
    expect(t1.branchPrices.filter((b) => b.variantId === variantId)).toEqual([
      { variantId, priceCents: 350, removed: false },
    ]);
    const t2 = await drain(till2, start2);
    expect(t2.branchPrices.filter((b) => b.variantId === variantId)).toEqual([
      { variantId, priceCents: 400, removed: false },
    ]);

    const del = await request(server)
      .delete(`/v1/variants/${variantId}/branch-prices/${suc1}`)
      .set(asOwner());
    expect(del.status).toBe(204);

    const removed = await drain(till1, t1.nextSince);
    expect(
      removed.branchPrices.filter((b) => b.variantId === variantId),
    ).toEqual([{ variantId, priceCents: null, removed: true }]);
    // SUC2 never hears about SUC1's change.
    const t2After = await drain(till2, t2.nextSince);
    expect(
      t2After.branchPrices.filter((b) => b.variantId === variantId),
    ).toEqual([]);
  });

  it('pages respect the limit and hand over with nextSince', async () => {
    await createProduct(`Oreja ${tag()}`, 1000);
    await createProduct(`Cuerno ${tag()}`, 1100);
    const page = await pull(till1, 0, 2);
    const rows =
      page.taxRates.length +
      page.categories.length +
      page.products.length +
      page.variants.length +
      page.branchPrices.length;
    expect(rows).toBe(2);
    expect(page.hasMore).toBe(true);
    const next = await pull(till1, page.nextSince, 2);
    expect(next.nextSince).toBeGreaterThan(page.nextSince);
  });

  it('refuses a pull without a device token, or with a bad since', async () => {
    expect(
      (await request(server).get('/v1/sync/catalog').query({ since: 0 }))
        .status,
    ).toBe(401);
    const bad = await request(server)
      .get('/v1/sync/catalog')
      .query({ since: -1 })
      .set('X-Device-Token', till1);
    expect(bad.status).toBe(400);
  });

  it('C9: the same record pushed twice is APPLIED then DUPLICATE with one audit row', async () => {
    const record = login(cashierId, { reference: 'turno-1' });
    expect(await push(till1, [record])).toEqual([
      expect.objectContaining({ id: record.id, status: 'APPLIED' }),
    ]);
    expect(await push(till1, [record])).toEqual([
      expect.objectContaining({ id: record.id, status: 'DUPLICATE' }),
    ]);
    const rows = await prisma.auditLog.findMany({
      where: { entityId: record.id },
    });
    expect(rows).toHaveLength(1);
    expect(rows[0]).toMatchObject({
      action: 'auth.login_success',
      actorStaffId: cashierId,
      deviceId: till1Id,
      branchId: suc1,
      occurredAt: new Date(record.occurredAt),
      data: { offline: true, reference: 'turno-1' },
    });
  });

  it('C9: two pushes of one record at the same moment apply it once', async () => {
    const record = login(cashierId);
    const [a, b] = await Promise.all([
      push(till1, [record]),
      push(till1, [record]),
    ]);
    expect([a[0].status, b[0].status].sort()).toEqual(['APPLIED', 'DUPLICATE']);
    expect(
      await prisma.auditLog.count({ where: { entityId: record.id } }),
    ).toBe(1);
  });

  it('C10: one bad record in 10 is quarantined, the owner lists and resolves it', async () => {
    const records: Record<string, unknown>[] = Array.from({ length: 9 }, () =>
      login(cashierId),
    );
    const bad = {
      ...login(cashierId),
      payload: {
        action: 'auth.login_success',
        staffId: cashierId,
        pin: '1234',
      },
    };
    records.splice(4, 0, bad);

    const results = await push(till1, records);
    expect(results.map((r) => r.id)).toEqual(records.map((r) => r.id));
    expect(results.filter((r) => r.status === 'APPLIED')).toHaveLength(9);
    expect(results[4]).toMatchObject({
      status: 'QUARANTINED',
      errorCode: 'SYNC_INVALID_PAYLOAD',
    });

    // The PIN the till wrongly sent is not kept.
    const stored = await prisma.syncQuarantine.findUniqueOrThrow({
      where: { recordId: bad.id },
    });
    expect(JSON.stringify(stored.payload)).not.toContain('1234');

    // Pushing it again reports it as quarantined, with its code.
    expect(await push(till1, [bad])).toEqual([
      expect.objectContaining({
        status: 'QUARANTINED',
        errorCode: 'SYNC_INVALID_PAYLOAD',
      }),
    ]);

    const list = await request(server)
      .get('/v1/sync/quarantine')
      .query({ deviceId: till1Id })
      .set(asOwner());
    expect(list.status).toBe(200);
    expectContract('/v1/sync/quarantine', 'GET', list);
    const items = (list.body as { items: { recordId: string }[] }).items;
    expect(items.map((i) => i.recordId)).toContain(bad.id);

    expect(
      (
        await request(server)
          .get('/v1/sync/quarantine')
          .set('Authorization', `Bearer ${managerToken}`)
      ).status,
    ).toBe(403);

    const resolvePath = `/v1/sync/quarantine/${bad.id}/resolve`;
    const resolved = await request(server)
      .post(resolvePath)
      .set(asOwner())
      .send({ note: 'Till sent a PIN; fixed in the app' });
    expect(resolved.status).toBe(200);
    expectContract('/v1/sync/quarantine/{recordId}/resolve', 'POST', resolved);
    expect(resolved.body).toMatchObject({
      recordId: bad.id,
      resolutionNote: 'Till sent a PIN; fixed in the app',
    });
    expect(
      await prisma.auditLog.count({
        where: {
          action: 'sync.quarantine_resolved',
          entityId: bad.id,
        },
      }),
    ).toBe(1);

    const again = await request(server)
      .post(resolvePath)
      .set(asOwner())
      .send({ note: 'again' });
    expect(again.status).toBe(409);
    const missing = await request(server)
      .post(`/v1/sync/quarantine/${uuidv7()}/resolve`)
      .set(asOwner())
      .send({ note: 'x' });
    expect(missing.status).toBe(404);

    const open = await request(server)
      .get('/v1/sync/quarantine')
      .query({ deviceId: till1Id, status: 'OPEN' })
      .set(asOwner());
    expect(
      (open.body as { items: { recordId: string }[] }).items.map(
        (i) => i.recordId,
      ),
    ).not.toContain(bad.id);
  });

  it('quarantines unknown types and rule breaks with their codes', async () => {
    const approval = (
      approverStaffId: string,
      approvalAction = 'sale.refund',
    ) => ({
      ...login(cashierId),
      payload: {
        action: 'auth.approval_granted',
        staffId: cashierId,
        approverStaffId,
        approvalAction,
      },
    });
    const results = await push(till1, [
      { ...login(cashierId), type: 'nothing.known' },
      login(otherBranchCashierId),
      approval(managerId),
      approval(cashierId),
      approval(managerId, 'not.a.permission'),
      {
        ...login(cashierId),
        payload: { action: 'auth.approval_granted', staffId: cashierId },
      },
    ]);
    expect(results.map((r) => [r.status, r.errorCode])).toEqual([
      ['QUARANTINED', 'SYNC_UNKNOWN_TYPE'],
      ['QUARANTINED', 'SYNC_REJECTED'],
      ['APPLIED', null],
      ['QUARANTINED', 'SYNC_REJECTED'],
      ['QUARANTINED', 'SYNC_REJECTED'],
      ['QUARANTINED', 'SYNC_INVALID_PAYLOAD'],
    ]);
    const approved = await prisma.auditLog.findFirstOrThrow({
      where: { entityId: results[2].id },
    });
    expect(approved).toMatchObject({
      action: 'auth.approval_granted',
      actorStaffId: cashierId,
      approverStaffId: managerId,
      data: { offline: true, action: 'sale.refund' },
    });
  });

  it('a record id from another till is refused and the stored one is untouched', async () => {
    const record = login(cashierId);
    await push(till1, [record]);
    expect(await push(till2, [record])).toEqual([
      expect.objectContaining({
        status: 'QUARANTINED',
        errorCode: 'SYNC_REJECTED',
      }),
    ]);
    expect(
      await prisma.auditLog.count({ where: { entityId: record.id } }),
    ).toBe(1);
  });

  it('refuses a malformed batch with 400 and a push without a device with 401', async () => {
    const empty = await request(server)
      .post('/v1/sync/push')
      .set('X-Device-Token', till1)
      .send({ records: [] });
    expect(empty.status).toBe(400);
    const noDevice = await request(server)
      .post('/v1/sync/push')
      .send({ records: [login(cashierId)] });
    expect(noDevice.status).toBe(401);
  });
});
