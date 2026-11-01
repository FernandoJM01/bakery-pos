// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'branch_price.dart';
import 'cents.dart';

part 'variant.g.dart';

@JsonSerializable()
class Variant {
  const Variant({
    required this.id,
    required this.productId,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.priceCents,
    required this.sortOrder,
    required this.isActive,
    required this.updatedAt,
    required this.branchPrices,
  });

  factory Variant.fromJson(Map<String, Object?> json) =>
      _$VariantFromJson(json);

  final String id;
  final String productId;
  final String name;
  final String? sku;
  final String? barcode;
  final Cents priceCents;
  final int sortOrder;
  final bool isActive;
  final DateTime updatedAt;
  final List<BranchPrice> branchPrices;

  Map<String, Object?> toJson() => _$VariantToJson(this);
}
