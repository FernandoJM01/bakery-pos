// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_old_rule_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayOldRuleSet _$DayOldRuleSetFromJson(Map<String, dynamic> json) =>
    DayOldRuleSet(
      productIds: (json['productIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dayOldDiscountAfterDays: (json['dayOldDiscountAfterDays'] as num?)
          ?.toInt(),
      dayOldDiscountBp: (json['dayOldDiscountBp'] as num?)?.toInt(),
      dayOldWasteAfterDays: (json['dayOldWasteAfterDays'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DayOldRuleSetToJson(DayOldRuleSet instance) =>
    <String, dynamic>{
      'productIds': instance.productIds,
      'dayOldDiscountAfterDays': ?instance.dayOldDiscountAfterDays,
      'dayOldDiscountBp': ?instance.dayOldDiscountBp,
      'dayOldWasteAfterDays': ?instance.dayOldWasteAfterDays,
    };
