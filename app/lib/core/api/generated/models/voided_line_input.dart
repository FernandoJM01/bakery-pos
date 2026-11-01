// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cents.dart';

part 'voided_line_input.g.dart';

@JsonSerializable()
class VoidedLineInput {
  const VoidedLineInput({
    required this.variantId,
    required this.quantity,
    required this.unitPriceCents,
    required this.voidedAt,
    required this.staffId,
  });

  factory VoidedLineInput.fromJson(Map<String, Object?> json) =>
      _$VoidedLineInputFromJson(json);

  final String variantId;
  final int quantity;
  final Cents unitPriceCents;
  final DateTime voidedAt;
  final String staffId;

  Map<String, Object?> toJson() => _$VoidedLineInputToJson(this);
}
