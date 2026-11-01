// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'folio.dart';
import 'payment.dart';
import 'refund.dart';
import 'sale_discount.dart';
import 'sale_line.dart';
import 'sale_status.dart';
import 'tax_by_rate.dart';
import 'voided_line.dart';

part 'sale.g.dart';

@JsonSerializable()
class Sale {
  const Sale({
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
    required this.folioNumber,
    required this.shiftId,
    required this.receivedAt,
    required this.lines,
    required this.discounts,
    required this.taxes,
    required this.payments,
    required this.voidedLines,
    required this.refunds,
  });

  factory Sale.fromJson(Map<String, Object?> json) => _$SaleFromJson(json);

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
  final int folioNumber;
  final String? shiftId;
  final DateTime receivedAt;
  final List<SaleLine> lines;
  final List<SaleDiscount> discounts;

  /// Sum of the lines' tax parts by kind and rate, before refunds
  final List<TaxByRate> taxes;
  final List<Payment> payments;
  final List<VoidedLine> voidedLines;
  final List<Refund> refunds;

  Map<String, Object?> toJson() => _$SaleToJson(this);
}
