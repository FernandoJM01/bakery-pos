// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variant_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VariantCreate _$VariantCreateFromJson(Map<String, dynamic> json) =>
    VariantCreate(
      name: json['name'] as String,
      priceCents: (json['priceCents'] as num).toInt(),
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$VariantCreateToJson(VariantCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sku': ?instance.sku,
      'barcode': ?instance.barcode,
      'priceCents': instance.priceCents,
      'sortOrder': ?instance.sortOrder,
    };
