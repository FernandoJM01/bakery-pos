import { readFileSync } from 'fs';
import { join } from 'path';
import {
  computeSaleTotals,
  overLimit,
  refundAmountCents,
  TotalsDiscount,
  TotalsLineInput,
} from './sale-totals';

interface FixtureCase {
  name: string;
  lines: TotalsLineInput[];
  orderDiscount?: TotalsDiscount;
  expected: unknown;
}

const fixture = JSON.parse(
  readFileSync(
    join(__dirname, '../../../contracts/fixtures/sale-totals-cases.json'),
    'utf8',
  ),
) as { cases: FixtureCase[] };

describe('computeSaleTotals', () => {
  it('has the shared cases', () => {
    expect(fixture.cases.length).toBeGreaterThanOrEqual(12);
  });

  it.each(fixture.cases.map((c) => [c.name, c] as const))(
    'D3: %s',
    (_name, c) => {
      expect(computeSaleTotals(c.lines, c.orderDiscount)).toEqual(c.expected);
    },
  );

  it('refuses an amount discount above the line', () => {
    expect(() =>
      computeSaleTotals([
        {
          lineNo: 1,
          unitPriceCents: 100,
          quantity: 1,
          ivaBp: 0,
          iepsBp: 0,
          discount: { kind: 'AMOUNT', value: 101 },
        },
      ]),
    ).toThrow();
  });
});

describe('overLimit', () => {
  it('allows exactly the limit and refuses one centavo more', () => {
    expect(overLimit(100, 1000, 1000)).toBe(false);
    expect(overLimit(101, 1000, 1000)).toBe(true);
    expect(overLimit(0, 0, 1000)).toBe(false);
  });
});

describe('refundAmountCents', () => {
  it('adds up to the line net over partial refunds', () => {
    const net = 1000;
    const parts = [1, 1, 1].map((k, i) => refundAmountCents(net, 3, i, k));
    expect(parts).toEqual([333, 334, 333]);
    expect(parts.reduce((a, b) => a + b, 0)).toBe(net);
  });
});
