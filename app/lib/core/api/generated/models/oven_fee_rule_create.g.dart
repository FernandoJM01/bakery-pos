// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oven_fee_rule_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvenFeeRuleCreate _$OvenFeeRuleCreateFromJson(Map<String, dynamic> json) =>
    OvenFeeRuleCreate(
      name: json['name'] as String,
      baseCents: (json['baseCents'] as num).toInt(),
      perKgCents: (json['perKgCents'] as num).toInt(),
      ivaRateId: json['ivaRateId'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OvenFeeRuleCreateToJson(OvenFeeRuleCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'baseCents': instance.baseCents,
      'perKgCents': instance.perKgCents,
      'ivaRateId': instance.ivaRateId,
      'sortOrder': ?instance.sortOrder,
    };
