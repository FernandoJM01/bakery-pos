// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductCreate _$ProductCreateFromJson(Map<String, dynamic> json) =>
    ProductCreate(
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      unit: ProductUnit.fromJson(json['unit'] as String),
      ivaRateId: json['ivaRateId'] as String,
      variants: (json['variants'] as List<dynamic>)
          .map((e) => VariantCreate.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
      photoId: json['photoId'] as String?,
      iepsRateId: json['iepsRateId'] as String?,
      dayOldDiscountAfterDays: (json['dayOldDiscountAfterDays'] as num?)
          ?.toInt(),
      dayOldDiscountBp: (json['dayOldDiscountBp'] as num?)?.toInt(),
      dayOldWasteAfterDays: (json['dayOldWasteAfterDays'] as num?)?.toInt(),
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductCreateToJson(ProductCreate instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'name': instance.name,
      'description': ?instance.description,
      'unit': _$ProductUnitEnumMap[instance.unit]!,
      'photoId': ?instance.photoId,
      'ivaRateId': instance.ivaRateId,
      'iepsRateId': ?instance.iepsRateId,
      'dayOldDiscountAfterDays': ?instance.dayOldDiscountAfterDays,
      'dayOldDiscountBp': ?instance.dayOldDiscountBp,
      'dayOldWasteAfterDays': ?instance.dayOldWasteAfterDays,
      'sortOrder': ?instance.sortOrder,
      'variants': instance.variants,
    };

const _$ProductUnitEnumMap = {
  ProductUnit.piece: 'PIECE',
  ProductUnit.kg: 'KG',
  ProductUnit.package: 'PACKAGE',
  ProductUnit.$unknown: r'$unknown',
};
