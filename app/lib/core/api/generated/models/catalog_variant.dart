// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cents.dart';

part 'catalog_variant.g.dart';

@JsonSerializable()
class CatalogVariant {
  const CatalogVariant({
    required this.id,
    required this.productId,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.priceCents,
    required this.unitsPerTray,
    required this.sortOrder,
    required this.isActive,
  });

  factory CatalogVariant.fromJson(Map<String, Object?> json) =>
      _$CatalogVariantFromJson(json);

  final String id;
  final String productId;
  final String name;
  final String? sku;
  final String? barcode;
  final Cents priceCents;

  /// Production entry works in trays when set
  final int? unitsPerTray;
  final int sortOrder;
  final bool isActive;

  Map<String, Object?> toJson() => _$CatalogVariantToJson(this);
}
