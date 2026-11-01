// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'refund_kind.dart';
import 'refund_line_input.dart';
import 'refund_reason.dart';

part 'sale_refunded_payload.g.dart';

/// Payload of `sale.refunded`. The record `id` is the refund ID. Amounts follow M3 brief section 4.3.
/// A VOID covers every remaining unit of a sale made on the same device on the same local day.
///
@JsonSerializable()
class SaleRefundedPayload {
  const SaleRefundedPayload({
    required this.saleId,
    required this.kind,
    required this.reason,
    required this.staffId,
    required this.lines,
    required this.totalCents,
    this.note,
    this.approverStaffId,
  });

  factory SaleRefundedPayload.fromJson(Map<String, Object?> json) =>
      _$SaleRefundedPayloadFromJson(json);

  final String saleId;
  final RefundKind kind;
  final RefundReason reason;
  final String? note;
  final String staffId;

  /// Required when `staffId` lacks the permission (`sale.refund` or `sale.void_after_payment`); the approver must hold it
  final String? approverStaffId;
  final List<RefundLineInput> lines;
  final AnyCents totalCents;

  Map<String, Object?> toJson() => _$SaleRefundedPayloadToJson(this);
}
