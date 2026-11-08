// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';
import 'sales_group.dart';
import 'sales_report_row.dart';

part 'sales_report.g.dart';

@JsonSerializable()
class SalesReport {
  const SalesReport({
    required this.from,
    required this.to,
    required this.groupBy,
    required this.items,
    required this.totals,
  });

  factory SalesReport.fromJson(Map<String, Object?> json) =>
      _$SalesReportFromJson(json);

  final LocalDate from;
  final LocalDate to;
  final SalesGroup groupBy;
  final List<SalesReportRow> items;
  final SalesReportRow totals;

  Map<String, Object?> toJson() => _$SalesReportToJson(this);
}
