// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'basis_points.dart';

part 'oven_fee_rule.g.dart';

/// A dish type. The fee is `baseCents + round(perKgCents × weightGrams / 1000)`, sold with the variant below (M8).
@JsonSerializable()
class OvenFeeRule {
  const OvenFeeRule({
    required this.id,
    required this.name,
    required this.baseCents,
    required this.perKgCents,
    required this.isActive,
    required this.sortOrder,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.ivaRateId,
    required this.ivaBp,
    required this.iepsRateId,
    required this.iepsBp,
  });

  factory OvenFeeRule.fromJson(Map<String, Object?> json) =>
      _$OvenFeeRuleFromJson(json);

  final String id;
  final String name;
  final AnyCents baseCents;
  final AnyCents perKgCents;
  final bool isActive;
  final int sortOrder;
  final String variantId;
  final String productName;
  final String variantName;
  final String ivaRateId;
  final BasisPoints ivaBp;
  final String? iepsRateId;
  final BasisPoints iepsBp;

  Map<String, Object?> toJson() => _$OvenFeeRuleToJson(this);
}
