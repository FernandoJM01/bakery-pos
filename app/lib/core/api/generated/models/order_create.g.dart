// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderCreate _$OrderCreateFromJson(Map<String, dynamic> json) => OrderCreate(
  weekdays: (json['weekdays'] as num).toInt(),
  startDate: json['startDate'] as LocalDate,
  pickupTime: json['pickupTime'] as PickupTime,
  missedRule: MissedRule.fromJson(json['missedRule'] as String),
  lines: (json['lines'] as List<dynamic>)
      .map((e) => OrderLineInput.fromJson(e as Map<String, dynamic>))
      .toList(),
  customerId: json['customerId'] as String,
  branchId: json['branchId'] as String,
  kind: OrderKind.fromJson(json['kind'] as String),
  endDate: json['endDate'] as LocalDate?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$OrderCreateToJson(OrderCreate instance) =>
    <String, dynamic>{
      'weekdays': instance.weekdays,
      'startDate': instance.startDate,
      'endDate': ?instance.endDate,
      'pickupTime': instance.pickupTime,
      'missedRule': _$MissedRuleEnumMap[instance.missedRule]!,
      'note': ?instance.note,
      'lines': instance.lines,
      'customerId': instance.customerId,
      'branchId': instance.branchId,
      'kind': _$OrderKindEnumMap[instance.kind]!,
    };

const _$MissedRuleEnumMap = {
  MissedRule.charge: 'CHARGE',
  MissedRule.noCharge: 'NO_CHARGE',
  MissedRule.$unknown: r'$unknown',
};

const _$OrderKindEnumMap = {
  OrderKind.standing: 'STANDING',
  OrderKind.oneOff: 'ONE_OFF',
  OrderKind.$unknown: r'$unknown',
};
