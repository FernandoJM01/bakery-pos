// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'day_old_days.dart';
import 'product_unit.dart';

part 'catalog_product.g.dart';

@JsonSerializable()
class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.unit,
    required this.photoId,
    required this.ivaRateId,
    required this.iepsRateId,
    required this.dayOldDiscountAfterDays,
    required this.dayOldDiscountBp,
    required this.dayOldWasteAfterDays,
    required this.sortOrder,
    required this.isActive,
  });

  factory CatalogProduct.fromJson(Map<String, Object?> json) =>
      _$CatalogProductFromJson(json);

  final String id;
  final String categoryId;
  final String name;
  final ProductUnit unit;
  final String? photoId;
  final String ivaRateId;
  final String? iepsRateId;
  final DayOldDays dayOldDiscountAfterDays;
  final int? dayOldDiscountBp;
  final DayOldDays dayOldWasteAfterDays;
  final int sortOrder;
  final bool isActive;

  Map<String, Object?> toJson() => _$CatalogProductToJson(this);
}
