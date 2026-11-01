/// Money is integer centavos everywhere (M2 brief section 2); these helpers
/// format and parse it only at the edge of the UI, for es-MX.
library;

/// `123450` → `$1,234.50`; negative amounts get a leading minus.
String formatCents(int cents) {
  final sign = cents < 0 ? '-' : '';
  final abs = cents.abs();
  final pesos = (abs ~/ 100).toString();
  final buf = StringBuffer();
  for (var i = 0; i < pesos.length; i++) {
    if (i > 0 && (pesos.length - i) % 3 == 0) buf.write(',');
    buf.write(pesos[i]);
  }
  final centavos = (abs % 100).toString().padLeft(2, '0');
  return '$sign\$$buf.$centavos';
}

/// What a price field shows while editing: `1250` → `12.50`.
String centsToInput(int cents) {
  final abs = cents.abs();
  final text = '${abs ~/ 100}.${(abs % 100).toString().padLeft(2, '0')}';
  return cents < 0 ? '-$text' : text;
}

final _amount = RegExp(r'^(\d{1,3}(,\d{3})+|\d+)(\.(\d{1,2}))?$');

/// Parses what a person types as pesos: `12`, `12.5`, `$1,234.50`.
/// Returns null for anything else, including negatives and more than two
/// decimals, so a form can show its own message.
int? parseCents(String input) {
  var text = input.trim();
  if (text.startsWith(r'$')) text = text.substring(1).trim();
  final match = _amount.firstMatch(text);
  if (match == null) return null;
  final pesos = int.parse(match.group(1)!.replaceAll(',', ''));
  final decimals = (match.group(4) ?? '').padRight(2, '0');
  return pesos * 100 + int.parse(decimals);
}
