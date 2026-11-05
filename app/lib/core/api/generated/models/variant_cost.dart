// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cents.dart';

part 'variant_cost.g.dart';

@JsonSerializable()
class VariantCost {
  const VariantCost({
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.categoryName,
    required this.priceCents,
    required this.costCents,
  });

  factory VariantCost.fromJson(Map<String, Object?> json) =>
      _$VariantCostFromJson(json);

  final String variantId;
  final String productName;
  final String variantName;
  final String categoryName;
  final Cents priceCents;
  final int? costCents;

  Map<String, Object?> toJson() => _$VariantCostToJson(this);
}
