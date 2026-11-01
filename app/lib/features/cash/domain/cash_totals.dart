/// Bills and coins a count asks for, largest first (M4 brief 2).
const denominationsCents = [
  100000,
  50000,
  20000,
  10000,
  5000,
  2000,
  1000,
  500,
  200,
  100,
  50,
];

/// What the cash-out and cash-in reasons are called in the contract.
enum CashReason {
  changeFund('CHANGE_FUND'),
  supplierPayment('SUPPLIER_PAYMENT'),
  bankDrop('BANK_DROP'),
  other('OTHER');

  const CashReason(this.json);
  final String json;
}

enum CashKind {
  cashIn('IN'),
  cashOut('OUT');

  const CashKind(this.json);
  final String json;
}

class CloseResult {
  const CloseResult({
    required this.expectedCents,
    required this.varianceCents,
    required this.flagged,
  });

  final int expectedCents;
  final int varianceCents;
  final bool flagged;
}

int _sum(Iterable<int> xs) => xs.fold(0, (a, b) => a + b);

/// Expected cash and the difference at close, M4 brief section 4.3. Same
/// function as `server/src/shifts/cash-totals.ts`; both reproduce
/// `contracts/fixtures/shift-cash-cases.json` (E3).
CloseResult closeResult({
  required int floatCents,
  required List<int> saleAmountsCents,
  required List<int> cashInCents,
  required List<int> cashOutCents,
  required List<int> refundsCents,
  required int countedCents,
  required int flagCents,
}) {
  final expected =
      floatCents +
      _sum(saleAmountsCents) +
      _sum(cashInCents) -
      _sum(cashOutCents) -
      _sum(refundsCents);
  final variance = countedCents - expected;
  return CloseResult(
    expectedCents: expected,
    varianceCents: variance,
    flagged: variance.abs() > flagCents,
  );
}

/// What a count adds up to; keys are denominations in centavos.
int countTotal(Map<int, int> count) =>
    _sum(count.entries.map((e) => e.key * e.value));
