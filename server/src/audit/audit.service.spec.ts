import { v7 as uuidv7 } from 'uuid';
import { ClockService } from '../common/clock.service';
import { PrismaService } from '../prisma/prisma.service';
import { AuditService } from './audit.service';

describe('AuditService', () => {
  let service: AuditService;
  let createMock: jest.Mock<Promise<unknown>, [unknown]>;
  let findManyMock: jest.Mock<Promise<unknown>, [unknown]>;
  let clock: ClockService;

  beforeEach(() => {
    createMock = jest.fn<Promise<unknown>, [unknown]>();
    findManyMock = jest.fn<Promise<unknown>, [unknown]>();
    clock = new ClockService();

    const prismaMock = {
      auditLog: {
        create: createMock,
        findMany: findManyMock,
      },
    } as unknown as PrismaService;

    service = new AuditService(prismaMock, clock);
  });

  describe('log', () => {
    it('creates audit log record with clock timestamp', async () => {
      const fixedTime = new Date('2026-10-23T18:00:00.000Z');
      clock.setNow(fixedTime);

      await service.log({
        action: 'branch.created',
        actorStaffId: 'actor-1',
        branchId: 'branch-1',
        data: { test: true },
      });

      expect(createMock).toHaveBeenCalled();
      const callArgs = createMock.mock.calls[0][0] as {
        data: {
          action: string;
          actorStaffId: string;
          branchId: string;
          occurredAt: Date;
          data: { test: boolean };
        };
      };
      expect(callArgs.data.action).toBe('branch.created');
      expect(callArgs.data.actorStaffId).toBe('actor-1');
      expect(callArgs.data.branchId).toBe('branch-1');
      expect(callArgs.data.occurredAt).toEqual(fixedTime);
      expect(callArgs.data.data.test).toBe(true);
    });
  });

  describe('list', () => {
    it('filters by from, to, branchId, staffId, action', async () => {
      findManyMock.mockResolvedValue([]);

      const staffId = uuidv7();
      const branchId = uuidv7();
      await service.list({
        from: '2026-10-20T00:00:00.000Z',
        to: '2026-10-23T23:59:59.000Z',
        branchId,
        staffId,
        action: 'auth.login_success',
        limit: 10,
      });

      expect(findManyMock).toHaveBeenCalledWith(
        expect.objectContaining({
          where: {
            AND: [
              { occurredAt: { gte: new Date('2026-10-20T00:00:00.000Z') } },
              { occurredAt: { lte: new Date('2026-10-23T23:59:59.000Z') } },
              { branchId },
              {
                OR: [{ actorStaffId: staffId }, { approverStaffId: staffId }],
              },
              { action: 'auth.login_success' },
            ],
          },
          take: 11,
          orderBy: [{ occurredAt: 'desc' }, { id: 'desc' }],
        }),
      );
    });

    it('handles cursor pagination and returns nextCursor when rows exceed limit', async () => {
      const row1 = {
        id: '2',
        occurredAt: new Date('2026-10-23T12:00:00.000Z'),
        branchId: null,
        deviceId: null,
        actorStaffId: null,
        approverStaffId: null,
        action: 'auth.login_success',
        entityType: null,
        entityId: null,
        data: {},
      };
      const row2 = {
        id: '1',
        occurredAt: new Date('2026-10-23T11:00:00.000Z'),
        branchId: null,
        deviceId: null,
        actorStaffId: null,
        approverStaffId: null,
        action: 'auth.login_success',
        entityType: null,
        entityId: null,
        data: {},
      };

      findManyMock.mockResolvedValue([row1, row2]);

      const result = await service.list({ limit: 1 });
      expect(result.items).toHaveLength(1);
      expect(result.items[0].id).toBe('2');
      expect(result.nextCursor).toBeDefined();

      const decoded = Buffer.from(result.nextCursor!, 'base64').toString(
        'utf8',
      );
      expect(decoded).toBe('2026-10-23T12:00:00.000Z|2');
    });
  });
});
