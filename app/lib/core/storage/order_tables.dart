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

/// Oven service fees from the server (M8): one row per dish type.
class LocalOvenRules extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get baseCents => integer()();
  IntColumn get perKgCents => integer()();
  TextColumn get variantId => text()();
  TextColumn get productName => text()();
  TextColumn get ivaRateId => text()();
  IntColumn get ivaBp => integer()();
  TextColumn get iepsRateId => text().nullable()();
  IntColumn get iepsBp => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Dishes in this branch's oven, as the server last sent them.
class LocalOvenTickets extends Table {
  TextColumn get id => text()();
  TextColumn get tag => text()();
  TextColumn get customerName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get description => text()();
  TextColumn get ruleId => text()();
  IntColumn get weightGrams => integer()();
  IntColumn get feeCents => integer()();
  DateTimeColumn get requestedAt => dateTime()();

  /// `RECEIVED`, `IN_OVEN`, `READY` or `PICKED_UP`.
  TextColumn get status => text()();
  DateTimeColumn get readyAt => dateTime().nullable()();
  BoolColumn get paid => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}
