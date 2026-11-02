class FifoLot {
  const FifoLot({
    required this.id,
    required this.producedOn,
    required this.left,
  });

  final String id;

  /// YYYY-MM-DD at the branch.
  final String producedOn;
  final int left;
}

class FifoResult {
  const FifoResult(this.takes, this.unassigned);

  /// Lot id and units taken from it.
  final List<(String, int)> takes;
  final int unassigned;
}

/// Which lots [quantity] units come from, oldest first (M5 brief 4.2). Same
/// function as `server/src/stock/fifo.ts`; both reproduce
/// `contracts/fixtures/stock-fifo-cases.json` (F2). Lots after
/// [agedOnOrBefore] do not count when it is given.
FifoResult assignLots(
  List<FifoLot> lots,
  int quantity, [
  String? agedOnOrBefore,
]) {
  final open =
      lots
          .where((l) => l.left > 0)
          .where(
            (l) =>
                agedOnOrBefore == null ||
                l.producedOn.compareTo(agedOnOrBefore) <= 0,
          )
          .toList()
        ..sort((a, b) {
          final d = a.producedOn.compareTo(b.producedOn);
          return d != 0 ? d : a.id.compareTo(b.id);
        });
  final takes = <(String, int)>[];
  var rest = quantity;
  for (final l in open) {
    if (rest == 0) break;
    final take = l.left < rest ? l.left : rest;
    takes.add((l.id, take));
    rest -= take;
  }
  return FifoResult(takes, rest);
}

/// Day-old price from the full price (M5 brief 2), half up.
int dayOldPrice(int fullCents, int discountBp) =>
    (2 * fullCents * (10000 - discountBp) + 10000) ~/ 20000;

/// The calendar day of [at] on this till, as YYYY-MM-DD.
String localDayOf(DateTime at) {
  final t = at.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)}';
}

DateTime _utc(String day) => DateTime.parse('${day}T00:00:00Z');

/// Whole calendar days from [from] to [to].
int daysBetween(String from, String to) =>
    _utc(to).difference(_utc(from)).inDays;

/// The calendar day [days] before [day].
String daysBefore(String day, int days) =>
    _utc(day).subtract(Duration(days: days)).toIso8601String().substring(0, 10);

/// What a product's day-old rule says about a lot of [age] days.
bool isDayOld(int age, int? afterDays) => afterDays != null && age >= afterDays;
