import { readFileSync } from 'fs';
import { join } from 'path';
import { isDue, Schedule, weekdayBit } from './schedule';

interface Case {
  name: string;
  order: Schedule;
  days: string[];
  expected: string[];
}

const { cases } = JSON.parse(
  readFileSync(
    join(__dirname, '../../../contracts/fixtures/order-schedule-cases.json'),
    'utf8',
  ),
) as { cases: Case[] };

describe('isDue (G2)', () => {
  it.each(cases.map((c) => [c.name, c] as const))('%s', (_name, c) => {
    expect(c.days.filter((d) => isDue(c.order, d))).toEqual(c.expected);
  });

  it('numbers weekdays from Monday', () => {
    expect(weekdayBit('2026-11-02')).toBe(1);
    expect(weekdayBit('2026-11-08')).toBe(64);
  });
});
