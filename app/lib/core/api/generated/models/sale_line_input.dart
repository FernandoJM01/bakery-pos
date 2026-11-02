// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'basis_points.dart';
import 'cents.dart';
import 'discount_input.dart';

part 'sale_line_input.g.dart';

@JsonSerializable()
class SaleLineInput {
  const SaleLineInput({
    required this.lineNo,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.unitPriceCents,
    required this.dayOld,
    required this.fullPriceCents,
    required this.ivaRateId,
    required this.ivaBp,
    required this.iepsBp,
    required this.grossCents,
    required this.lineDiscountCents,
    required this.orderDiscountCents,
    required this.netCents,
    required this.baseCents,
    required this.iepsCents,
    required this.ivaCents,
    this.iepsRateId,
    this.discount,
  });

  factory SaleLineInput.fromJson(Map<String, Object?> json) =>
      _$SaleLineInputFromJson(json);

  final int lineNo;
  final String variantId;
  final String productName;
  final String variantName;
  final int quantity;
  final Cents unitPriceCents;

  /// Sold from aged stock at the day-old price (M6.2)
  final bool dayOld;

  /// The price without the day-old reduction; equals `unitPriceCents` when not `dayOld`
  final Cents fullPriceCents;
  final String ivaRateId;
  final BasisPoints ivaBp;
  final String? iepsRateId;
  final BasisPoints iepsBp;
  final DiscountInput? discount;
  final AnyCents grossCents;
  final AnyCents lineDiscountCents;
  final AnyCents orderDiscountCents;
  final AnyCents netCents;
  final AnyCents baseCents;
  final AnyCents iepsCents;
  final AnyCents ivaCents;

  Map<String, Object?> toJson() => _$SaleLineInputToJson(this);
}
