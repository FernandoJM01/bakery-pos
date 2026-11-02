import 'package:drift/drift.dart';

/// Shifts on this till (M4 brief 4), one row per drawer from float to Z
/// report. `OPEN` while selling, `COUNTED` when a flagged close still needs
/// its note, then `CLOSED`.
class LocalShifts extends Table {
  TextColumn get id => text()();
  TextColumn get status => text()();
  DateTimeColumn get openedAt => dateTime()();
  TextColumn get openedByStaffId => text()();
  TextColumn get openedByName => text()();
  IntColumn get floatCents => integer()();
  IntColumn get zNumber => integer().nullable()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  TextColumn get closedByStaffId => text().nullable()();
  TextColumn get closedByName => text().nullable()();
  IntColumn get expectedCents => integer().nullable()();
  IntColumn get countedCents => integer().nullable()();
  IntColumn get varianceCents => integer().nullable()();
  BoolColumn get flagged => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalCashMovements extends Table {
  TextColumn get id => text()();
  TextColumn get shiftId => text()();

  /// `IN` or `OUT`.
  TextColumn get kind => text()();
  IntColumn get amountCents => integer()();
  TextColumn get reason => text()();
  TextColumn get note => text().nullable()();
  TextColumn get staffId => text()();
  TextColumn get approverStaffId => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalCashCounts extends Table {
  TextColumn get shiftId => text()();

  /// `OPEN` or `CLOSE`.
  TextColumn get stage => text()();
  IntColumn get denominationCents => integer()();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {shiftId, stage, denominationCents};
}
