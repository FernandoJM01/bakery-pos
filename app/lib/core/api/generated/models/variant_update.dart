// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cents.dart';

part 'variant_update.g.dart';

@JsonSerializable()
class VariantUpdate {
  const VariantUpdate({
    this.name,
    this.sku,
    this.barcode,
    this.priceCents,
    this.costCents,
    this.unitsPerTray,
    this.sortOrder,
    this.isActive,
  });

  factory VariantUpdate.fromJson(Map<String, Object?> json) =>
      _$VariantUpdateFromJson(json);

  final String? name;
  final String? sku;
  final String? barcode;
  final Cents? priceCents;
  final Cents? costCents;
  final int? unitsPerTray;
  final int? sortOrder;
  final bool? isActive;

  Map<String, Object?> toJson() => _$VariantUpdateToJson(this);
}
