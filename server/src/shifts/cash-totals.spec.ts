import { readFileSync } from 'fs';
import { join } from 'path';
import { closeResult, countTotal, ExpectedCashInput } from './cash-totals';

interface Case extends ExpectedCashInput {
  name: string;
  countedCents: number;
  cashVarianceFlagCents: number;
  expected: { expectedCents: number; varianceCents: number; flagged: boolean };
}

const { cases } = JSON.parse(
  readFileSync(
    join(__dirname, '../../../contracts/fixtures/shift-cash-cases.json'),
    'utf8',
  ),
) as { cases: Case[] };

describe('closeResult (E3)', () => {
  it.each(cases.map((c) => [c.name, c] as const))('%s', (_name, c) => {
    expect(closeResult(c, c.countedCents, c.cashVarianceFlagCents)).toEqual(
      c.expected,
    );
  });
});

describe('countTotal', () => {
  it('adds value times quantity', () => {
    expect(
      countTotal([
        { denominationCents: 50000, quantity: 2 },
        { denominationCents: 50, quantity: 3 },
      ]),
    ).toBe(100150);
  });
});
