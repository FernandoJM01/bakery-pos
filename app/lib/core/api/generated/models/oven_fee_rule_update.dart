// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'oven_fee_rule_update.g.dart';

@JsonSerializable()
class OvenFeeRuleUpdate {
  const OvenFeeRuleUpdate({
    this.name,
    this.baseCents,
    this.perKgCents,
    this.isActive,
    this.sortOrder,
  });

  factory OvenFeeRuleUpdate.fromJson(Map<String, Object?> json) =>
      _$OvenFeeRuleUpdateFromJson(json);

  final String? name;
  final int? baseCents;
  final int? perKgCents;
  final bool? isActive;
  final int? sortOrder;

  Map<String, Object?> toJson() => _$OvenFeeRuleUpdateToJson(this);
}
