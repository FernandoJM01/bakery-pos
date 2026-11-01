// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Refund _$RefundFromJson(Map<String, dynamic> json) => Refund(
  id: json['id'] as String,
  kind: RefundKind.fromJson(json['kind'] as String),
  reason: RefundReason.fromJson(json['reason'] as String),
  note: json['note'] as String?,
  deviceId: json['deviceId'] as String,
  staffId: json['staffId'] as String,
  approverStaffId: json['approverStaffId'] as String?,
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  totalCents: (json['totalCents'] as num).toInt(),
  lines: (json['lines'] as List<dynamic>)
      .map((e) => RefundLine.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RefundToJson(Refund instance) => <String, dynamic>{
  'id': instance.id,
  'kind': _$RefundKindEnumMap[instance.kind]!,
  'reason': _$RefundReasonEnumMap[instance.reason]!,
  'note': ?instance.note,
  'deviceId': instance.deviceId,
  'staffId': instance.staffId,
  'approverStaffId': ?instance.approverStaffId,
  'occurredAt': instance.occurredAt.toIso8601String(),
  'totalCents': instance.totalCents,
  'lines': instance.lines,
};

const _$RefundKindEnumMap = {
  RefundKind.refund: 'REFUND',
  RefundKind.valueVoid: 'VOID',
  RefundKind.$unknown: r'$unknown',
};

const _$RefundReasonEnumMap = {
  RefundReason.customerReturn: 'CUSTOMER_RETURN',
  RefundReason.wrongItem: 'WRONG_ITEM',
  RefundReason.quality: 'QUALITY',
  RefundReason.cashierError: 'CASHIER_ERROR',
  RefundReason.other: 'OTHER',
  RefundReason.$unknown: r'$unknown',
};
