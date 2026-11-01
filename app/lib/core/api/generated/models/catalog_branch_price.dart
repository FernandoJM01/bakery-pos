// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'catalog_branch_price.g.dart';

@JsonSerializable()
class CatalogBranchPrice {
  const CatalogBranchPrice({
    required this.variantId,
    required this.priceCents,
    required this.removed,
  });

  factory CatalogBranchPrice.fromJson(Map<String, Object?> json) =>
      _$CatalogBranchPriceFromJson(json);

  final String variantId;
  final int? priceCents;
  final bool removed;

  Map<String, Object?> toJson() => _$CatalogBranchPriceToJson(this);
}
