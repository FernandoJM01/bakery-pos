import { ConflictException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { changedFields, withFieldConflict } from './catalog-format';
import { assertDayOldRule } from './catalog.service';

const unique = (target: string[]) =>
  new Prisma.PrismaClientKnownRequestError('Unique constraint failed', {
    code: 'P2002',
    clientVersion: 'test',
    meta: { target },
  });

describe('catalog helpers', () => {
  it('reports only fields whose value changes', () => {
    expect(
      changedFields(
        { name: 'Concha', priceCents: 1200, sku: null },
        { name: 'Concha', priceCents: 1300, sku: undefined },
      ),
    ).toEqual({ priceCents: { old: 1200, new: 1300 } });
  });

  it.each([
    [['sku'], 'sku'],
    [['barcode'], 'barcode'],
    [['name'], 'name'],
  ])('names %j in details.field', async (target, field) => {
    const err = await withFieldConflict(() =>
      Promise.reject(unique(target)),
    ).catch((e: unknown) => e);
    expect(err).toBeInstanceOf(ConflictException);
    expect((err as ConflictException).getResponse()).toMatchObject({
      details: { field },
    });
  });

  it('passes other errors through', async () => {
    const boom = new Error('boom');
    await expect(withFieldConflict(() => Promise.reject(boom))).rejects.toBe(
      boom,
    );
  });

  it.each([
    [{ d: 2, bp: null, w: null }, false],
    [{ d: null, bp: 3000, w: null }, false],
    [{ d: 2, bp: 3000, w: 2 }, false],
    [{ d: 2, bp: 3000, w: 3 }, true],
    [{ d: null, bp: null, w: 5 }, true],
    [{ d: null, bp: null, w: null }, true],
  ])('C7: day-old rule %j valid=%s', ({ d, bp, w }, valid) => {
    const check = () =>
      assertDayOldRule({
        dayOldDiscountAfterDays: d,
        dayOldDiscountBp: bp,
        dayOldWasteAfterDays: w,
      });
    if (valid) expect(check).not.toThrow();
    else expect(check).toThrow();
  });
});
