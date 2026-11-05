// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_v1_day_old_rules_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutV1DayOldRulesResponse _$PutV1DayOldRulesResponseFromJson(
  Map<String, dynamic> json,
) => PutV1DayOldRulesResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => DayOldRule.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PutV1DayOldRulesResponseToJson(
  PutV1DayOldRulesResponse instance,
) => <String, dynamic>{'items': instance.items};
