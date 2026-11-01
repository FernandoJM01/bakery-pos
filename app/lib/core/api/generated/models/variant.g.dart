// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Variant _$VariantFromJson(Map<String, dynamic> json) => Variant(
  id: json['id'] as String,
  productId: json['productId'] as String,
  name: json['name'] as String,
  sku: json['sku'] as String?,
  barcode: json['barcode'] as String?,
  priceCents: (json['priceCents'] as num).toInt(),
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  branchPrices: (json['branchPrices'] as List<dynamic>)
      .map((e) => BranchPrice.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VariantToJson(Variant instance) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'name': instance.name,
  'sku': ?instance.sku,
  'barcode': ?instance.barcode,
  'priceCents': instance.priceCents,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'branchPrices': instance.branchPrices,
};
