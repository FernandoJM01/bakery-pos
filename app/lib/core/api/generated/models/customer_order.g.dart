// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerOrder _$CustomerOrderFromJson(Map<String, dynamic> json) =>
    CustomerOrder(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      branchId: json['branchId'] as String,
      kind: OrderKind.fromJson(json['kind'] as String),
      weekdays: (json['weekdays'] as num).toInt(),
      startDate: json['startDate'] as LocalDate,
      endDate: json['endDate'] as LocalDate?,
      pickupTime: json['pickupTime'] as PickupTime,
      missedRule: MissedRule.fromJson(json['missedRule'] as String),
      status: OrderStatus.fromJson(json['status'] as String),
      pausedFrom: json['pausedFrom'] as LocalDate?,
      pausedUntil: json['pausedUntil'] as LocalDate?,
      note: json['note'] as String?,
      lines: (json['lines'] as List<dynamic>)
          .map((e) => Lines4.fromJson(e as Map<String, dynamic>))
          .toList(),
      skips: (json['skips'] as List<dynamic>)
          .map((e) => e as LocalDate)
          .toList(),
    );

Map<String, dynamic> _$CustomerOrderToJson(CustomerOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'branchId': instance.branchId,
      'kind': _$OrderKindEnumMap[instance.kind]!,
      'weekdays': instance.weekdays,
      'startDate': instance.startDate,
      'endDate': ?instance.endDate,
      'pickupTime': instance.pickupTime,
      'missedRule': _$MissedRuleEnumMap[instance.missedRule]!,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'pausedFrom': ?instance.pausedFrom,
      'pausedUntil': ?instance.pausedUntil,
      'note': ?instance.note,
      'lines': instance.lines,
      'skips': instance.skips,
    };

const _$OrderKindEnumMap = {
  OrderKind.standing: 'STANDING',
  OrderKind.oneOff: 'ONE_OFF',
  OrderKind.$unknown: r'$unknown',
};

const _$MissedRuleEnumMap = {
  MissedRule.charge: 'CHARGE',
  MissedRule.noCharge: 'NO_CHARGE',
  MissedRule.$unknown: r'$unknown',
};

const _$OrderStatusEnumMap = {
  OrderStatus.active: 'ACTIVE',
  OrderStatus.paused: 'PAUSED',
  OrderStatus.ended: 'ENDED',
  OrderStatus.$unknown: r'$unknown',
};
