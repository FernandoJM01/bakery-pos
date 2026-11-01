/// A tax-included price split into its parts, in centavos.
class TaxSplit {
  const TaxSplit({
    required this.baseCents,
    required this.iepsCents,
    required this.ivaCents,
  });

  final int baseCents;
  final int iepsCents;
  final int ivaCents;

  @override
  bool operator ==(Object other) =>
      other is TaxSplit &&
      other.baseCents == baseCents &&
      other.iepsCents == iepsCents &&
      other.ivaCents == ivaCents;

  @override
  int get hashCode => Object.hash(baseCents, iepsCents, ivaCents);

  @override
  String toString() =>
      'TaxSplit(base: $baseCents, ieps: $iepsCents, iva: $ivaCents)';
}

/// Integer division rounded half up, for non-negative operands.
int _divRoundHalfUp(int numerator, int denominator) =>
    (2 * numerator + denominator) ~/ (2 * denominator);

/// Splits a tax-included price (M2 brief 4.1). IEPS applies to the base and
/// IVA to the base plus IEPS, so we work back from the price; the three parts
/// always add up to it. Same function as `server/src/catalog/tax-split.ts`,
/// checked against `contracts/fixtures/tax-split-cases.json` on both sides.
TaxSplit splitTax(int priceCents, int ivaBp, int iepsBp) {
  final beforeIva = _divRoundHalfUp(priceCents * 10000, 10000 + ivaBp);
  final base = _divRoundHalfUp(beforeIva * 10000, 10000 + iepsBp);
  return TaxSplit(
    baseCents: base,
    iepsCents: beforeIva - base,
    ivaCents: priceCents - beforeIva,
  );
}
