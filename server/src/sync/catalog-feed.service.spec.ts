import { Device } from '@prisma/client';
import { ClockService } from '../common/clock.service';
import { PrismaService } from '../prisma/prisma.service';
import { CatalogFeedService } from './catalog-feed.service';

type Where = { changeSeq: { gt: bigint }; branchId?: string };
type Args = { where: Where; take: number };

/** A fake table: rows with a changeSeq, filtered and paged like Prisma. */
function table<T extends { changeSeq: bigint; branchId?: string }>(rows: T[]) {
  return {
    findMany: jest.fn(({ where, take }: Args) =>
      Promise.resolve(
        rows
          .filter(
            (r) =>
              r.changeSeq > where.changeSeq.gt &&
              (where.branchId === undefined || r.branchId === where.branchId),
          )
          .sort((a, b) => Number(a.changeSeq - b.changeSeq))
          .slice(0, take),
      ),
    ),
  };
}

/** Runs the queries it is given and records the options, like $transaction. */
const transaction = jest.fn<
  Promise<unknown[]>,
  [Promise<unknown>[], { isolationLevel?: string }?]
>((ops) => Promise.all(ops));

const T0 = new Date('2026-11-01T12:00:00Z');
const device = { id: 'd1', branchId: 'b1' } as Device;

function service() {
  const at = { createdAt: T0, updatedAt: T0 };
  const prisma = {
    taxRate: table([
      {
        id: 't1',
        kind: 'IVA',
        name: 'IVA 16%',
        rateBp: 1600,
        isActive: true,
        changeSeq: 1n,
        ...at,
      },
    ]),
    category: table([
      {
        id: 'c1',
        name: 'Pan',
        color: '#C46A2B',
        sortOrder: 0,
        isActive: true,
        changeSeq: 2n,
        ...at,
      },
    ]),
    product: table([
      { id: 'p1', categoryId: 'c1', name: 'Concha', changeSeq: 3n } as never,
      { id: 'p2', categoryId: 'c1', name: 'Oreja', changeSeq: 6n } as never,
    ]),
    productVariant: table([
      {
        id: 'v1',
        productId: 'p1',
        name: 'Normal',
        priceCents: 1200,
        changeSeq: 4n,
      } as never,
    ]),
    branchPrice: table([
      {
        variantId: 'v1',
        branchId: 'b1',
        priceCents: 1300,
        deletedAt: null,
        changeSeq: 5n,
      },
      {
        variantId: 'v1',
        branchId: 'b2',
        priceCents: 9900,
        deletedAt: null,
        changeSeq: 7n,
      },
      {
        variantId: 'v1',
        branchId: 'b1',
        priceCents: 1300,
        deletedAt: T0,
        changeSeq: 8n,
      },
    ]),
  };
  const clock = { now: () => T0 } as ClockService;
  const withTx = {
    ...prisma,
    $transaction: transaction,
  };
  return new CatalogFeedService(withTx as unknown as PrismaService, clock);
}

describe('CatalogFeedService', () => {
  it('reads every list from one snapshot, so no row is skipped', async () => {
    transaction.mockClear();
    await service().pull(device, 0n, 10);

    expect(transaction).toHaveBeenCalledTimes(1);
    expect(transaction.mock.calls[0][1]).toEqual({
      isolationLevel: 'RepeatableRead',
    });
  });

  it('merges the tables in change order and pages by total rows', async () => {
    const feed = service();
    const first = await feed.pull(device, 0n, 4);
    expect(first.nextSince).toBe(4);
    expect(first.hasMore).toBe(true);
    expect(
      [first.taxRates, first.categories, first.products, first.variants].map(
        (l) => l.length,
      ),
    ).toEqual([1, 1, 1, 1]);
    expect(first.branchPrices).toEqual([]);

    const second = await feed.pull(device, 4n, 4);
    expect(second.branchPrices).toEqual([
      { variantId: 'v1', priceCents: 1300, removed: false },
      { variantId: 'v1', priceCents: null, removed: true },
    ]);
    expect(second.products).toEqual([expect.objectContaining({ id: 'p2' })]);
    // Seq 7 belongs to another branch and is never sent.
    expect(second.nextSince).toBe(8);
    expect(second.hasMore).toBe(false);
  });

  it('returns an empty page that keeps since when nothing changed', async () => {
    const page = await service().pull(device, 8n, 500);
    expect(page).toMatchObject({
      nextSince: 8,
      hasMore: false,
      taxRates: [],
      categories: [],
      products: [],
      variants: [],
      branchPrices: [],
      serverTime: T0.toISOString(),
    });
  });
});
