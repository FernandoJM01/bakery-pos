// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: json['id'] as String,
  categoryId: json['categoryId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  unit: ProductUnit.fromJson(json['unit'] as String),
  photoId: json['photoId'] as String?,
  ivaRateId: json['ivaRateId'] as String,
  iepsRateId: json['iepsRateId'] as String?,
  dayOldDiscountAfterDays: (json['dayOldDiscountAfterDays'] as num?)?.toInt(),
  dayOldDiscountBp: (json['dayOldDiscountBp'] as num?)?.toInt(),
  dayOldWasteAfterDays: (json['dayOldWasteAfterDays'] as num?)?.toInt(),
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  variants: (json['variants'] as List<dynamic>)
      .map((e) => Variant.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
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
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'variants': instance.variants,
};

const _$ProductUnitEnumMap = {
  ProductUnit.piece: 'PIECE',
  ProductUnit.kg: 'KG',
  ProductUnit.package: 'PACKAGE',
  ProductUnit.$unknown: r'$unknown',
};
