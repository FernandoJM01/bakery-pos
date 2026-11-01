// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cents.dart';

part 'voided_line.g.dart';

@JsonSerializable()
class VoidedLine {
  const VoidedLine({
    required this.variantId,
    required this.quantity,
    required this.unitPriceCents,
    required this.voidedAt,
    required this.staffId,
  });

  factory VoidedLine.fromJson(Map<String, Object?> json) =>
      _$VoidedLineFromJson(json);

  final String variantId;
  final int quantity;
  final Cents unitPriceCents;
  final DateTime voidedAt;
  final String staffId;

  Map<String, Object?> toJson() => _$VoidedLineToJson(this);
}
