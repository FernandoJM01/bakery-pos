import 'package:drift/drift.dart';

/// Sales made on this till (M3 brief 4.1), written in one transaction with
/// their lines, discounts, the next folio number and the `sale.completed`
/// outbox record. Money is centavos with tax included.
class LocalSales extends Table {
  TextColumn get id => text()();
  TextColumn get folio => text().unique()();
  IntColumn get folioNumber => integer().unique()();

  /// Null only on sales from before shifts (M4).
  TextColumn get shiftId => text().nullable()();

  /// `CASH`, or `PREPAID` for an order pickup paid from the balance (M6).
  TextColumn get paymentMethod => text().withDefault(const Constant('CASH'))();
  TextColumn get orderTicketId => text().nullable()();
  TextColumn get cashierStaffId => text()();
  TextColumn get cashierName => text()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get grossCents => integer()();
  IntColumn get discountCents => integer()();
  IntColumn get totalCents => integer()();

  /// The one cash payment: what the customer gave and the change.
  IntColumn get tenderedCents => integer()();
  IntColumn get changeCents => integer()();

  /// `COMPLETED`, `PARTIALLY_REFUNDED`, `REFUNDED` or `VOIDED`.
  TextColumn get status => text().withDefault(const Constant('COMPLETED'))();
  IntColumn get refundedCents => integer().withDefault(const Constant(0))();

  /// Lines removed before payment, as the outbox payload's `voidedLines`.
  TextColumn get voidedLinesJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalSaleLines extends Table {
  TextColumn get saleId => text()();
  IntColumn get lineNo => integer()();
  TextColumn get variantId => text()();
  TextColumn get productName => text()();
  TextColumn get variantName => text()();
  IntColumn get quantity => integer()();
  IntColumn get unitPriceCents => integer()();
  IntColumn get grossCents => integer()();
  IntColumn get lineDiscountCents => integer()();
  IntColumn get orderDiscountCents => integer()();
  IntColumn get netCents => integer()();
  TextColumn get ivaRateId => text()();
  IntColumn get ivaBp => integer()();
  TextColumn get iepsRateId => text().nullable()();
  IntColumn get iepsBp => integer()();
  IntColumn get baseCents => integer()();
  IntColumn get iepsCents => integer()();
  IntColumn get ivaCents => integer()();
  IntColumn get refundedQuantity => integer().withDefault(const Constant(0))();
  IntColumn get refundedCents => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {saleId, lineNo};
}

class LocalSaleDiscounts extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();

  /// Null for the ticket discount.
  IntColumn get lineNo => integer().nullable()();
  TextColumn get kind => text()();
  IntColumn get value => integer()();
  IntColumn get cents => integer()();
  TextColumn get reason => text()();
  TextColumn get note => text().nullable()();
  TextColumn get approverStaffId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tickets put on hold (M3 brief 4.4). Local only: never synced, no folio
/// until paid. Any cashier on this till sees them.
class LocalHeldTickets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  DateTimeColumn get heldAt => dateTime()();
  TextColumn get heldByStaffId => text()();
  IntColumn get lineCount => integer()();
  IntColumn get totalCents => integer()();

  /// The whole ticket (lines with their prices, discounts, voided units).
  TextColumn get ticketJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Refunds and voids recorded on this till (M3 brief 4.3), for any sale of
/// the branch. The sale's own rows are updated when it was made here.
class LocalRefunds extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get folio => text()();

  /// The shift of this till that paid the money (M4).
  TextColumn get shiftId => text().nullable()();

  /// False when the money went back to a customer's balance, not the
  /// drawer: the sale was a pickup (M6).
  BoolColumn get cash => boolean().withDefault(const Constant(true))();

  /// `REFUND` or `VOID`.
  TextColumn get kind => text()();
  TextColumn get reason => text()();
  TextColumn get note => text().nullable()();
  TextColumn get staffId => text()();
  TextColumn get approverStaffId => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get totalCents => integer()();

  /// The refund lines, as the outbox payload's `lines`.
  TextColumn get linesJson => text()();

  /// `lineNo`, `ivaBp` and `iepsBp` per line, for the Z report: a sale made
  /// on another till has no lines here to read them from.
  TextColumn get ratesJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}
