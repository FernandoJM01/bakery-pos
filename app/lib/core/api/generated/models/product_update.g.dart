// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductUpdate _$ProductUpdateFromJson(Map<String, dynamic> json) =>
    ProductUpdate(
      categoryId: json['categoryId'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      unit: json['unit'] == null
          ? null
          : ProductUnit.fromJson(json['unit'] as String),
      photoId: json['photoId'] as String?,
      ivaRateId: json['ivaRateId'] as String?,
      iepsRateId: json['iepsRateId'] as String?,
      dayOldDiscountAfterDays: (json['dayOldDiscountAfterDays'] as num?)
          ?.toInt(),
      dayOldDiscountBp: (json['dayOldDiscountBp'] as num?)?.toInt(),
      dayOldWasteAfterDays: (json['dayOldWasteAfterDays'] as num?)?.toInt(),
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$ProductUpdateToJson(ProductUpdate instance) =>
    <String, dynamic>{
      'categoryId': ?instance.categoryId,
      'name': ?instance.name,
      'description': ?instance.description,
      'unit': ?_$ProductUnitEnumMap[instance.unit],
      'photoId': ?instance.photoId,
      'ivaRateId': ?instance.ivaRateId,
      'iepsRateId': ?instance.iepsRateId,
      'dayOldDiscountAfterDays': ?instance.dayOldDiscountAfterDays,
      'dayOldDiscountBp': ?instance.dayOldDiscountBp,
      'dayOldWasteAfterDays': ?instance.dayOldWasteAfterDays,
      'sortOrder': ?instance.sortOrder,
      'isActive': ?instance.isActive,
    };

const _$ProductUnitEnumMap = {
  ProductUnit.piece: 'PIECE',
  ProductUnit.kg: 'KG',
  ProductUnit.package: 'PACKAGE',
  ProductUnit.$unknown: r'$unknown',
};
