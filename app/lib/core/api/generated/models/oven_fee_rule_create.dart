// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'oven_fee_rule_create.g.dart';

@JsonSerializable()
class OvenFeeRuleCreate {
  const OvenFeeRuleCreate({
    required this.name,
    required this.baseCents,
    required this.perKgCents,
    required this.ivaRateId,
    this.sortOrder,
  });

  factory OvenFeeRuleCreate.fromJson(Map<String, Object?> json) =>
      _$OvenFeeRuleCreateFromJson(json);

  final String name;
  final int baseCents;
  final int perKgCents;
  final String ivaRateId;
  final int? sortOrder;

  Map<String, Object?> toJson() => _$OvenFeeRuleCreateToJson(this);
}
