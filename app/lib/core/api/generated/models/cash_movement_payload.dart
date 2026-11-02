// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'cash_movement_kind.dart';
import 'cash_movement_reason.dart';

part 'cash_movement_payload.g.dart';

/// Payload of `cash.movement`. The record `id` is the movement ID. A note is required with `OTHER`.
@JsonSerializable()
class CashMovementPayload {
  const CashMovementPayload({
    required this.shiftId,
    required this.kind,
    required this.amountCents,
    required this.reason,
    required this.staffId,
    this.note,
    this.approverStaffId,
  });

  factory CashMovementPayload.fromJson(Map<String, Object?> json) =>
      _$CashMovementPayloadFromJson(json);

  final String shiftId;
  final CashMovementKind kind;
  final AnyCents amountCents;
  final CashMovementReason reason;
  final String? note;
  final String staffId;

  /// Required when `staffId` lacks `cash.movement`; the approver must hold it
  final String? approverStaffId;

  Map<String, Object?> toJson() => _$CashMovementPayloadToJson(this);
}
