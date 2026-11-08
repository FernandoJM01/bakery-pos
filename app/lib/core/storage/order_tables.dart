import 'package:drift/drift.dart';

/// Order tickets of this branch from the server (M6 brief 4.4), so the
/// counter can hand orders over offline.
class LocalOrderTickets extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get customerId => text()();
  TextColumn get customerName => text()();
  TextColumn get customerPhone => text().nullable()();

  /// The customer's balance when the server sent this.
  IntColumn get balanceCents => integer()();

  /// YYYY-MM-DD and HH:MM at the branch.
  TextColumn get dueDate => text()();
  TextColumn get pickupTime => text()();
  TextColumn get status => text()();
  IntColumn get totalCents => integer()();

  /// The `OrderTicketLine` rows as JSON.
  TextColumn get linesJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Prepayments taken on this till, for expected cash and the Z report.
class LocalPrepayments extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text()();
  TextColumn get customerName => text()();
  TextColumn get shiftId => text()();
  IntColumn get amountCents => integer()();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
