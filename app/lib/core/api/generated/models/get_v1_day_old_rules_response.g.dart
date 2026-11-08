// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_v1_day_old_rules_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetV1DayOldRulesResponse _$GetV1DayOldRulesResponseFromJson(
  Map<String, dynamic> json,
) => GetV1DayOldRulesResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => DayOldRule.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetV1DayOldRulesResponseToJson(
  GetV1DayOldRulesResponse instance,
) => <String, dynamic>{'items': instance.items};
