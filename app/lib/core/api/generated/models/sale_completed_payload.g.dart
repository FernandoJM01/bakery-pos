// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_completed_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleCompletedPayload _$SaleCompletedPayloadFromJson(
  Map<String, dynamic> json,
) => SaleCompletedPayload(
  folio: json['folio'] as Folio,
  folioNumber: (json['folioNumber'] as num).toInt(),
  cashierStaffId: json['cashierStaffId'] as String,
  shiftId: json['shiftId'] as String,
  lines: (json['lines'] as List<dynamic>)
      .map((e) => SaleLineInput.fromJson(e as Map<String, dynamic>))
      .toList(),
  voidedLines: (json['voidedLines'] as List<dynamic>)
      .map((e) => VoidedLineInput.fromJson(e as Map<String, dynamic>))
      .toList(),
  grossCents: (json['grossCents'] as num).toInt(),
  discountCents: (json['discountCents'] as num).toInt(),
  totalCents: (json['totalCents'] as num).toInt(),
  payments: (json['payments'] as List<dynamic>)
      .map((e) => PaymentInput.fromJson(e as Map<String, dynamic>))
      .toList(),
  orderDiscount: json['orderDiscount'] == null
      ? null
      : DiscountInput.fromJson(json['orderDiscount'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SaleCompletedPayloadToJson(
  SaleCompletedPayload instance,
) => <String, dynamic>{
  'folio': instance.folio,
  'folioNumber': instance.folioNumber,
  'cashierStaffId': instance.cashierStaffId,
  'shiftId': instance.shiftId,
  'lines': instance.lines,
  'orderDiscount': ?instance.orderDiscount,
  'voidedLines': instance.voidedLines,
  'grossCents': instance.grossCents,
  'discountCents': instance.discountCents,
  'totalCents': instance.totalCents,
  'payments': instance.payments,
};
