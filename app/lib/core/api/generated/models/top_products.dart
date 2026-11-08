// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'top_products.g.dart';

@JsonSerializable()
class TopProducts {
  const TopProducts({
    required this.variantId,
    required this.label,
    required this.quantity,
    required this.netCents,
  });

  factory TopProducts.fromJson(Map<String, Object?> json) =>
      _$TopProductsFromJson(json);

  final String variantId;
  final String label;
  final int quantity;
  final int netCents;

  Map<String, Object?> toJson() => _$TopProductsToJson(this);
}
