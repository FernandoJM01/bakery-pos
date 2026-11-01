// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_discount.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleDiscount _$SaleDiscountFromJson(Map<String, dynamic> json) => SaleDiscount(
  lineNo: (json['lineNo'] as num?)?.toInt(),
  kind: DiscountKind.fromJson(json['kind'] as String),
  value: (json['value'] as num).toInt(),
  cents: (json['cents'] as num).toInt(),
  reason: DiscountReason.fromJson(json['reason'] as String),
  note: json['note'] as String?,
  approverStaffId: json['approverStaffId'] as String?,
);

Map<String, dynamic> _$SaleDiscountToJson(SaleDiscount instance) =>
    <String, dynamic>{
      'lineNo': ?instance.lineNo,
      'kind': _$DiscountKindEnumMap[instance.kind]!,
      'value': instance.value,
      'cents': instance.cents,
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
