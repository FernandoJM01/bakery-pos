import { ovenFee } from './fee';

describe('ovenFee', () => {
  it('adds the base and the weight at the price per kilo', () => {
    // $80 + $40/kg × 3.2 kg = $208.
    expect(ovenFee(8000, 4000, 3200)).toBe(20800);
  });

  it('rounds half a centavo up', () => {
    expect(ovenFee(0, 4001, 500)).toBe(2001);
    expect(ovenFee(0, 3333, 1500)).toBe(5000);
  });

  it('a flat fee has no price per kilo', () => {
    expect(ovenFee(15000, 0, 7000)).toBe(15000);
  });
});
