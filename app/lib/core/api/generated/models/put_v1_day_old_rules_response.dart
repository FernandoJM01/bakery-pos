// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'day_old_rule.dart';

part 'put_v1_day_old_rules_response.g.dart';

@JsonSerializable()
class PutV1DayOldRulesResponse {
  const PutV1DayOldRulesResponse({required this.items});

  factory PutV1DayOldRulesResponse.fromJson(Map<String, Object?> json) =>
      _$PutV1DayOldRulesResponseFromJson(json);

  final List<DayOldRule> items;

  Map<String, Object?> toJson() => _$PutV1DayOldRulesResponseToJson(this);
}
