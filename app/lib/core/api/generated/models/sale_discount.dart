// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'discount_kind.dart';
import 'discount_reason.dart';

part 'sale_discount.g.dart';

@JsonSerializable()
class SaleDiscount {
  const SaleDiscount({
    required this.lineNo,
    required this.kind,
    required this.value,
    required this.cents,
    required this.reason,
    required this.note,
    required this.approverStaffId,
  });

  factory SaleDiscount.fromJson(Map<String, Object?> json) =>
      _$SaleDiscountFromJson(json);

  /// Null for a ticket discount
  final int? lineNo;
  final DiscountKind kind;
  final int value;
  final AnyCents cents;
  final DiscountReason reason;
  final String? note;
  final String? approverStaffId;

  Map<String, Object?> toJson() => _$SaleDiscountToJson(this);
}
