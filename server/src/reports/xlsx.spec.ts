import { crc32, csv, xlsx } from './xlsx';

describe('exports', () => {
  it('computes the zip CRC-32', () => {
    expect(crc32(Buffer.from('123456789'))).toBe(0xcbf43926);
  });

  it('writes a zip with the sheet and its values', () => {
    const file = xlsx('Ventas', ['Día', 'Total'], [['2026-11-09', 1250.5]]);
    expect(file.subarray(0, 4)).toEqual(Buffer.from([0x50, 0x4b, 3, 4]));
    const text = file.toString('utf8');
    expect(text).toContain('xl/worksheets/sheet1.xml');
    expect(text).toContain('<v>1250.5</v>');
    expect(text).toContain('Día');
  });

  it('escapes XML and keeps accents', () => {
    const text = xlsx('S', ['Pan & <dulce>'], []).toString('utf8');
    expect(text).toContain('Pan &amp; &lt;dulce&gt;');
  });

  it('quotes CSV fields and defuses formulas', () => {
    const out = csv(['a', 'b'], [['x, "y"', '=SUM(A1)']]).toString('utf8');
    expect(out.charCodeAt(0) === 0xfeff).toBe(true);
    expect(out).toContain('"x, ""y""",\'=SUM(A1)');
  });
});
