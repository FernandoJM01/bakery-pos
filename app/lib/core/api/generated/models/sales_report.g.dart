// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesReport _$SalesReportFromJson(Map<String, dynamic> json) => SalesReport(
  from: json['from'] as LocalDate,
  to: json['to'] as LocalDate,
  groupBy: SalesGroup.fromJson(json['groupBy'] as String),
  items: (json['items'] as List<dynamic>)
      .map((e) => SalesReportRow.fromJson(e as Map<String, dynamic>))
      .toList(),
  totals: SalesReportRow.fromJson(json['totals'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SalesReportToJson(SalesReport instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'groupBy': _$SalesGroupEnumMap[instance.groupBy]!,
      'items': instance.items,
      'totals': instance.totals,
    };

const _$SalesGroupEnumMap = {
  SalesGroup.day: 'day',
  SalesGroup.hour: 'hour',
  SalesGroup.branch: 'branch',
  SalesGroup.device: 'device',
  SalesGroup.cashier: 'cashier',
  SalesGroup.product: 'product',
  SalesGroup.taxRate: 'taxRate',
  SalesGroup.$unknown: r'$unknown',
};
