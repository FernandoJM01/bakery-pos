import { readFileSync } from 'fs';
import { join } from 'path';
import {
  assignLots,
  dayOldPrice,
  daysBefore,
  daysBetween,
  FifoLot,
  FifoResult,
} from './fifo';

interface Case {
  name: string;
  lots: FifoLot[];
  quantity: number;
  dayOld: boolean;
  agedOnOrBefore: string;
  expected: FifoResult;
}

const { cases } = JSON.parse(
  readFileSync(
    join(__dirname, '../../../contracts/fixtures/stock-fifo-cases.json'),
    'utf8',
  ),
) as { cases: Case[] };

describe('assignLots (F2)', () => {
  it.each(cases.map((c) => [c.name, c] as const))('%s', (_name, c) => {
    expect(
      assignLots(c.lots, c.quantity, c.dayOld ? c.agedOnOrBefore : null),
    ).toEqual(c.expected);
  });
});

describe('dates and day-old price', () => {
  it('rounds half up', () => {
    expect(dayOldPrice(1500, 3000)).toBe(1050);
    expect(dayOldPrice(1250, 3300)).toBe(838);
  });

  it('counts calendar days across a month and a clock change', () => {
    expect(daysBefore('2026-11-01', 1)).toBe('2026-10-31');
    expect(daysBetween('2026-10-24', '2026-10-26')).toBe(2);
    expect(daysBetween('2027-03-27', '2027-03-29')).toBe(2);
  });
});
