// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'sales_report_row.g.dart';

@JsonSerializable()
class SalesReportRow {
  const SalesReportRow({
    required this.key,
    required this.label,
    required this.saleCount,
    required this.quantity,
    required this.grossCents,
    required this.discountCents,
    required this.netCents,
    required this.cashCents,
    required this.prepaidCents,
    required this.refundCents,
    required this.baseCents,
    required this.taxCents,
  });

  factory SalesReportRow.fromJson(Map<String, Object?> json) =>
      _$SalesReportRowFromJson(json);

  /// A day, an hour (00-23), an id, or a tax rate such as IVA:1600
  final String key;
  final String label;
  final int saleCount;

  /// Units, for products only
  final int? quantity;
  final int grossCents;
  final int discountCents;

  /// What the sales came to, before refunds
  final int netCents;
  final int cashCents;

  /// Order pickups paid from a balance
  final int prepaidCents;
  final int refundCents;

  /// Tax rows only, net of refunds
  final int? baseCents;

  /// Tax rows only, net of refunds
  final int? taxCents;

  Map<String, Object?> toJson() => _$SalesReportRowToJson(this);
}
