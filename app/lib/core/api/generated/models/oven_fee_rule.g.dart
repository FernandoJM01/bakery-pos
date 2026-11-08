// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oven_fee_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvenFeeRule _$OvenFeeRuleFromJson(Map<String, dynamic> json) => OvenFeeRule(
  id: json['id'] as String,
  name: json['name'] as String,
  baseCents: (json['baseCents'] as num).toInt(),
  perKgCents: (json['perKgCents'] as num).toInt(),
  isActive: json['isActive'] as bool,
  sortOrder: (json['sortOrder'] as num).toInt(),
  variantId: json['variantId'] as String,
  productName: json['productName'] as String,
  variantName: json['variantName'] as String,
  ivaRateId: json['ivaRateId'] as String,
  ivaBp: (json['ivaBp'] as num).toInt(),
  iepsRateId: json['iepsRateId'] as String?,
  iepsBp: (json['iepsBp'] as num).toInt(),
);

Map<String, dynamic> _$OvenFeeRuleToJson(OvenFeeRule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'baseCents': instance.baseCents,
      'perKgCents': instance.perKgCents,
      'isActive': instance.isActive,
      'sortOrder': instance.sortOrder,
      'variantId': instance.variantId,
      'productName': instance.productName,
      'variantName': instance.variantName,
      'ivaRateId': instance.ivaRateId,
      'ivaBp': instance.ivaBp,
      'iepsRateId': ?instance.iepsRateId,
      'iepsBp': instance.iepsBp,
    };
