import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/models/catalog_changes.dart';
import '../../../core/api/generated/sync/sync_api_client.dart';
import '../../../core/storage/local_database.dart';

const lastCatalogSeqKey = 'lastCatalogSeq';

/// One product as the grid shows it: active variants with the price that
/// applies in this branch (the branch price when there is one).
class GridProduct {
  const GridProduct({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.photoId,
    required this.variants,
    this.ivaRateId = '',
    this.ivaBp = 0,
    this.iepsRateId,
    this.iepsBp = 0,
    this.dayOldAfterDays,
    this.dayOldBp,
  });

  final String id;
  final String categoryId;
  final String name;
  final String? photoId;
  final List<GridVariant> variants;

  /// The product's tax rates as the till's copy has them; a sale line keeps
  /// the id and the rate (M3 brief 4.5).
  final String ivaRateId;
  final int ivaBp;
  final String? iepsRateId;
  final int iepsBp;

  /// The product's day-old rule (M6.1); null when it has none.
  final int? dayOldAfterDays;
  final int? dayOldBp;

  int get lowestPriceCents =>
      variants.map((v) => v.priceCents).reduce((a, b) => a < b ? a : b);
  bool get hasPriceRange =>
      variants.any((v) => v.priceCents != variants.first.priceCents);
}

class GridVariant {
  const GridVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.priceCents,
    this.unitsPerTray,
  });

  final String id;
  final String name;
  final String? sku;
  final String? barcode;
  final int priceCents;
  final int? unitsPerTray;
}

class GridCategory {
  const GridCategory({required this.id, required this.name, this.color});

  final String id;
  final String name;
  final String? color;
}

class TillCatalog {
  const TillCatalog({required this.categories, required this.products});

  final List<GridCategory> categories;
  final List<GridProduct> products;
}

/// Keeps the till's catalog in the encrypted local database and brings it up
/// to date from `GET /v1/sync/catalog`.
class TillCatalogRepository {
  TillCatalogRepository(this._db, this._api);

  final AppDatabase _db;
  final SyncApiClient _api;

  Future<int> lastSeq() async {
    final row = await (_db.select(
      _db.syncStateEntries,
    )..where((t) => t.key.equals(lastCatalogSeqKey))).getSingleOrNull();
    return row?.intValue ?? 0;
  }

  /// Pulls every page after the stored sequence. Each page is applied in one
  /// transaction together with its `nextSince`, so a failure part way keeps
  /// the pages already applied and the next pull resumes after them.
  /// Returns the number of rows applied.
  Future<int> pull({int pageSize = 500}) async {
    var since = await lastSeq();
    var applied = 0;
    for (;;) {
      final page = await _api.pullCatalog(since: since, limit: pageSize);
      await applyPage(page);
      applied +=
          page.taxRates.length +
          page.categories.length +
          page.products.length +
          page.variants.length +
          page.branchPrices.length;
      since = page.nextSince;
      if (!page.hasMore) return applied;
    }
  }

  Future<void> applyPage(CatalogChanges page) => _db.transaction(() async {
    await _db.batch((b) {
      for (final t in page.taxRates) {
        b.insert(
          _db.catalogTaxRates,
          CatalogTaxRatesCompanion.insert(
            id: t.id,
            kind: t.kind.json ?? '',
            name: t.name,
            rateBp: t.rateBp,
            isActive: t.isActive,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
      for (final c in page.categories) {
        b.insert(
          _db.catalogCategories,
          CatalogCategoriesCompanion.insert(
            id: c.id,
            name: c.name,
            sortOrder: c.sortOrder,
            color: Value(c.color),
            isActive: c.isActive,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
      for (final p in page.products) {
        b.insert(
          _db.catalogProducts,
          CatalogProductsCompanion.insert(
            id: p.id,
            categoryId: p.categoryId,
            name: p.name,
            unit: p.unit.json ?? '',
            photoId: Value(p.photoId),
            ivaRateId: p.ivaRateId,
            iepsRateId: Value(p.iepsRateId),
            dayOldDiscountAfterDays: Value(p.dayOldDiscountAfterDays),
            dayOldDiscountBp: Value(p.dayOldDiscountBp),
            dayOldWasteAfterDays: Value(p.dayOldWasteAfterDays),
            sortOrder: p.sortOrder,
            isActive: p.isActive,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
      for (final v in page.variants) {
        b.insert(
          _db.catalogVariants,
          CatalogVariantsCompanion.insert(
            id: v.id,
            productId: v.productId,
            name: v.name,
            sku: Value(v.sku),
            barcode: Value(v.barcode),
            priceCents: v.priceCents,
            unitsPerTray: Value(v.unitsPerTray),
            sortOrder: v.sortOrder,
            isActive: v.isActive,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
      for (final bp in page.branchPrices) {
        if (bp.removed || bp.priceCents == null) {
          b.deleteWhere(
            _db.catalogBranchPrices,
            (t) => t.variantId.equals(bp.variantId),
          );
        } else {
          b.insert(
            _db.catalogBranchPrices,
            CatalogBranchPricesCompanion.insert(
              variantId: bp.variantId,
              priceCents: bp.priceCents!,
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      }
      b.insert(
        _db.syncStateEntries,
        SyncStateEntriesCompanion.insert(
          key: lastCatalogSeqKey,
          intValue: page.nextSince,
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  });

  /// The active catalog, in display order. Products whose category is
  /// inactive, or that have no active variant, are left out.
  Future<TillCatalog> load() async {
    final cats =
        await (_db.select(_db.catalogCategories)
              ..where((c) => c.isActive.equals(true))
              ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
            .get();
    final products =
        await (_db.select(_db.catalogProducts)
              ..where((p) => p.isActive.equals(true))
              ..orderBy([
                (p) => OrderingTerm(expression: p.sortOrder),
                (p) => OrderingTerm(expression: p.name),
              ]))
            .get();
    final variants =
        await (_db.select(_db.catalogVariants)
              ..where((v) => v.isActive.equals(true))
              ..orderBy([(v) => OrderingTerm(expression: v.sortOrder)]))
            .get();
    final prices = {
      for (final bp in await _db.select(_db.catalogBranchPrices).get())
        bp.variantId: bp.priceCents,
    };
    final rates = {
      for (final r in await _db.select(_db.catalogTaxRates).get())
        r.id: r.rateBp,
    };
    final activeCats = {for (final c in cats) c.id};
    final byProduct = <String, List<GridVariant>>{};
    for (final v in variants) {
      byProduct
          .putIfAbsent(v.productId, () => [])
          .add(
            GridVariant(
              id: v.id,
              name: v.name,
              sku: v.sku,
              barcode: v.barcode,
              priceCents: prices[v.id] ?? v.priceCents,
              unitsPerTray: v.unitsPerTray,
            ),
          );
    }
    return TillCatalog(
      categories: [
        for (final c in cats)
          GridCategory(id: c.id, name: c.name, color: c.color),
      ],
      products: [
        for (final p in products)
          if (activeCats.contains(p.categoryId) && byProduct[p.id] != null)
            GridProduct(
              id: p.id,
              categoryId: p.categoryId,
              name: p.name,
              photoId: p.photoId,
              variants: byProduct[p.id]!,
              ivaRateId: p.ivaRateId,
              ivaBp: rates[p.ivaRateId] ?? 0,
              iepsRateId: p.iepsRateId,
              iepsBp: p.iepsRateId == null ? 0 : rates[p.iepsRateId] ?? 0,
              dayOldAfterDays: p.dayOldDiscountAfterDays,
              dayOldBp: p.dayOldDiscountBp,
            ),
      ],
    );
  }
}

/// Lower-case and without accents, so "pina" finds "Piña" and "CONCHA"
/// finds "concha".
String foldForSearch(String s) {
  const from = 'áàäâéèëêíìïîóòöôúùüûñ';
  const to = 'aaaaeeeeiiiioooouuuun';
  final lower = s.toLowerCase();
  final out = StringBuffer();
  for (final ch in lower.split('')) {
    final i = from.indexOf(ch);
    out.write(i < 0 ? ch : to[i]);
  }
  return out.toString();
}

/// Products matching a search by product name, variant name, SKU or barcode.
List<GridProduct> searchProducts(List<GridProduct> products, String query) {
  final q = foldForSearch(query.trim());
  if (q.isEmpty) return products;
  return [
    for (final p in products)
      if (foldForSearch(p.name).contains(q) ||
          p.variants.any(
            (v) =>
                foldForSearch(v.name).contains(q) ||
                (v.sku != null && foldForSearch(v.sku!).contains(q)) ||
                (v.barcode != null && v.barcode!.contains(query.trim())),
          ))
        p,
  ];
}

final tillCatalogRepositoryProvider = Provider<TillCatalogRepository>(
  (ref) => TillCatalogRepository(
    ref.watch(tillDatabaseProvider),
    ref.watch(restClientProvider).sync,
  ),
);

/// The local catalog the grid shows; invalidated after each pull.
final tillCatalogProvider = FutureProvider<TillCatalog>(
  (ref) => ref.watch(tillCatalogRepositoryProvider).load(),
);
