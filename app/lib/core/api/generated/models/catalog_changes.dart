// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'catalog_branch_price.dart';
import 'catalog_product.dart';
import 'catalog_variant.dart';
import 'category.dart';
import 'tax_rate.dart';

part 'catalog_changes.g.dart';

/// Flat rows for the till. Apply a page in one local transaction, then store `nextSince`.
/// Keep asking while `hasMore` is true. Inactive rows are sent so the till can hide them;.
/// a removed branch price comes with `removed: true` and `priceCents: null`.
///
@JsonSerializable()
class CatalogChanges {
  const CatalogChanges({
    required this.nextSince,
    required this.hasMore,
    required this.serverTime,
    required this.taxRates,
    required this.categories,
    required this.products,
    required this.variants,
    required this.branchPrices,
  });

  factory CatalogChanges.fromJson(Map<String, Object?> json) =>
      _$CatalogChangesFromJson(json);

  final int nextSince;
  final bool hasMore;
  final DateTime serverTime;
  final List<TaxRate> taxRates;
  final List<Category> categories;
  final List<CatalogProduct> products;
  final List<CatalogVariant> variants;

  /// Only the device's branch
  final List<CatalogBranchPrice> branchPrices;

  Map<String, Object?> toJson() => _$CatalogChangesToJson(this);
}
