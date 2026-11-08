// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'lines4.g.dart';

@JsonSerializable()
class Lines4 {
  const Lines4({
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.quantity,
  });

  factory Lines4.fromJson(Map<String, Object?> json) => _$Lines4FromJson(json);

  final String variantId;
  final String productName;
  final String variantName;
  final int quantity;

  Map<String, Object?> toJson() => _$Lines4ToJson(this);
}
