// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'day_old_days.dart';

part 'day_old_rule.g.dart';

@JsonSerializable()
class DayOldRule {
  const DayOldRule({
    required this.productId,
    required this.categoryId,
    required this.categoryName,
    required this.productName,
    required this.isActive,
    required this.dayOldDiscountAfterDays,
    required this.dayOldDiscountBp,
    required this.dayOldWasteAfterDays,
  });

  factory DayOldRule.fromJson(Map<String, Object?> json) =>
      _$DayOldRuleFromJson(json);

  final String productId;
  final String categoryId;
  final String categoryName;
  final String productName;
  final bool isActive;
  final DayOldDays dayOldDiscountAfterDays;
  final int? dayOldDiscountBp;
  final DayOldDays dayOldWasteAfterDays;

  Map<String, Object?> toJson() => _$DayOldRuleToJson(this);
}
