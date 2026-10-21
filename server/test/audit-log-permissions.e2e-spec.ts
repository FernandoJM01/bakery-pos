import { PrismaClient } from '@prisma/client';
import { randomBytes } from 'crypto';
import { v7 as uuidv7 } from 'uuid';

describe('A14: audit_log insert-only permissions (e2e)', () => {
  let adminClient: PrismaClient;
  let appClient: PrismaClient;
  const testLogId = uuidv7();
  const fkStaffId = uuidv7();
  const fkLogId = uuidv7();

  beforeAll(async () => {
    const adminUrl =
      process.env.DATABASE_URL ??
      'postgres://pos:pos_dev_only@127.0.0.1:5432/pos_dev';

    adminClient = new PrismaClient({
      datasources: { db: { url: adminUrl } },
    });

    // The migration creates pos_app without login (it also runs in
    // production); give it a throwaway password for this test database.
    let appUrl = process.env.APP_DATABASE_URL;
    if (!appUrl) {
      const password = randomBytes(18).toString('hex');
      await adminClient.$executeRawUnsafe(
        `ALTER ROLE pos_app WITH LOGIN PASSWORD '${password}'`,
      );
      const parsedUrl = new URL(adminUrl);
      parsedUrl.username = 'pos_app';
      parsedUrl.password = password;
      appUrl = parsedUrl.toString();
    }
    appClient = new PrismaClient({
      datasources: { db: { url: appUrl } },
    });

    await adminClient.$connect();
    await appClient.$connect();
  });

  afterAll(async () => {
    try {
      // Clean up test record using admin credentials
      await adminClient.auditLog.deleteMany({
        where: { id: { in: [testLogId, fkLogId] } },
      });
      await adminClient.staff.deleteMany({ where: { id: fkStaffId } });
    } catch {
      // Ignore cleanup error if already removed
    } finally {
      await appClient?.$disconnect();
      await adminClient?.$disconnect();
    }
  });

  it('A14: app role can insert into audit_log', async () => {
    const created = await appClient.auditLog.create({
      data: {
        id: testLogId,
        action: 'test.a14_insert',
        data: { test: true },
      },
    });

    expect(created).toBeDefined();
    expect(created.id).toBe(testLogId);
    expect(created.action).toBe('test.a14_insert');
  });

  it('A14: app role can select from audit_log', async () => {
    const found = await appClient.auditLog.findUnique({
      where: { id: testLogId },
    });

    expect(found).not.toBeNull();
    expect(found?.action).toBe('test.a14_insert');
  });

  it('A14: app role cannot UPDATE audit_log (refused with permission denied)', async () => {
    await expect(
      appClient.auditLog.update({
        where: { id: testLogId },
        data: { action: 'tampered.action' },
      }),
    ).rejects.toThrow(/permission denied for table audit_log/);
  });

  it('A14: app role cannot raw UPDATE audit_log', async () => {
    await expect(
      appClient.$executeRawUnsafe(
        `UPDATE audit_log SET action = 'tampered' WHERE id = '${testLogId}'`,
      ),
    ).rejects.toThrow(/permission denied for table audit_log/);
  });

  it('A14: app role cannot DELETE from audit_log (refused with permission denied)', async () => {
    await expect(
      appClient.auditLog.delete({
        where: { id: testLogId },
      }),
    ).rejects.toThrow(/permission denied for table audit_log/);
  });

  it('A14: app role cannot raw DELETE from audit_log', async () => {
    await expect(
      appClient.$executeRawUnsafe(
        `DELETE FROM audit_log WHERE id = '${testLogId}'`,
      ),
    ).rejects.toThrow(/permission denied for table audit_log/);
  });

  it('A14: deleting a staff member cannot rewrite audit history', async () => {
    const staffId = fkStaffId;
    const logId = fkLogId;
    await adminClient.staff.create({
      data: {
        id: staffId,
        fullName: 'A14 Temp',
        displayName: 'Temp',
        role: 'CASHIER',
        pinHash: 'not-a-real-hash',
        offlinePinVerifier: 'not-a-real-hash',
        pinUpdatedAt: new Date(),
      },
    });
    await appClient.auditLog.create({
      data: { id: logId, actorStaffId: staffId, action: 'test.a14_fk' },
    });

    // Referential actions run as the table owner, so ON DELETE SET NULL
    // would bypass the revoked UPDATE; the foreign key must refuse instead.
    await expect(
      appClient.staff.delete({ where: { id: staffId } }),
    ).rejects.toThrow(/foreign key/i);

    const log = await adminClient.auditLog.findUnique({ where: { id: logId } });
    expect(log?.actorStaffId).toBe(staffId);
  });
});
