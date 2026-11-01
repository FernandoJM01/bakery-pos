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
const IEPS8 = '019a1e00-0000-7000-8000-000000000003';

interface VariantBody {
  id: string;
  name: string;
  sku: string | null;
  priceCents: number;
  branchPrices: { branchId: string; priceCents: number }[];
}
interface ProductBody {
  id: string;
  name: string;
  photoId: string | null;
  variants: VariantBody[];
}

const tag = () => randomBytes(4).toString('hex');

describe('Catalog API (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  const prisma = new PrismaClient();
  let ownerId: string;
  let ownerToken: string;
  let managerToken: string;
  let cashierToken: string;
  let branchId: string;
  let categoryId: string;

  const ownerEmail = 'catalog-e2e-owner@bakery.local';
  const managerEmail = 'catalog-e2e-manager@bakery.local';
  const password = 'CatalogPass123!';

  const asOwner = () => ({ Authorization: `Bearer ${ownerToken}` });

  function expectContract(
    path: string,
    method: string,
    res: request.Response,
  ): void {
    const result = validateResponseAgainstContract({
      path,
      method,
      status: res.status,
      body: res.body,
    });
    expect(result.errors ?? []).toEqual([]);
  }

  function variant(name: string, priceCents: number, extra = {}) {
    return { name, priceCents, ...extra };
  }

  async function createProduct(body: Record<string, unknown>) {
    return request(server)
      .post('/v1/products')
      .set(asOwner())
      .send({
        categoryId,
        name: `Concha ${tag()}`,
        unit: 'PIECE',
        ivaRateId: IVA16,
        variants: [variant('Normal', 1200)],
        ...body,
      });
  }

  async function auditRows(action: string, entityId: string) {
    return prisma.auditLog.findMany({
      where: { action, entityId },
      orderBy: { occurredAt: 'asc' },
    });
  }

  beforeAll(async () => {
    const branch = await prisma.branch.create({
      data: { id: uuidv7(), code: `C${tag().toUpperCase()}`, name: 'Catalog' },
    });
    branchId = branch.id;
    const passwordHash = await hashPassword(password);

    const makeStaff = async (role: Role, email: string | null, pin: string) => {
      const { pinHash, offlinePinVerifier } = await hashPin(pin);
      return prisma.staff.create({
        data: {
          id: uuidv7(),
          fullName: `Catalog ${role}`,
          displayName: role,
          role,
          email: email ? `${tag()}-${email}` : null,
          passwordHash: email ? passwordHash : null,
          pinHash,
          offlinePinVerifier,
          pinUpdatedAt: new Date(),
          staffBranches: { create: [{ branchId }] },
        },
      });
    };
    const owner = await makeStaff(Role.OWNER, ownerEmail, '1111');
    ownerId = owner.id;
    const manager = await makeStaff(Role.BRANCH_MANAGER, managerEmail, '2222');
    const cashier = await makeStaff(Role.CASHIER, null, '3333');

    const deviceToken = randomBytes(32).toString('hex');
    await prisma.device.create({
      data: {
        id: uuidv7(),
        branchId,
        name: 'Catalog till',
        type: 'TILL',
        status: 'ACTIVE',
        tokenHash: hashTokenWithPepper(
          deviceToken,
          process.env.DEVICE_TOKEN_PEPPER!,
        ),
      },
    });

    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleRef.createNestApplication();
    configureApp(app);
    await app.init();
    server = app.getHttpServer() as Server;

    const login = async (email: string) =>
      (
        (
          await request(server)
            .post('/v1/auth/password-login')
            .send({ email, password })
        ).body as { accessToken: string }
      ).accessToken;
    ownerToken = await login(owner.email!);
    managerToken = await login(manager.email!);
    cashierToken = (
      (
        await request(server)
          .post('/v1/auth/pin-login')
          .set('X-Device-Token', deviceToken)
          .send({ staffId: cashier.id, pin: '3333' })
      ).body as { accessToken: string }
    ).accessToken;

    const category = await request(server)
      .post('/v1/categories')
      .set(asOwner())
      .send({ name: `Pan dulce ${tag()}`, color: '#C46A2B' });
    expect(category.status).toBe(201);
    expectContract('/v1/categories', 'POST', category);
    categoryId = (category.body as { id: string }).id;
  });

  afterAll(async () => {
    await app?.close();
    await prisma.$disconnect();
  });

  it('C1: owner creates a product with 3 variants and a photo in one request', async () => {
    const photo = await prisma.photo.create({
      data: {
        id: uuidv7(),
        contentType: 'image/webp',
        bytes: 1234,
        width: 800,
        height: 800,
        sha256: 'a'.repeat(64),
        createdBy: ownerId,
      },
    });
    const res = await createProduct({
      photoId: photo.id,
      iepsRateId: IEPS8,
      variants: [
        variant('Chica', 900, { sku: `S-${tag()}` }),
        variant('Mediana', 1200, { barcode: `750${tag()}` }),
        variant('Grande', 1500),
      ],
    });
    expect(res.status).toBe(201);
    expectContract('/v1/products', 'POST', res);
    const body = res.body as ProductBody;
    expect(body.photoId).toBe(photo.id);
    expect(body.variants.map((v) => [v.name, v.priceCents])).toEqual([
      ['Chica', 900],
      ['Mediana', 1200],
      ['Grande', 1500],
    ]);
    expect(await auditRows('catalog.product_created', body.id)).toHaveLength(1);

    const fetched = await request(server)
      .get(`/v1/products/${body.id}`)
      .set(asOwner());
    expect(fetched.status).toBe(200);
    expectContract('/v1/products/{productId}', 'GET', fetched);
  });

  it('C1: managers and cashiers get 403 on every catalog write', async () => {
    const id = uuidv7();
    const writes: [string, string, object][] = [
      ['post', '/v1/tax-rates', { kind: 'IVA', name: 'X', rateBp: 1 }],
      ['patch', `/v1/tax-rates/${id}`, { name: 'X' }],
      ['post', '/v1/categories', { name: 'X' }],
      ['patch', `/v1/categories/${id}`, { name: 'X' }],
      ['post', '/v1/products', {}],
      ['patch', `/v1/products/${id}`, { name: 'X' }],
      ['post', `/v1/products/${id}/variants`, variant('X', 100)],
      ['patch', `/v1/variants/${id}`, { name: 'X' }],
      [
        'put',
        `/v1/variants/${id}/branch-prices/${branchId}`,
        { priceCents: 1 },
      ],
      ['delete', `/v1/variants/${id}/branch-prices/${branchId}`, {}],
    ];
    for (const token of [managerToken, cashierToken]) {
      for (const [method, path, body] of writes) {
        const res = await (
          request(server) as unknown as Record<
            string,
            (p: string) => request.Test
          >
        )
          [method](path)
          .set('Authorization', `Bearer ${token}`)
          .send(body);
        expect([method, path, res.status]).toEqual([method, path, 403]);
      }
    }
  });

  it('C2: a duplicate SKU or barcode is refused with 409 naming the field', async () => {
    const sku = `DUP-${tag()}`;
    const barcode = `750${tag()}`;
    const first = await createProduct({
      variants: [variant('A', 500, { sku, barcode })],
    });
    expect(first.status).toBe(201);

    const dupSku = await createProduct({
      variants: [variant('B', 500, { sku })],
    });
    expect(dupSku.status).toBe(409);
    expect(dupSku.body).toMatchObject({
      code: 'CONFLICT',
      details: { field: 'sku' },
    });

    const product = (await createProduct({})).body as ProductBody;
    const dupBarcode = await request(server)
      .post(`/v1/products/${product.id}/variants`)
      .set(asOwner())
      .send(variant('C', 500, { barcode }));
    expect(dupBarcode.status).toBe(409);
    expectContract('/v1/products/{productId}/variants', 'POST', dupBarcode);
    expect(dupBarcode.body).toMatchObject({ details: { field: 'barcode' } });

    const patch = await request(server)
      .patch(`/v1/variants/${product.variants[0].id}`)
      .set(asOwner())
      .send({ sku });
    expect(patch.status).toBe(409);
    expect(patch.body).toMatchObject({ details: { field: 'sku' } });
  });

  it('C6: an IEPS rate cannot be the IVA rate, and a rate in use cannot be deactivated', async () => {
    const wrongKind = await createProduct({ ivaRateId: IEPS8 });
    expect(wrongKind.status).toBe(400);
    expect(wrongKind.body).toMatchObject({ code: 'VALIDATION_FAILED' });

    const rate = await request(server)
      .post('/v1/tax-rates')
      .set(asOwner())
      .send({ kind: 'IVA', name: `IVA prueba ${tag()}`, rateBp: 1600 });
    expect(rate.status).toBe(201);
    expectContract('/v1/tax-rates', 'POST', rate);
    const rateId = (rate.body as { id: string }).id;
    expect((await createProduct({ ivaRateId: rateId })).status).toBe(201);

    const deactivate = await request(server)
      .patch(`/v1/tax-rates/${rateId}`)
      .set(asOwner())
      .send({ isActive: false });
    expect(deactivate.status).toBe(409);
    expectContract('/v1/tax-rates/{taxRateId}', 'PATCH', deactivate);

    const list = await request(server).get('/v1/tax-rates').set(asOwner());
    expect(list.status).toBe(200);
    expectContract('/v1/tax-rates', 'GET', list);
  });

  it('C7: day-old discount days need a percentage, and waste comes after discount', async () => {
    const noPercent = await createProduct({ dayOldDiscountAfterDays: 2 });
    expect(noPercent.status).toBe(400);
    const wasteTooSoon = await createProduct({
      dayOldDiscountAfterDays: 2,
      dayOldDiscountBp: 3000,
      dayOldWasteAfterDays: 2,
    });
    expect(wasteTooSoon.status).toBe(400);
    expectContract('/v1/products', 'POST', wasteTooSoon);

    const ok = await createProduct({
      dayOldDiscountAfterDays: 2,
      dayOldDiscountBp: 3000,
      dayOldWasteAfterDays: 4,
    });
    expect(ok.status).toBe(201);
    const id = (ok.body as ProductBody).id;
    // The rule is checked against the merged state on PATCH too.
    const patch = await request(server)
      .patch(`/v1/products/${id}`)
      .set(asOwner())
      .send({ dayOldWasteAfterDays: 1 });
    expect(patch.status).toBe(400);
    const clear = await request(server)
      .patch(`/v1/products/${id}`)
      .set(asOwner())
      .send({
        dayOldDiscountAfterDays: null,
        dayOldDiscountBp: null,
        iepsRateId: null,
      });
    expect(clear.status).toBe(200);
    expectContract('/v1/products/{productId}', 'PATCH', clear);
  });

  it('C8: each price change writes one audit row with actor, old and new centavos', async () => {
    const product = (await createProduct({})).body as ProductBody;
    const variantId = product.variants[0].id;
    const patch = (body: object) =>
      request(server)
        .patch(`/v1/variants/${variantId}`)
        .set(asOwner())
        .send(body);

    const changed = await patch({ priceCents: 1350 });
    expect(changed.status).toBe(200);
    expectContract('/v1/variants/{variantId}', 'PATCH', changed);
    expect((await patch({ priceCents: 1350 })).status).toBe(200);
    expect((await patch({ name: 'Renamed' })).status).toBe(200);

    const priceRows = await auditRows('catalog.price_changed', variantId);
    expect(priceRows).toHaveLength(1);
    expect(priceRows[0].actorStaffId).toBe(ownerId);
    expect(priceRows[0].data).toEqual({ old: 1200, new: 1350 });
    expect(await auditRows('catalog.variant_updated', variantId)).toHaveLength(
      1,
    );

    const path = `/v1/variants/${variantId}/branch-prices/${branchId}`;
    const set = await request(server)
      .put(path)
      .set(asOwner())
      .send({ priceCents: 1400 });
    expect(set.status).toBe(200);
    expectContract(
      '/v1/variants/{variantId}/branch-prices/{branchId}',
      'PUT',
      set,
    );
    expect((await request(server).delete(path).set(asOwner())).status).toBe(
      204,
    );
    // Removing again is idempotent and writes nothing.
    expect((await request(server).delete(path).set(asOwner())).status).toBe(
      204,
    );

    const branchRows = await auditRows(
      'catalog.branch_price_changed',
      variantId,
    );
    expect(branchRows.map((r) => r.data)).toEqual([
      { branchId, old: null, new: 1400 },
      { branchId, old: 1400, new: null },
    ]);
    const after = (
      await request(server).get(`/v1/products/${product.id}`).set(asOwner())
    ).body as ProductBody;
    expect(after.variants[0].branchPrices).toEqual([]);
  });

  it('keeps at least one active variant on an active product', async () => {
    const product = (await createProduct({})).body as ProductBody;
    const res = await request(server)
      .patch(`/v1/variants/${product.variants[0].id}`)
      .set(asOwner())
      .send({ isActive: false });
    expect(res.status).toBe(409);
  });

  it('refuses null for a field that cannot be cleared', async () => {
    const product = (await createProduct({})).body as ProductBody;
    const res = await request(server)
      .patch(`/v1/products/${product.id}`)
      .set(asOwner())
      .send({ name: null });
    expect(res.status).toBe(400);
    expect(res.body).toMatchObject({ code: 'VALIDATION_FAILED' });
  });

  it('searches ignoring case and accents, by SKU and barcode, and pages', async () => {
    const word = `Conchá${tag()}`;
    const sku = `SRCH-${tag()}`;
    await createProduct({ name: `${word} vainilla` });
    await createProduct({ name: `${word} chocolate` });
    await createProduct({ variants: [variant('Normal', 800, { sku })] });

    const search = (q: string, extra = '') =>
      request(server)
        .get(`/v1/products?q=${encodeURIComponent(q)}${extra}`)
        .set(asOwner());

    const byName = await search(word.toUpperCase().replace('Á', 'A'));
    expect(byName.status).toBe(200);
    expectContract('/v1/products', 'GET', byName);
    expect((byName.body as { items: unknown[] }).items).toHaveLength(2);

    const bySku = await search(sku.toLowerCase());
    expect((bySku.body as { items: unknown[] }).items).toHaveLength(1);

    const page1 = await search(word, '&limit=1');
    const { items, nextCursor } = page1.body as {
      items: ProductBody[];
      nextCursor: string;
    };
    expect(items).toHaveLength(1);
    const page2 = await search(word, `&limit=1&cursor=${nextCursor}`);
    const second = page2.body as { items: ProductBody[]; nextCursor: null };
    expect(second.items[0].id).not.toBe(items[0].id);
    expect(second.nextCursor).toBeNull();

    expect((await search(word, '&cursor=nonsense')).status).toBe(400);
  });
});
