import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { PrismaClient, Role } from '@prisma/client';
import { randomBytes } from 'crypto';
import type { Server } from 'http';
import request from 'supertest';
import { v7 as uuidv7 } from 'uuid';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import { hashPassword, hashPin } from '../src/common/crypto';
import { validateResponseAgainstContract } from './contract-validator';

const IVA0 = '019a1e00-0000-7000-8000-000000000001';
const tag = () => randomBytes(4).toString('hex');

describe('Day-old rules and costs (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  const prisma = new PrismaClient();
  let ownerToken: string;
  let managerToken: string;
  let managerId: string;
  let products: string[];
  let variantId: string;
  const password = 'RulesPass123!';

  const valid = (path: string, method: string, res: request.Response) =>
    expect(
      validateResponseAgainstContract({
        path,
        method,
        status: res.status,
        body: res.body,
      }).errors ?? [],
    ).toEqual([]);

  beforeAll(async () => {
    const branchId = (
      await prisma.branch.create({
        data: { id: uuidv7(), code: `D${tag().toUpperCase()}`, name: 'Reglas' },
      })
    ).id;
    const passwordHash = await hashPassword(password);
    const staff = async (role: Role) => {
      const { pinHash, offlinePinVerifier } = await hashPin('1234');
      return prisma.staff.create({
        data: {
          id: uuidv7(),
          fullName: `Reglas ${role}`,
          displayName: role,
          role,
          email: `${tag()}-reglas@bakery.local`,
          passwordHash,
          pinHash,
          offlinePinVerifier,
          pinUpdatedAt: new Date(),
          staffBranches: { create: [{ branchId }] },
        },
      });
    };
    const owner = await staff(Role.OWNER);
    const manager = await staff(Role.BRANCH_MANAGER);
    managerId = manager.id;
    const categoryId = (
      await prisma.category.create({
        data: { id: uuidv7(), name: `Reglas ${tag()}` },
      })
    ).id;
    products = [];
    for (const n of [1, 2, 3]) {
      const p = await prisma.product.create({
        data: {
          id: uuidv7(),
          categoryId,
          name: `Pan ${n} ${tag()}`,
          unit: 'PIECE',
          ivaRateId: IVA0,
        },
      });
      products.push(p.id);
      const v = await prisma.productVariant.create({
        data: { id: uuidv7(), productId: p.id, name: 'Pieza', priceCents: 900 },
      });
      variantId ??= v.id;
    }

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
  });

  afterAll(async () => {
    await app?.close();
    await prisma.$disconnect();
  });

  it('sets one rule on many products, audits each and validates it', async () => {
    const res = await request(server)
      .put('/v1/day-old-rules')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        productIds: products.slice(0, 2),
        dayOldDiscountAfterDays: 1,
        dayOldDiscountBp: 3000,
        dayOldWasteAfterDays: 3,
      });
    expect(res.status).toBe(200);
    valid('/v1/day-old-rules', 'PUT', res);
    const rows = await prisma.product.findMany({
      where: { id: { in: products } },
    });
    expect(rows.filter((p) => p.dayOldDiscountBp === 3000)).toHaveLength(2);
    expect(
      await prisma.auditLog.count({
        where: {
          entityId: { in: products },
          action: 'catalog.product_updated',
        },
      }),
    ).toBe(2);

    const list = await request(server)
      .get('/v1/day-old-rules')
      .set('Authorization', `Bearer ${ownerToken}`);
    expect(list.status).toBe(200);
    valid('/v1/day-old-rules', 'GET', list);

    const bad = await request(server)
      .put('/v1/day-old-rules')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        productIds: products,
        dayOldDiscountAfterDays: 3,
        dayOldDiscountBp: 3000,
        dayOldWasteAfterDays: 2,
      });
    expect(bad.status).toBe(400);
    const missing = await request(server)
      .put('/v1/day-old-rules')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ productIds: products, dayOldDiscountAfterDays: 1 });
    expect(missing.status).toBe(400);

    const cleared = await request(server)
      .put('/v1/day-old-rules')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        productIds: [products[0]],
        dayOldDiscountAfterDays: null,
        dayOldDiscountBp: null,
        dayOldWasteAfterDays: null,
      });
    expect(cleared.status).toBe(200);
    expect(
      (
        await prisma.product.findUniqueOrThrow({
          where: { id: products[0] },
        })
      ).dayOldDiscountBp,
    ).toBeNull();
  });

  it('a manager cannot change rules', async () => {
    const res = await request(server)
      .put('/v1/day-old-rules')
      .set('Authorization', `Bearer ${managerToken}`)
      .send({
        productIds: products,
        dayOldDiscountAfterDays: null,
        dayOldDiscountBp: null,
        dayOldWasteAfterDays: null,
      });
    expect(res.status).toBe(403);
  });

  it('a branch manager sets and clears a cost, each audited', async () => {
    const list = await request(server)
      .get('/v1/costs')
      .set('Authorization', `Bearer ${managerToken}`);
    expect(list.status).toBe(200);
    valid('/v1/costs', 'GET', list);

    const set = await request(server)
      .put(`/v1/costs/${variantId}`)
      .set('Authorization', `Bearer ${managerToken}`)
      .send({ costCents: 350 });
    expect(set.status).toBe(200);
    valid('/v1/costs/{variantId}', 'PUT', set);
    expect((set.body as { costCents: number }).costCents).toBe(350);

    const cleared = await request(server)
      .put(`/v1/costs/${variantId}`)
      .set('Authorization', `Bearer ${managerToken}`)
      .send({ costCents: null });
    expect((cleared.body as { costCents: null }).costCents).toBeNull();
    const audits = await prisma.auditLog.findMany({
      where: { entityId: variantId, action: 'catalog.cost_changed' },
    });
    expect(audits).toHaveLength(2);
    expect(audits.every((a) => a.actorStaffId === managerId)).toBe(true);

    const zero = await request(server)
      .put(`/v1/costs/${variantId}`)
      .set('Authorization', `Bearer ${managerToken}`)
      .send({ costCents: 0 });
    expect(zero.status).toBe(400);
  });
});
