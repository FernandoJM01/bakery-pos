// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'folio.dart';
import 'sale_status.dart';

part 'sale_summary.g.dart';

@JsonSerializable()
class SaleSummary {
  const SaleSummary({
    required this.id,
    required this.folio,
    required this.branchId,
    required this.deviceId,
    required this.cashierStaffId,
    required this.cashierName,
    required this.occurredAt,
    required this.status,
    required this.lineCount,
    required this.grossCents,
    required this.discountCents,
    required this.totalCents,
    required this.refundedCents,
  });

  factory SaleSummary.fromJson(Map<String, Object?> json) =>
      _$SaleSummaryFromJson(json);

  final String id;
  final Folio folio;
  final String branchId;
  final String deviceId;
  final String cashierStaffId;
  final String cashierName;
  final DateTime occurredAt;
  final SaleStatus status;
  final int lineCount;
  final AnyCents grossCents;
  final AnyCents discountCents;
  final AnyCents totalCents;
  final AnyCents refundedCents;

  Map<String, Object?> toJson() => _$SaleSummaryToJson(this);
}
