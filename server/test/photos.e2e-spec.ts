import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { PrismaClient, Role } from '@prisma/client';
import { randomBytes } from 'crypto';
import type { Server } from 'http';
import sharp from 'sharp';
import request from 'supertest';
import { v7 as uuidv7 } from 'uuid';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import { hashPassword, hashPin } from '../src/common/crypto';
import { validateResponseAgainstContract } from './contract-validator';

/** Random noise compresses badly, so a modest size gives a large JPEG. */
async function noisyJpeg(width: number, height: number, quality: number) {
  return sharp(randomBytes(width * height * 3), {
    raw: { width, height, channels: 3 },
  })
    .withExif({ IFD0: { Make: 'TestCam', Model: 'Concha 3000' } })
    .jpeg({ quality })
    .toBuffer();
}

describe('Photos (e2e)', () => {
  let app: INestApplication;
  let server: Server;
  const prisma = new PrismaClient();
  let ownerToken: string;
  let managerToken: string;

  beforeAll(async () => {
    const branch = await prisma.branch.create({
      data: {
        id: uuidv7(),
        code: `P${randomBytes(4).toString('hex').toUpperCase()}`,
        name: 'Photos',
      },
    });
    const password = 'PhotosPass123!';
    const passwordHash = await hashPassword(password);
    const staff = async (role: Role) => {
      const { pinHash, offlinePinVerifier } = await hashPin('1234');
      return prisma.staff.create({
        data: {
          id: uuidv7(),
          fullName: `Photos ${role}`,
          displayName: role,
          role,
          email: `${randomBytes(4).toString('hex')}-photos@bakery.local`,
          passwordHash,
          pinHash,
          offlinePinVerifier,
          pinUpdatedAt: new Date(),
          staffBranches: { create: [{ branchId: branch.id }] },
        },
      });
    };
    const owner = await staff(Role.OWNER);
    const manager = await staff(Role.BRANCH_MANAGER);

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
  });

  afterAll(async () => {
    await app?.close();
    await prisma.$disconnect();
  });

  const upload = (token: string, data: Buffer, filename: string) =>
    request(server)
      .post('/v1/photos')
      .set('Authorization', `Bearer ${token}`)
      .attach('file', data, filename);

  it('C14: a 4 MB JPEG becomes a WebP of at most 800 px without EXIF', async () => {
    const jpeg = await noisyJpeg(2000, 1600, 98);
    expect(jpeg.length).toBeGreaterThan(3.5 * 1024 * 1024);
    expect(jpeg.length).toBeLessThan(5 * 1024 * 1024);
    expect((await sharp(jpeg).metadata()).exif).toBeDefined();

    const res = await upload(ownerToken, jpeg, 'concha.jpg');
    expect(res.status).toBe(201);
    expect(
      validateResponseAgainstContract({
        path: '/v1/photos',
        method: 'POST',
        status: 201,
        body: res.body,
      }).errors ?? [],
    ).toEqual([]);
    const { id, width, height } = res.body as {
      id: string;
      width: number;
      height: number;
    };
    expect([width, height]).toEqual([800, 640]);

    const got = await request(server)
      .get(`/v1/photos/${id}`)
      .buffer(true)
      .parse((r, cb) => {
        const chunks: Buffer[] = [];
        r.on('data', (c: Buffer) => chunks.push(c));
        r.on('end', () => cb(null, Buffer.concat(chunks)));
      });
    expect(got.status).toBe(200);
    expect(got.headers['content-type']).toBe('image/webp');
    expect(got.headers['cache-control']).toBe(
      'public, max-age=31536000, immutable',
    );
    const meta = await sharp(got.body as Buffer).metadata();
    expect(meta.format).toBe('webp');
    expect(Math.max(meta.width, meta.height)).toBe(800);
    expect(meta.exif).toBeUndefined();
  });

  it('C14: a renamed text file is refused with 400', async () => {
    const res = await upload(
      ownerToken,
      Buffer.from('not really a picture\n'.repeat(50)),
      'concha.jpg',
    );
    expect(res.status).toBe(400);
    expect(res.body).toMatchObject({ code: 'VALIDATION_FAILED' });
  });

  it('refuses a file over 5 MB with 413 PAYLOAD_TOO_LARGE', async () => {
    const res = await upload(
      ownerToken,
      Buffer.concat([Buffer.from([0xff, 0xd8, 0xff]), randomBytes(5.5e6)]),
      'big.jpg',
    );
    expect(res.status).toBe(413);
    expect(
      validateResponseAgainstContract({
        path: '/v1/photos',
        method: 'POST',
        status: 413,
        body: res.body,
      }).errors ?? [],
    ).toEqual([]);
    expect(res.body).toMatchObject({ code: 'PAYLOAD_TOO_LARGE' });
  });

  it('only the owner can upload; anyone can fetch, unknown ids are 404', async () => {
    const png = await sharp({
      create: { width: 40, height: 30, channels: 3, background: '#c46a2b' },
    })
      .png()
      .toBuffer();
    expect((await upload(managerToken, png, 'a.png')).status).toBe(403);
    const small = await upload(ownerToken, png, 'a.png');
    expect(small.status).toBe(201);
    // Small images are not enlarged.
    expect(small.body).toMatchObject({ width: 40, height: 30 });

    const missing = await request(server).get(`/v1/photos/${uuidv7()}`);
    expect(missing.status).toBe(404);
    expect(missing.body).toMatchObject({ code: 'NOT_FOUND' });
  });
});
