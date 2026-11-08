// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderUpdate _$OrderUpdateFromJson(Map<String, dynamic> json) => OrderUpdate(
  weekdays: (json['weekdays'] as num).toInt(),
  startDate: json['startDate'] as LocalDate,
  pickupTime: json['pickupTime'] as PickupTime,
  missedRule: MissedRule.fromJson(json['missedRule'] as String),
  lines: (json['lines'] as List<dynamic>)
      .map((e) => OrderLineInput.fromJson(e as Map<String, dynamic>))
      .toList(),
  endDate: json['endDate'] as LocalDate?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$OrderUpdateToJson(OrderUpdate instance) =>
    <String, dynamic>{
      'weekdays': instance.weekdays,
      'startDate': instance.startDate,
      'endDate': ?instance.endDate,
      'pickupTime': instance.pickupTime,
      'missedRule': _$MissedRuleEnumMap[instance.missedRule]!,
      'note': ?instance.note,
      'lines': instance.lines,
    };

const _$MissedRuleEnumMap = {
  MissedRule.charge: 'CHARGE',
  MissedRule.noCharge: 'NO_CHARGE',
  MissedRule.$unknown: r'$unknown',
};
