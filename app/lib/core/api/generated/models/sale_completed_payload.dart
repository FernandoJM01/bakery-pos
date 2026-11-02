// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'discount_input.dart';
import 'folio.dart';
import 'payment_input.dart';
import 'sale_line_input.dart';
import 'voided_line_input.dart';

part 'sale_completed_payload.g.dart';

/// Payload of `sale.completed`. The record `id` is the sale ID. Every amount must match the totals in M3 brief.
/// section 4.2, recomputed by the server. Exactly one CASH payment in M3.
///
@JsonSerializable()
class SaleCompletedPayload {
  const SaleCompletedPayload({
    required this.folio,
    required this.folioNumber,
    required this.cashierStaffId,
    required this.shiftId,
    required this.lines,
    required this.voidedLines,
    required this.grossCents,
    required this.discountCents,
    required this.totalCents,
    required this.payments,
    this.orderDiscount,
  });

  factory SaleCompletedPayload.fromJson(Map<String, Object?> json) =>
      _$SaleCompletedPayloadFromJson(json);

  final Folio folio;
  final int folioNumber;
  final String cashierStaffId;

  /// The open shift of this device (M4.1)
  final String shiftId;
  final List<SaleLineInput> lines;
  final DiscountInput? orderDiscount;
  final List<VoidedLineInput> voidedLines;
  final AnyCents grossCents;
  final AnyCents discountCents;
  final AnyCents totalCents;
  final List<PaymentInput> payments;

  Map<String, Object?> toJson() => _$SaleCompletedPayloadToJson(this);
}
