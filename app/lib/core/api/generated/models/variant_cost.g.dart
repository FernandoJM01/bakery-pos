// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variant_cost.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VariantCost _$VariantCostFromJson(Map<String, dynamic> json) => VariantCost(
  variantId: json['variantId'] as String,
  productName: json['productName'] as String,
  variantName: json['variantName'] as String,
  categoryName: json['categoryName'] as String,
  priceCents: (json['priceCents'] as num).toInt(),
  costCents: (json['costCents'] as num?)?.toInt(),
);

Map<String, dynamic> _$VariantCostToJson(VariantCost instance) =>
    <String, dynamic>{
      'variantId': instance.variantId,
      'productName': instance.productName,
      'variantName': instance.variantName,
      'categoryName': instance.categoryName,
      'priceCents': instance.priceCents,
      'costCents': ?instance.costCents,
    };
