// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cents.dart';

part 'variant_create.g.dart';

@JsonSerializable()
class VariantCreate {
  const VariantCreate({
    required this.name,
    required this.priceCents,
    this.sku,
    this.barcode,
    this.sortOrder,
  });

  factory VariantCreate.fromJson(Map<String, Object?> json) =>
      _$VariantCreateFromJson(json);

  final String name;
  final String? sku;
  final String? barcode;
  final Cents priceCents;
  final int? sortOrder;

  Map<String, Object?> toJson() => _$VariantCreateToJson(this);
}
