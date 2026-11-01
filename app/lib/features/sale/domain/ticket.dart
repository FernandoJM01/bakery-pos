import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sale_totals.dart';

/// Why a discount was given (contract `DiscountReason`).
enum DiscountReason {
  frequentCustomer('FREQUENT_CUSTOMER'),
  damaged('DAMAGED'),
  promotion('PROMOTION'),
  other('OTHER');

  const DiscountReason(this.json);
  final String json;

  static DiscountReason fromJson(String v) =>
      values.firstWhere((r) => r.json == v, orElse: () => other);
}

/// A sellable variant as the ticket keeps it: the price and tax rates it had
/// when it was added, so a held ticket keeps them too (M3 brief 4.4).
class SaleItem {
  const SaleItem({
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.unitPriceCents,
    required this.ivaRateId,
    required this.ivaBp,
    this.iepsRateId,
    this.iepsBp = 0,
  });

  final String variantId;
  final String productName;
  final String variantName;
  final int unitPriceCents;
  final String ivaRateId;
  final int ivaBp;
  final String? iepsRateId;
  final int iepsBp;

  Map<String, Object?> toJson() => {
    'variantId': variantId,
    'productName': productName,
    'variantName': variantName,
    'unitPriceCents': unitPriceCents,
    'ivaRateId': ivaRateId,
    'ivaBp': ivaBp,
    'iepsRateId': iepsRateId,
    'iepsBp': iepsBp,
  };

  factory SaleItem.fromJson(Map<String, dynamic> j) => SaleItem(
    variantId: j['variantId'] as String,
    productName: j['productName'] as String,
    variantName: j['variantName'] as String,
    unitPriceCents: j['unitPriceCents'] as int,
    ivaRateId: j['ivaRateId'] as String,
    ivaBp: j['ivaBp'] as int,
    iepsRateId: j['iepsRateId'] as String?,
    iepsBp: j['iepsBp'] as int? ?? 0,
  );
}

class TicketDiscount {
  const TicketDiscount({
    required this.kind,
    required this.value,
    required this.reason,
    this.note,
    this.approverStaffId,
  });

  final DiscountKind kind;

  /// Basis points for percent, centavos for amount.
  final int value;
  final DiscountReason reason;
  final String? note;

  /// The manager who approved a discount above the cashier limit.
  final String? approverStaffId;

  TotalsDiscount get totals => TotalsDiscount(kind, value);

  TicketDiscount withApprover(String? staffId) => TicketDiscount(
    kind: kind,
    value: value,
    reason: reason,
    note: note,
    approverStaffId: staffId,
  );

  /// The contract's `DiscountInput`.
  Map<String, Object?> toJson() => {
    'kind': kind.json,
    'value': value,
    'reason': reason.json,
    'note': note,
    'approverStaffId': approverStaffId,
  };

  factory TicketDiscount.fromJson(Map<String, dynamic> j) => TicketDiscount(
    kind: j['kind'] == 'PERCENT' ? DiscountKind.percent : DiscountKind.amount,
    value: j['value'] as int,
    reason: DiscountReason.fromJson(j['reason'] as String),
    note: j['note'] as String?,
    approverStaffId: j['approverStaffId'] as String?,
  );
}

class TicketLine {
  const TicketLine({required this.item, required this.quantity, this.discount});

  final SaleItem item;
  final int quantity;
  final TicketDiscount? discount;

  TicketLine copyWith({
    int? quantity,
    TicketDiscount? discount,
    bool clearDiscount = false,
  }) => TicketLine(
    item: item,
    quantity: quantity ?? this.quantity,
    discount: clearDiscount ? null : (discount ?? this.discount),
  );

  Map<String, Object?> toJson() => {
    'item': item.toJson(),
    'quantity': quantity,
    'discount': discount?.toJson(),
  };

  factory TicketLine.fromJson(Map<String, dynamic> j) => TicketLine(
    item: SaleItem.fromJson(j['item'] as Map<String, dynamic>),
    quantity: j['quantity'] as int,
    discount: j['discount'] == null
        ? null
        : TicketDiscount.fromJson(j['discount'] as Map<String, dynamic>),
  );
}

/// Units taken off the ticket before payment (`VoidedLineInput`).
class VoidedLine {
  const VoidedLine({
    required this.variantId,
    required this.quantity,
    required this.unitPriceCents,
    required this.voidedAt,
    required this.staffId,
  });

  final String variantId;
  final int quantity;
  final int unitPriceCents;
  final DateTime voidedAt;
  final String staffId;

  Map<String, Object?> toJson() => {
    'variantId': variantId,
    'quantity': quantity,
    'unitPriceCents': unitPriceCents,
    'voidedAt': voidedAt.toUtc().toIso8601String(),
    'staffId': staffId,
  };

  factory VoidedLine.fromJson(Map<String, dynamic> j) => VoidedLine(
    variantId: j['variantId'] as String,
    quantity: j['quantity'] as int,
    unitPriceCents: j['unitPriceCents'] as int,
    voidedAt: DateTime.parse(j['voidedAt'] as String),
    staffId: j['staffId'] as String,
  );
}

/// The ticket being rung up on the till.
class Ticket {
  const Ticket({
    this.lines = const [],
    this.orderDiscount,
    this.voided = const [],
  });

  final List<TicketLine> lines;
  final TicketDiscount? orderDiscount;
  final List<VoidedLine> voided;

  bool get isEmpty => lines.isEmpty;
  int get unitCount => lines.fold(0, (a, l) => a + l.quantity);

  List<TotalsLineInput> get totalsInput => [
    for (final (i, l) in lines.indexed)
      TotalsLineInput(
        lineNo: i + 1,
        unitPriceCents: l.item.unitPriceCents,
        quantity: l.quantity,
        ivaBp: l.item.ivaBp,
        iepsBp: l.item.iepsBp,
        discount: l.discount?.totals,
      ),
  ];

  SaleTotals get totals =>
      computeSaleTotals(totalsInput, orderDiscount?.totals);

  /// Whether a discount is above [limitBp] with no manager behind it. A
  /// discount within the limit when given can pass it later, when the
  /// quantity drops, so the share is checked again before payment
  /// (brief 4.2 step 7); the server would reject the paid sale otherwise.
  bool needsApproval(int limitBp) {
    final t = totals;
    for (final (i, l) in lines.indexed) {
      if (_unapproved(
        l.discount,
        t.lines[i].lineDiscountCents,
        t.lines[i].grossCents,
        limitBp,
      )) {
        return true;
      }
    }
    return _unapproved(
      orderDiscount,
      t.orderDiscountCents,
      t.afterLineCents,
      limitBp,
    );
  }

  /// The same ticket with [staffId] approving every discount that needs it.
  Ticket approvedBy(String staffId, int limitBp) {
    final t = totals;
    return Ticket(
      lines: [
        for (final (i, l) in lines.indexed)
          _unapproved(
                l.discount,
                t.lines[i].lineDiscountCents,
                t.lines[i].grossCents,
                limitBp,
              )
              ? l.copyWith(discount: l.discount!.withApprover(staffId))
              : l,
      ],
      orderDiscount:
          _unapproved(
            orderDiscount,
            t.orderDiscountCents,
            t.afterLineCents,
            limitBp,
          )
          ? orderDiscount!.withApprover(staffId)
          : orderDiscount,
      voided: voided,
    );
  }

  /// The same ticket without approvals by [staffId]. A manager who resumes
  /// a held ticket cannot approve their own sale; their permission covers it.
  Ticket withoutApprovalsBy(String staffId) {
    TicketDiscount? clean(TicketDiscount? d) =>
        d?.approverStaffId == staffId ? d!.withApprover(null) : d;
    return Ticket(
      lines: [
        for (final l in lines)
          l.discount == null
              ? l
              : TicketLine(
                  item: l.item,
                  quantity: l.quantity,
                  discount: clean(l.discount),
                ),
      ],
      orderDiscount: clean(orderDiscount),
      voided: voided,
    );
  }

  static bool _unapproved(
    TicketDiscount? d,
    int cents,
    int base,
    int limitBp,
  ) =>
      d != null && d.approverStaffId == null && overLimit(cents, base, limitBp);

  Ticket copyWith({
    List<TicketLine>? lines,
    TicketDiscount? orderDiscount,
    bool clearOrderDiscount = false,
    List<VoidedLine>? voided,
  }) => Ticket(
    lines: lines ?? this.lines,
    orderDiscount: clearOrderDiscount
        ? null
        : (orderDiscount ?? this.orderDiscount),
    voided: voided ?? this.voided,
  );

  Map<String, Object?> toJson() => {
    'lines': [for (final l in lines) l.toJson()],
    'orderDiscount': orderDiscount?.toJson(),
    'voided': [for (final v in voided) v.toJson()],
  };

  factory Ticket.fromJson(Map<String, dynamic> j) => Ticket(
    lines: [
      for (final l in (j['lines'] as List? ?? const []))
        TicketLine.fromJson(l as Map<String, dynamic>),
    ],
    orderDiscount: j['orderDiscount'] == null
        ? null
        : TicketDiscount.fromJson(j['orderDiscount'] as Map<String, dynamic>),
    voided: [
      for (final v in (j['voided'] as List? ?? const []))
        VoidedLine.fromJson(v as Map<String, dynamic>),
    ],
  );
}

/// The time the ticket stamps on removals; tests override it.
final saleClockProvider = Provider<DateTime Function()>((_) => DateTime.now);

class TicketNotifier extends Notifier<Ticket> {
  @override
  Ticket build() => const Ticket();

  /// One more unit of [item]: a new line, or the same line again when the
  /// variant is already on the ticket.
  void add(SaleItem item) {
    final i = state.lines.indexWhere((l) => l.item.variantId == item.variantId);
    if (i < 0) {
      state = state.copyWith(
        lines: [
          ...state.lines,
          TicketLine(item: item, quantity: 1),
        ],
      );
    } else {
      setQuantity(i, state.lines[i].quantity + 1, staffId: '');
    }
  }

  /// Sets a line's quantity. Lowering it records the units taken off in
  /// the voided lines under [staffId] (`sale.void_line_before_payment`);
  /// zero removes the line.
  void setQuantity(int index, int quantity, {required String staffId}) {
    final line = state.lines[index];
    if (quantity == line.quantity || quantity < 0) return;
    final lines = [...state.lines];
    var voided = state.voided;
    if (quantity < line.quantity) {
      voided = [
        ...voided,
        VoidedLine(
          variantId: line.item.variantId,
          quantity: line.quantity - quantity,
          unitPriceCents: line.item.unitPriceCents,
          voidedAt: ref.read(saleClockProvider)().toUtc(),
          staffId: staffId,
        ),
      ];
    }
    if (quantity == 0) {
      lines.removeAt(index);
    } else {
      lines[index] = line.copyWith(quantity: quantity);
    }
    state = state.copyWith(lines: lines, voided: voided);
    _dropInvalidDiscounts();
  }

  void remove(int index, {required String staffId}) =>
      setQuantity(index, 0, staffId: staffId);

  void setLineDiscount(int index, TicketDiscount? discount) {
    final lines = [...state.lines];
    lines[index] = discount == null
        ? lines[index].copyWith(clearDiscount: true)
        : lines[index].copyWith(discount: discount);
    state = state.copyWith(lines: lines);
    _dropInvalidDiscounts();
  }

  void setOrderDiscount(TicketDiscount? discount) {
    state = discount == null
        ? state.copyWith(clearOrderDiscount: true)
        : state.copyWith(orderDiscount: discount);
    _dropInvalidDiscounts();
  }

  /// An amount discount larger than what is left after a quantity change
  /// cannot apply; it is removed rather than letting the total go wrong.
  void _dropInvalidDiscounts() {
    final lines = [
      for (final l in state.lines)
        if (l.discount?.kind == DiscountKind.amount &&
            l.discount!.value > l.item.unitPriceCents * l.quantity)
          l.copyWith(clearDiscount: true)
        else
          l,
    ];
    var t = state.copyWith(lines: lines);
    if (t.lines.isEmpty) {
      t = t.copyWith(clearOrderDiscount: true);
    } else if (t.orderDiscount?.kind == DiscountKind.amount) {
      final base = t.totals.afterLineCents;
      if (t.orderDiscount!.value > base) {
        t = t.copyWith(clearOrderDiscount: true);
      }
    }
    state = t;
  }

  /// Replaces the ticket (a held ticket resumed, or after a sale).
  void restore(Ticket ticket) => state = ticket;

  void clear() => state = const Ticket();
}

final ticketProvider = NotifierProvider<TicketNotifier, Ticket>(
  TicketNotifier.new,
);
