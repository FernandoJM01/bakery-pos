/// What baking a dish costs (M8, decided 8 Nov 2026): a base per dish type
/// plus a price per kilo, half up. Same function as `server/src/oven/fee.ts`.
int ovenFee(int baseCents, int perKgCents, int weightGrams) =>
    baseCents + (2 * perKgCents * weightGrams + 1000) ~/ 2000;

/// The order a dish moves through; a step never goes back.
const ovenSteps = ['RECEIVED', 'IN_OVEN', 'READY', 'PICKED_UP'];

int ovenStep(String status) => ovenSteps.indexOf(status);

/// The phone as the server takes it: digits, `+` and spaces, 7 to 20 long.
/// Dashes, dots and brackets are dropped. Empty is null; "" when invalid.
String? cleanOvenPhone(String input) {
  final s = input.replaceAll(RegExp(r'[-.()]'), '').trim();
  if (s.isEmpty) return null;
  return RegExp(r'^[0-9+ ]{7,20}$').hasMatch(s) ? s : '';
}

/// Most a dish may weigh, as the server allows.
const ovenMaxGrams = 100000;
