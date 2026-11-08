// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oven_fee_rule_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvenFeeRuleUpdate _$OvenFeeRuleUpdateFromJson(Map<String, dynamic> json) =>
    OvenFeeRuleUpdate(
      name: json['name'] as String?,
      baseCents: (json['baseCents'] as num?)?.toInt(),
      perKgCents: (json['perKgCents'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OvenFeeRuleUpdateToJson(OvenFeeRuleUpdate instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'baseCents': ?instance.baseCents,
      'perKgCents': ?instance.perKgCents,
      'isActive': ?instance.isActive,
      'sortOrder': ?instance.sortOrder,
    };
