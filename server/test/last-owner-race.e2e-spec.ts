import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { PrismaClient, Role } from '@prisma/client';
import { execSync } from 'child_process';
import type { Server } from 'http';
import request from 'supertest';
import { v7 as uuidv7 } from 'uuid';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import { hashPassword, hashPin } from '../src/common/crypto';

// Runs the last-owner guard's real SELECT ... FOR UPDATE as pos_app. Other
// e2e files share the main test database and keep their own owners active,
// so this file migrates a database of its own where only two owners exist.
describe('Last owner guard under concurrency (e2e, real SQL)', () => {
  const dbName = 'pos_e2e_last_owner';
  const adminUrl = new URL(process.env.MIGRATION_DATABASE_URL!);
  const appUrl = new URL(process.env.DATABASE_URL!);
  let app: INestApplication;
  let server: Server;
  let admin: PrismaClient;
  let prisma: PrismaClient;
  const owners = [
    { email: 'race-a@bakery.local', id: uuidv7() },
    { email: 'race-b@bakery.local', id: uuidv7() },
  ];
  const password = 'RaceOwnerPass123!';

  beforeAll(async () => {
    admin = new PrismaClient({
      datasources: { db: { url: adminUrl.toString() } },
    });
    await admin.$executeRawUnsafe(`DROP DATABASE IF EXISTS ${dbName}`);
    await admin.$executeRawUnsafe(`CREATE DATABASE ${dbName}`);

    adminUrl.pathname = `/${dbName}`;
    appUrl.pathname = `/${dbName}`;
    execSync('npx prisma migrate deploy', {
      stdio: 'ignore',
      env: {
        ...process.env,
        DATABASE_URL: adminUrl.toString(),
        MIGRATION_DATABASE_URL: adminUrl.toString(),
      },
    });
    process.env.DATABASE_URL = appUrl.toString();

    prisma = new PrismaClient({
      datasources: { db: { url: appUrl.toString() } },
    });
    const passwordHash = await hashPassword(password);
    const { pinHash, offlinePinVerifier } = await hashPin('1234');
    for (const o of owners) {
      await prisma.staff.create({
        data: {
          id: o.id,
          fullName: o.email,
          displayName: o.email,
          role: Role.OWNER,
          email: o.email,
          passwordHash,
          pinHash,
          offlinePinVerifier,
          pinUpdatedAt: new Date(),
          isActive: true,
        },
      });
    }

    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleRef.createNestApplication();
    configureApp(app);
    await app.init();
    server = app.getHttpServer() as Server;
  }, 60000);

  afterAll(async () => {
    await app?.close();
    await prisma?.$disconnect();
    await admin?.$executeRawUnsafe(
      `DROP DATABASE IF EXISTS ${dbName} WITH (FORCE)`,
    );
    await admin?.$disconnect();
  });

  it('two owners deactivating each other at once: exactly one succeeds', async () => {
    const tokens: string[] = [];
    for (const o of owners) {
      const res = await request(server)
        .post('/v1/auth/password-login')
        .send({ email: o.email, password });
      expect(res.status).toBe(200);
      tokens.push((res.body as { accessToken: string }).accessToken);
    }

    // A deactivates B while B deactivates A.
    const results = await Promise.all([
      request(server)
        .patch(`/v1/staff/${owners[1].id}`)
        .set('Authorization', `Bearer ${tokens[0]}`)
        .send({ isActive: false }),
      request(server)
        .patch(`/v1/staff/${owners[0].id}`)
        .set('Authorization', `Bearer ${tokens[1]}`)
        .send({ isActive: false }),
    ]);

    const statuses = results.map((r) => r.status).sort();
    expect(statuses.filter((s) => s === 200)).toHaveLength(1);
    // The loser either waited on the row lock and saw one owner left (409),
    // or arrived after the winner's commit and was already signed out (401).
    expect([401, 409]).toContain(statuses.find((s) => s !== 200));

    const active = await prisma.staff.count({
      where: { role: Role.OWNER, isActive: true },
    });
    expect(active).toBe(1);
  });
});
