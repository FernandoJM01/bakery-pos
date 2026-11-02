// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'z_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZReport _$ZReportFromJson(Map<String, dynamic> json) => ZReport(
  saleCount: (json['saleCount'] as num).toInt(),
  grossCents: (json['grossCents'] as num).toInt(),
  discountCents: (json['discountCents'] as num).toInt(),
  netCents: (json['netCents'] as num).toInt(),
  taxes: (json['taxes'] as List<dynamic>)
      .map((e) => TaxByRate.fromJson(e as Map<String, dynamic>))
      .toList(),
  refundCount: (json['refundCount'] as num).toInt(),
  refundCents: (json['refundCents'] as num).toInt(),
  voidCount: (json['voidCount'] as num).toInt(),
  voidCents: (json['voidCents'] as num).toInt(),
  prepaidCollectedCents: (json['prepaidCollectedCents'] as num).toInt(),
  cashInCents: (json['cashInCents'] as num).toInt(),
  cashOutCents: (json['cashOutCents'] as num).toInt(),
  movements: (json['movements'] as List<dynamic>)
      .map((e) => Movements.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ZReportToJson(ZReport instance) => <String, dynamic>{
  'saleCount': instance.saleCount,
  'grossCents': instance.grossCents,
  'discountCents': instance.discountCents,
  'netCents': instance.netCents,
  'taxes': instance.taxes,
  'refundCount': instance.refundCount,
  'refundCents': instance.refundCents,
  'voidCount': instance.voidCount,
  'voidCents': instance.voidCents,
  'prepaidCollectedCents': instance.prepaidCollectedCents,
  'cashInCents': instance.cashInCents,
  'cashOutCents': instance.cashOutCents,
  'movements': instance.movements,
};
