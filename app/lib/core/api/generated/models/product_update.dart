// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'day_old_days.dart';
import 'product_unit.dart';

part 'product_update.g.dart';

@JsonSerializable()
class ProductUpdate {
  const ProductUpdate({
    this.categoryId,
    this.name,
    this.description,
    this.unit,
    this.photoId,
    this.ivaRateId,
    this.iepsRateId,
    this.dayOldDiscountAfterDays,
    this.dayOldDiscountBp,
    this.dayOldWasteAfterDays,
    this.sortOrder,
    this.isActive,
  });

  factory ProductUpdate.fromJson(Map<String, Object?> json) =>
      _$ProductUpdateFromJson(json);

  final String? categoryId;
  final String? name;
  final String? description;
  final ProductUnit? unit;
  final String? photoId;
  final String? ivaRateId;
  final String? iepsRateId;
  final DayOldDays? dayOldDiscountAfterDays;
  final int? dayOldDiscountBp;
  final DayOldDays? dayOldWasteAfterDays;
  final int? sortOrder;
  final bool? isActive;

  Map<String, Object?> toJson() => _$ProductUpdateToJson(this);
}
