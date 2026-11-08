// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrdersReport _$OrdersReportFromJson(Map<String, dynamic> json) => OrdersReport(
  from: json['from'] as LocalDate,
  to: json['to'] as LocalDate,
  tickets: (json['tickets'] as List<dynamic>)
      .map((e) => Tickets.fromJson(e as Map<String, dynamic>))
      .toList(),
  balances: (json['balances'] as List<dynamic>)
      .map((e) => Balances.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OrdersReportToJson(OrdersReport instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'tickets': instance.tickets,
      'balances': instance.balances,
    };
