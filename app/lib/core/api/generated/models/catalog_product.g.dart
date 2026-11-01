// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogProduct _$CatalogProductFromJson(Map<String, dynamic> json) =>
    CatalogProduct(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      unit: ProductUnit.fromJson(json['unit'] as String),
      photoId: json['photoId'] as String?,
      ivaRateId: json['ivaRateId'] as String,
      iepsRateId: json['iepsRateId'] as String?,
      dayOldDiscountAfterDays: (json['dayOldDiscountAfterDays'] as num?)
          ?.toInt(),
      dayOldDiscountBp: (json['dayOldDiscountBp'] as num?)?.toInt(),
      dayOldWasteAfterDays: (json['dayOldWasteAfterDays'] as num?)?.toInt(),
      sortOrder: (json['sortOrder'] as num).toInt(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$CatalogProductToJson(CatalogProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'name': instance.name,
      'unit': _$ProductUnitEnumMap[instance.unit]!,
      'photoId': ?instance.photoId,
      'ivaRateId': instance.ivaRateId,
      'iepsRateId': ?instance.iepsRateId,
      'dayOldDiscountAfterDays': ?instance.dayOldDiscountAfterDays,
      'dayOldDiscountBp': ?instance.dayOldDiscountBp,
      'dayOldWasteAfterDays': ?instance.dayOldWasteAfterDays,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };

const _$ProductUnitEnumMap = {
  ProductUnit.piece: 'PIECE',
  ProductUnit.kg: 'KG',
  ProductUnit.package: 'PACKAGE',
  ProductUnit.$unknown: r'$unknown',
};
