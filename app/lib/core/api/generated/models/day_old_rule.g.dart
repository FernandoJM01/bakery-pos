// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_old_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayOldRule _$DayOldRuleFromJson(Map<String, dynamic> json) => DayOldRule(
  productId: json['productId'] as String,
  categoryId: json['categoryId'] as String,
  categoryName: json['categoryName'] as String,
  productName: json['productName'] as String,
  isActive: json['isActive'] as bool,
  dayOldDiscountAfterDays: (json['dayOldDiscountAfterDays'] as num?)?.toInt(),
  dayOldDiscountBp: (json['dayOldDiscountBp'] as num?)?.toInt(),
  dayOldWasteAfterDays: (json['dayOldWasteAfterDays'] as num?)?.toInt(),
);

Map<String, dynamic> _$DayOldRuleToJson(DayOldRule instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'productName': instance.productName,
      'isActive': instance.isActive,
      'dayOldDiscountAfterDays': ?instance.dayOldDiscountAfterDays,
      'dayOldDiscountBp': ?instance.dayOldDiscountBp,
      'dayOldWasteAfterDays': ?instance.dayOldWasteAfterDays,
    };
