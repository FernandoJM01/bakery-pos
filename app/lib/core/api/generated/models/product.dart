// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'day_old_days.dart';
import 'product_unit.dart';
import 'variant.dart';

part 'product.g.dart';

/// Back office view, with variants and their branch prices.
@JsonSerializable()
class Product {
  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.unit,
    required this.photoId,
    required this.ivaRateId,
    required this.iepsRateId,
    required this.dayOldDiscountAfterDays,
    required this.dayOldDiscountBp,
    required this.dayOldWasteAfterDays,
    required this.sortOrder,
    required this.isActive,
    required this.updatedAt,
    required this.variants,
  });

  factory Product.fromJson(Map<String, Object?> json) =>
      _$ProductFromJson(json);

  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final ProductUnit unit;
  final String? photoId;
  final String ivaRateId;
  final String? iepsRateId;
  final DayOldDays dayOldDiscountAfterDays;
  final int? dayOldDiscountBp;
  final DayOldDays dayOldWasteAfterDays;
  final int sortOrder;
  final bool isActive;
  final DateTime updatedAt;
  final List<Variant> variants;

  Map<String, Object?> toJson() => _$ProductToJson(this);
}
