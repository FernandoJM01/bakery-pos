// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'totals.g.dart';

@JsonSerializable()
class Totals {
  const Totals({
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.quantity,
  });

  factory Totals.fromJson(Map<String, Object?> json) => _$TotalsFromJson(json);

  final String variantId;
  final String productName;
  final String variantName;
  final int quantity;

  Map<String, Object?> toJson() => _$TotalsToJson(this);
}
