// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';
import 'stock_report_row.dart';

part 'stock_report.g.dart';

@JsonSerializable()
class StockReport {
  const StockReport({
    required this.from,
    required this.to,
    required this.items,
  });

  factory StockReport.fromJson(Map<String, Object?> json) =>
      _$StockReportFromJson(json);

  final LocalDate from;
  final LocalDate to;
  final List<StockReportRow> items;

  Map<String, Object?> toJson() => _$StockReportToJson(this);
}
