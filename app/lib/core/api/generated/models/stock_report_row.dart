// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'stock_report_row.g.dart';

@JsonSerializable()
class StockReportRow {
  const StockReportRow({
    required this.branchId,
    required this.branchName,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.produced,
    required this.sold,
    required this.dayOldSold,
    required this.returned,
    required this.wasted,
    required this.transferredIn,
    required this.transferredOut,
    required this.adjusted,
    required this.onHand,
    required this.wasteCostCents,
  });

  factory StockReportRow.fromJson(Map<String, Object?> json) =>
      _$StockReportRowFromJson(json);

  final String branchId;
  final String branchName;
  final String variantId;
  final String productName;
  final String variantName;
  final int produced;
  final int sold;
  final int dayOldSold;
  final int returned;
  final int wasted;
  final int transferredIn;
  final int transferredOut;
  final int adjusted;

  /// At the end of the last day
  final int onHand;
  final int? wasteCostCents;

  Map<String, Object?> toJson() => _$StockReportRowToJson(this);
}
