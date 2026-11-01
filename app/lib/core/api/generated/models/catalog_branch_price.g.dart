// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_branch_price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogBranchPrice _$CatalogBranchPriceFromJson(Map<String, dynamic> json) =>
    CatalogBranchPrice(
      variantId: json['variantId'] as String,
      priceCents: (json['priceCents'] as num?)?.toInt(),
      removed: json['removed'] as bool,
    );

Map<String, dynamic> _$CatalogBranchPriceToJson(CatalogBranchPrice instance) =>
    <String, dynamic>{
      'variantId': instance.variantId,
      'priceCents': ?instance.priceCents,
      'removed': instance.removed,
    };
