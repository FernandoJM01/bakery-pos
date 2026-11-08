// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockReport _$StockReportFromJson(Map<String, dynamic> json) => StockReport(
  from: json['from'] as LocalDate,
  to: json['to'] as LocalDate,
  items: (json['items'] as List<dynamic>)
      .map((e) => StockReportRow.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StockReportToJson(StockReport instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'items': instance.items,
    };
