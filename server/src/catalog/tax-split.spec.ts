import * as fs from 'fs';
import * as path from 'path';
import { splitTax } from './tax-split';

interface Case {
  priceCents: number;
  ivaBp: number;
  iepsBp: number;
  baseCents: number;
  iepsCents: number;
  ivaCents: number;
}

const fixture = JSON.parse(
  fs.readFileSync(
    path.resolve(__dirname, '../../../contracts/fixtures/tax-split-cases.json'),
    'utf8',
  ),
) as { cases: Case[] };

describe('splitTax', () => {
  it('C5: $10.00 with IVA 16% and with IEPS 8% plus IVA 16%', () => {
    expect(splitTax(1000, 1600, 0)).toEqual({
      baseCents: 862,
      iepsCents: 0,
      ivaCents: 138,
    });
    expect(splitTax(1000, 1600, 800)).toEqual({
      baseCents: 798,
      iepsCents: 64,
      ivaCents: 138,
    });
  });

  it.each(fixture.cases)(
    'C5: shared case $priceCents IVA $ivaBp IEPS $iepsBp',
    (c) => {
      const split = splitTax(c.priceCents, c.ivaBp, c.iepsBp);
      expect(split).toEqual({
        baseCents: c.baseCents,
        iepsCents: c.iepsCents,
        ivaCents: c.ivaCents,
      });
      expect(split.baseCents + split.iepsCents + split.ivaCents).toBe(
        c.priceCents,
      );
    },
  );

  it('stays exact at the largest price the contract allows', () => {
    const split = splitTax(10_000_000, 1600, 800);
    expect(split.baseCents + split.iepsCents + split.ivaCents).toBe(10_000_000);
  });
});
