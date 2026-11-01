// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscountInput _$DiscountInputFromJson(Map<String, dynamic> json) =>
    DiscountInput(
      kind: DiscountKind.fromJson(json['kind'] as String),
      value: (json['value'] as num).toInt(),
      reason: DiscountReason.fromJson(json['reason'] as String),
      note: json['note'] as String?,
      approverStaffId: json['approverStaffId'] as String?,
    );

Map<String, dynamic> _$DiscountInputToJson(DiscountInput instance) =>
    <String, dynamic>{
      'kind': _$DiscountKindEnumMap[instance.kind]!,
      'value': instance.value,
      'reason': _$DiscountReasonEnumMap[instance.reason]!,
      'note': ?instance.note,
      'approverStaffId': ?instance.approverStaffId,
    };

const _$DiscountKindEnumMap = {
  DiscountKind.percent: 'PERCENT',
  DiscountKind.amount: 'AMOUNT',
  DiscountKind.$unknown: r'$unknown',
};

const _$DiscountReasonEnumMap = {
  DiscountReason.frequentCustomer: 'FREQUENT_CUSTOMER',
  DiscountReason.damaged: 'DAMAGED',
  DiscountReason.promotion: 'PROMOTION',
  DiscountReason.other: 'OTHER',
  DiscountReason.$unknown: r'$unknown',
};
