// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'movements.dart';
import 'tax_by_rate.dart';

part 'z_report.g.dart';

/// M4 brief section 4.5. Tax by rate is net of refunds, from stored amounts.
@JsonSerializable()
class ZReport {
  const ZReport({
    required this.saleCount,
    required this.grossCents,
    required this.discountCents,
    required this.netCents,
    required this.taxes,
    required this.refundCount,
    required this.refundCents,
    required this.voidCount,
    required this.voidCents,
    required this.prepaidCollectedCents,
    required this.cashInCents,
    required this.cashOutCents,
    required this.movements,
  });

  factory ZReport.fromJson(Map<String, Object?> json) =>
      _$ZReportFromJson(json);

  final int saleCount;
  final int grossCents;
  final int discountCents;
  final int netCents;
  final List<TaxByRate> taxes;
  final int refundCount;
  final int refundCents;
  final int voidCount;
  final int voidCents;

  /// 0 until orders in Sprint 6
  final int prepaidCollectedCents;
  final int cashInCents;
  final int cashOutCents;

  /// Total per kind and reason
  final List<Movements> movements;

  Map<String, Object?> toJson() => _$ZReportToJson(this);
}
