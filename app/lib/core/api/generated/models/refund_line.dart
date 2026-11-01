// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';

part 'refund_line.g.dart';

@JsonSerializable()
class RefundLine {
  const RefundLine({
    required this.lineNo,
    required this.quantity,
    required this.amountCents,
    required this.baseCents,
    required this.iepsCents,
    required this.ivaCents,
    required this.restock,
  });

  factory RefundLine.fromJson(Map<String, Object?> json) =>
      _$RefundLineFromJson(json);

  final int lineNo;
  final int quantity;
  final AnyCents amountCents;
  final AnyCents baseCents;
  final AnyCents iepsCents;
  final AnyCents ivaCents;
  final bool restock;

  Map<String, Object?> toJson() => _$RefundLineToJson(this);
}
