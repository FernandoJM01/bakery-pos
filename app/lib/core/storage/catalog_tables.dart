import 'package:drift/drift.dart';

/// The till's copy of the catalog (M2 brief 4.2). Money is centavos; rows
/// are never deleted except a removed branch price, so inactive rows stay
/// and the grid hides them.
class CatalogTaxRates extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get name => text()();
  IntColumn get rateBp => integer()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

class CatalogCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();
  TextColumn get color => text().nullable()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

class CatalogProducts extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  TextColumn get name => text()();
  TextColumn get unit => text()();
  TextColumn get photoId => text().nullable()();
  TextColumn get ivaRateId => text()();
  TextColumn get iepsRateId => text().nullable()();
  IntColumn get dayOldDiscountAfterDays => integer().nullable()();
  IntColumn get dayOldDiscountBp => integer().nullable()();
  IntColumn get dayOldWasteAfterDays => integer().nullable()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

class CatalogVariants extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  IntColumn get priceCents => integer()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

/// This branch's price overrides only; the server sends no other branch's.
class CatalogBranchPrices extends Table {
  TextColumn get variantId => text()();
  IntColumn get priceCents => integer()();

  @override
  Set<Column> get primaryKey => {variantId};
}

/// Sync bookkeeping, one row per key (for now `lastCatalogSeq`).
class SyncStateEntries extends Table {
  TextColumn get key => text()();
  IntColumn get intValue => integer()();

  @override
  Set<Column> get primaryKey => {key};
}
