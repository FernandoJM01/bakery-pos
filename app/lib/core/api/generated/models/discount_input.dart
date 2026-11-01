// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'discount_kind.dart';
import 'discount_reason.dart';

part 'discount_input.g.dart';

@JsonSerializable()
class DiscountInput {
  const DiscountInput({
    required this.kind,
    required this.value,
    required this.reason,
    this.note,
    this.approverStaffId,
  });

  factory DiscountInput.fromJson(Map<String, Object?> json) =>
      _$DiscountInputFromJson(json);

  final DiscountKind kind;

  /// Basis points for PERCENT (at most 10000), centavos for AMOUNT
  final int value;
  final DiscountReason reason;
  final String? note;

  /// Required when the discount's share is above `discountLimitBp`; must hold `sale.discount_over_limit`
  final String? approverStaffId;

  Map<String, Object?> toJson() => _$DiscountInputToJson(this);
}
