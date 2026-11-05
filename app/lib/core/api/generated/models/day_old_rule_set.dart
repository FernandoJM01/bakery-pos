// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'day_old_days.dart';

part 'day_old_rule_set.g.dart';

@JsonSerializable()
class DayOldRuleSet {
  const DayOldRuleSet({
    required this.productIds,
    required this.dayOldDiscountAfterDays,
    required this.dayOldDiscountBp,
    required this.dayOldWasteAfterDays,
  });

  factory DayOldRuleSet.fromJson(Map<String, Object?> json) =>
      _$DayOldRuleSetFromJson(json);

  final List<String> productIds;
  final DayOldDays dayOldDiscountAfterDays;
  final int? dayOldDiscountBp;
  final DayOldDays dayOldWasteAfterDays;

  Map<String, Object?> toJson() => _$DayOldRuleSetToJson(this);
}
