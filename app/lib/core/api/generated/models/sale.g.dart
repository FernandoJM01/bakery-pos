// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sale _$SaleFromJson(Map<String, dynamic> json) => Sale(
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
  folioNumber: (json['folioNumber'] as num).toInt(),
  shiftId: json['shiftId'] as String?,
  receivedAt: DateTime.parse(json['receivedAt'] as String),
  lines: (json['lines'] as List<dynamic>)
      .map((e) => SaleLine.fromJson(e as Map<String, dynamic>))
      .toList(),
  discounts: (json['discounts'] as List<dynamic>)
      .map((e) => SaleDiscount.fromJson(e as Map<String, dynamic>))
      .toList(),
  taxes: (json['taxes'] as List<dynamic>)
      .map((e) => TaxByRate.fromJson(e as Map<String, dynamic>))
      .toList(),
  payments: (json['payments'] as List<dynamic>)
      .map((e) => Payment.fromJson(e as Map<String, dynamic>))
      .toList(),
  voidedLines: (json['voidedLines'] as List<dynamic>)
      .map((e) => VoidedLine.fromJson(e as Map<String, dynamic>))
      .toList(),
  refunds: (json['refunds'] as List<dynamic>)
      .map((e) => Refund.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SaleToJson(Sale instance) => <String, dynamic>{
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
  'folioNumber': instance.folioNumber,
  'shiftId': ?instance.shiftId,
  'receivedAt': instance.receivedAt.toIso8601String(),
  'lines': instance.lines,
  'discounts': instance.discounts,
  'taxes': instance.taxes,
  'payments': instance.payments,
  'voidedLines': instance.voidedLines,
  'refunds': instance.refunds,
};

const _$SaleStatusEnumMap = {
  SaleStatus.completed: 'COMPLETED',
  SaleStatus.partiallyRefunded: 'PARTIALLY_REFUNDED',
  SaleStatus.refunded: 'REFUNDED',
  SaleStatus.voided: 'VOIDED',
  SaleStatus.$unknown: r'$unknown',
};
