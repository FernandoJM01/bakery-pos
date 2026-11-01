// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';

part 'refund_line_input.g.dart';

@JsonSerializable()
class RefundLineInput {
  const RefundLineInput({
    required this.lineNo,
    required this.quantity,
    required this.amountCents,
    required this.baseCents,
    required this.iepsCents,
    required this.ivaCents,
    required this.restock,
  });

  factory RefundLineInput.fromJson(Map<String, Object?> json) =>
      _$RefundLineInputFromJson(json);

  final int lineNo;
  final int quantity;
  final AnyCents amountCents;
  final AnyCents baseCents;
  final AnyCents iepsCents;
  final AnyCents ivaCents;

  /// The units go back to stock (used from Sprint 5)
  final bool restock;

  Map<String, Object?> toJson() => _$RefundLineInputToJson(this);
}
