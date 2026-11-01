import 'package:bakery_pos/core/money/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats centavos as es-MX pesos', () {
    expect(formatCents(0), r'$0.00');
    expect(formatCents(5), r'$0.05');
    expect(formatCents(1250), r'$12.50');
    expect(formatCents(123450), r'$1,234.50');
    expect(formatCents(100000000), r'$1,000,000.00');
    expect(formatCents(-1999), r'-$19.99');
  });

  test('edits a price without the sign and separators', () {
    expect(centsToInput(1250), '12.50');
    expect(centsToInput(123450), '1234.50');
    expect(centsToInput(-5), '-0.05');
  });

  test('parses what people type', () {
    expect(parseCents('12'), 1200);
    expect(parseCents('12.5'), 1250);
    expect(parseCents('12.05'), 1205);
    expect(parseCents(r' $1,234.50 '), 123450);
    expect(parseCents('0.99'), 99);
    expect(parseCents(r'$ 7'), 700);
  });

  test('refuses anything that is not a plain amount', () {
    for (final bad in [
      '',
      'abc',
      '12.345',
      '-5',
      '1,23',
      '12,50',
      '1.2.3',
      '.5',
    ]) {
      expect(parseCents(bad), isNull, reason: bad);
    }
  });

  test('round-trips through the edit field', () {
    for (final c in [0, 1, 99, 100, 1250, 123456789]) {
      expect(parseCents(centsToInput(c)), c);
      expect(parseCents(formatCents(c)), c);
    }
  });
}
