// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'basis_points.dart';
import 'cents.dart';

part 'sale_line.g.dart';

@JsonSerializable()
class SaleLine {
  const SaleLine({
    required this.lineNo,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.unitPriceCents,
    required this.grossCents,
    required this.lineDiscountCents,
    required this.orderDiscountCents,
    required this.netCents,
    required this.ivaRateId,
    required this.ivaBp,
    required this.iepsRateId,
    required this.iepsBp,
    required this.baseCents,
    required this.iepsCents,
    required this.ivaCents,
    required this.refundedQuantity,
    this.refundedCents,
  });

  factory SaleLine.fromJson(Map<String, Object?> json) =>
      _$SaleLineFromJson(json);

  final int lineNo;
  final String variantId;
  final String productName;
  final String variantName;
  final int quantity;
  final Cents unitPriceCents;
  final AnyCents grossCents;
  final AnyCents lineDiscountCents;
  final AnyCents orderDiscountCents;
  final AnyCents netCents;
  final String ivaRateId;
  final BasisPoints ivaBp;
  final String? iepsRateId;
  final BasisPoints iepsBp;
  final AnyCents baseCents;
  final AnyCents iepsCents;
  final AnyCents ivaCents;
  final int refundedQuantity;
  final AnyCents? refundedCents;

  Map<String, Object?> toJson() => _$SaleLineToJson(this);
}
