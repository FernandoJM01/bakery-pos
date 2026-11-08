// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_report_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesReportRow _$SalesReportRowFromJson(Map<String, dynamic> json) =>
    SalesReportRow(
      key: json['key'] as String,
      label: json['label'] as String,
      saleCount: (json['saleCount'] as num).toInt(),
      quantity: (json['quantity'] as num?)?.toInt(),
      grossCents: (json['grossCents'] as num).toInt(),
      discountCents: (json['discountCents'] as num).toInt(),
      netCents: (json['netCents'] as num).toInt(),
      cashCents: (json['cashCents'] as num).toInt(),
      prepaidCents: (json['prepaidCents'] as num).toInt(),
      refundCents: (json['refundCents'] as num).toInt(),
      baseCents: (json['baseCents'] as num?)?.toInt(),
      taxCents: (json['taxCents'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SalesReportRowToJson(SalesReportRow instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'saleCount': instance.saleCount,
      'quantity': ?instance.quantity,
      'grossCents': instance.grossCents,
      'discountCents': instance.discountCents,
      'netCents': instance.netCents,
      'cashCents': instance.cashCents,
      'prepaidCents': instance.prepaidCents,
      'refundCents': instance.refundCents,
      'baseCents': ?instance.baseCents,
      'taxCents': ?instance.taxCents,
    };
