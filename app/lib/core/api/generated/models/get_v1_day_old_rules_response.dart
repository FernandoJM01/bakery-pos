// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'day_old_rule.dart';

part 'get_v1_day_old_rules_response.g.dart';

@JsonSerializable()
class GetV1DayOldRulesResponse {
  const GetV1DayOldRulesResponse({required this.items});

  factory GetV1DayOldRulesResponse.fromJson(Map<String, Object?> json) =>
      _$GetV1DayOldRulesResponseFromJson(json);

  final List<DayOldRule> items;

  Map<String, Object?> toJson() => _$GetV1DayOldRulesResponseToJson(this);
}
