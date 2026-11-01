// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleSummary _$SaleSummaryFromJson(Map<String, dynamic> json) => SaleSummary(
  id: json['id'] as String,
  folio: json['folio'] as Folio,
  branchId: json['branchId'] as String,
  deviceId: json['deviceId'] as String,
  cashierStaffId: json['cashierStaffId'] as String,
  cashierName: json['cashierName'] as String,
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  status: SaleStatus.fromJson(json['status'] as String),
  lineCount: (json['lineCount'] as num).toInt(),
  grossCents: (json['grossCents'] as num).toInt(),
  discountCents: (json['discountCents'] as num).toInt(),
  totalCents: (json['totalCents'] as num).toInt(),
  refundedCents: (json['refundedCents'] as num).toInt(),
);

Map<String, dynamic> _$SaleSummaryToJson(SaleSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'folio': instance.folio,
      'branchId': instance.branchId,
      'deviceId': instance.deviceId,
      'cashierStaffId': instance.cashierStaffId,
      'cashierName': instance.cashierName,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'status': _$SaleStatusEnumMap[instance.status]!,
      'lineCount': instance.lineCount,
      'grossCents': instance.grossCents,
      'discountCents': instance.discountCents,
      'totalCents': instance.totalCents,
      'refundedCents': instance.refundedCents,
    };

const _$SaleStatusEnumMap = {
  SaleStatus.completed: 'COMPLETED',
  SaleStatus.partiallyRefunded: 'PARTIALLY_REFUNDED',
  SaleStatus.refunded: 'REFUNDED',
  SaleStatus.voided: 'VOIDED',
  SaleStatus.$unknown: r'$unknown',
};
