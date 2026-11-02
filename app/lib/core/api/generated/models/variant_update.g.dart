// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variant_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VariantUpdate _$VariantUpdateFromJson(Map<String, dynamic> json) =>
    VariantUpdate(
      name: json['name'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      priceCents: (json['priceCents'] as num?)?.toInt(),
      costCents: (json['costCents'] as num?)?.toInt(),
      unitsPerTray: (json['unitsPerTray'] as num?)?.toInt(),
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$VariantUpdateToJson(VariantUpdate instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'sku': ?instance.sku,
      'barcode': ?instance.barcode,
      'priceCents': ?instance.priceCents,
      'costCents': ?instance.costCents,
      'unitsPerTray': ?instance.unitsPerTray,
      'sortOrder': ?instance.sortOrder,
      'isActive': ?instance.isActive,
    };
