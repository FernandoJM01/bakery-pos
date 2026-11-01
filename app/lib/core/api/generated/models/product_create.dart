// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'day_old_days.dart';
import 'product_unit.dart';
import 'variant_create.dart';

part 'product_create.g.dart';

/// Day-old discount days and percentage are both set or both null; waste days must be greater than discount days when both are set.
@JsonSerializable()
class ProductCreate {
  const ProductCreate({
    required this.categoryId,
    required this.name,
    required this.unit,
    required this.ivaRateId,
    required this.variants,
    this.description,
    this.photoId,
    this.iepsRateId,
    this.dayOldDiscountAfterDays,
    this.dayOldDiscountBp,
    this.dayOldWasteAfterDays,
    this.sortOrder,
  });

  factory ProductCreate.fromJson(Map<String, Object?> json) =>
      _$ProductCreateFromJson(json);

  final String categoryId;
  final String name;
  final String? description;
  final ProductUnit unit;
  final String? photoId;
  final String ivaRateId;
  final String? iepsRateId;
  final DayOldDays? dayOldDiscountAfterDays;
  final int? dayOldDiscountBp;
  final DayOldDays? dayOldWasteAfterDays;
  final int? sortOrder;
  final List<VariantCreate> variants;

  Map<String, Object?> toJson() => _$ProductCreateToJson(this);
}
