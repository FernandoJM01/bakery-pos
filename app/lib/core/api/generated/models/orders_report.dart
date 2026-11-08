// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'balances.dart';
import 'local_date.dart';
import 'tickets.dart';

part 'orders_report.g.dart';

@JsonSerializable()
class OrdersReport {
  const OrdersReport({
    required this.from,
    required this.to,
    required this.tickets,
    required this.balances,
  });

  factory OrdersReport.fromJson(Map<String, Object?> json) =>
      _$OrdersReportFromJson(json);

  final LocalDate from;
  final LocalDate to;
  final List<Tickets> tickets;

  /// Lowest first, so who owes comes first
  final List<Balances> balances;

  Map<String, Object?> toJson() => _$OrdersReportToJson(this);
}
