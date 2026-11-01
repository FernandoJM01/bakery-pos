// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_variant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogVariant _$CatalogVariantFromJson(Map<String, dynamic> json) =>
    CatalogVariant(
      id: json['id'] as String,
      productId: json['productId'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      priceCents: (json['priceCents'] as num).toInt(),
      sortOrder: (json['sortOrder'] as num).toInt(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$CatalogVariantToJson(CatalogVariant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'name': instance.name,
      'sku': ?instance.sku,
      'barcode': ?instance.barcode,
      'priceCents': instance.priceCents,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };
