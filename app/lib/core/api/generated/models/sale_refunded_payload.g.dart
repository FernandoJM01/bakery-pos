// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_refunded_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleRefundedPayload _$SaleRefundedPayloadFromJson(Map<String, dynamic> json) =>
    SaleRefundedPayload(
      saleId: json['saleId'] as String,
      kind: RefundKind.fromJson(json['kind'] as String),
      reason: RefundReason.fromJson(json['reason'] as String),
      staffId: json['staffId'] as String,
      lines: (json['lines'] as List<dynamic>)
          .map((e) => RefundLineInput.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCents: (json['totalCents'] as num).toInt(),
      note: json['note'] as String?,
      approverStaffId: json['approverStaffId'] as String?,
    );

Map<String, dynamic> _$SaleRefundedPayloadToJson(
  SaleRefundedPayload instance,
) => <String, dynamic>{
  'saleId': instance.saleId,
  'kind': _$RefundKindEnumMap[instance.kind]!,
  'reason': _$RefundReasonEnumMap[instance.reason]!,
  'note': ?instance.note,
  'staffId': instance.staffId,
  'approverStaffId': ?instance.approverStaffId,
  'lines': instance.lines,
  'totalCents': instance.totalCents,
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
