import 'package:drift/drift.dart' show Value;
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/features/sale/data/sale_repository.dart';
import 'package:bakery_pos/features/sale/domain/ticket.dart';

const iva0 = '019a1e00-0000-7000-8000-000000000001';
const iva16 = '019a1e00-0000-7000-8000-000000000002';
const ieps8 = '019a1e00-0000-7000-8000-000000000003';

final cashier = StaffEntry(
  id: '0192e2b0-0000-7000-8000-00000000c001',
  displayName: 'Ana',
  role: 'CASHIER',
  offlinePinVerifier: 'x',
  pinUpdatedAt: DateTime.utc(2026),
);

final manager = StaffEntry(
  id: '0192e2b0-0000-7000-8000-00000000a001',
  displayName: 'Carlos',
  role: 'BRANCH_MANAGER',
  offlinePinVerifier: 'x',
  pinUpdatedAt: DateTime.utc(2026),
);

const concha = SaleItem(
  variantId: '0192e2b0-0000-7000-8000-0000000000a1',
  productName: 'Concha',
  variantName: 'Pieza',
  unitPriceCents: 1500,
  ivaRateId: iva0,
  ivaBp: 0,
);

const galletas = SaleItem(
  variantId: '0192e2b0-0000-7000-8000-0000000000a2',
  productName: 'Galletas',
  variantName: 'Bolsa',
  unitPriceCents: 800,
  ivaRateId: iva0,
  ivaBp: 0,
);

const pastel = SaleItem(
  variantId: '0192e2b0-0000-7000-8000-0000000000a3',
  productName: 'Pastel',
  variantName: 'Rebanada',
  unitPriceCents: 2200,
  ivaRateId: iva16,
  ivaBp: 1600,
  iepsRateId: ieps8,
  iepsBp: 800,
);

/// Fills the till's catalog with [items] (one product each) and the folio
/// prefix, as a sync would.
Future<void> seedTill(
  AppDatabase db, {
  List<SaleItem> items = const [concha, galletas, pastel],
  String? prefix = 'SUC1-02',
}) async {
  await db.batch((b) {
    for (final (id, kind, bp) in [
      (iva0, 'IVA', 0),
      (iva16, 'IVA', 1600),
      (ieps8, 'IEPS', 800),
    ]) {
      b.insert(
        db.catalogTaxRates,
        CatalogTaxRatesCompanion.insert(
          id: id,
          kind: kind,
          name: '$kind $bp',
          rateBp: bp,
          isActive: true,
        ),
      );
    }
    b.insert(
      db.catalogCategories,
      CatalogCategoriesCompanion.insert(
        id: 'cat',
        name: 'Pan',
        sortOrder: 0,
        isActive: true,
      ),
    );
    for (final (i, it) in items.indexed) {
      b.insert(
        db.catalogProducts,
        CatalogProductsCompanion.insert(
          id: 'p-${it.variantId}',
          categoryId: 'cat',
          name: it.productName,
          unit: 'PIECE',
          ivaRateId: it.ivaRateId,
          iepsRateId: Value(it.iepsRateId),
          sortOrder: i,
          isActive: true,
        ),
      );
      b.insert(
        db.catalogVariants,
        CatalogVariantsCompanion.insert(
          id: it.variantId,
          productId: 'p-${it.variantId}',
          name: it.variantName,
          priceCents: it.unitPriceCents,
          sortOrder: 0,
          isActive: true,
        ),
      );
    }
  });
  if (prefix != null) await db.setSessionValue(folioPrefixKey, prefix);
}
