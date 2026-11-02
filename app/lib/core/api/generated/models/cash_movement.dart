// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'cash_movement_kind.dart';
import 'cash_movement_reason.dart';

part 'cash_movement.g.dart';

@JsonSerializable()
class CashMovement {
  const CashMovement({
    required this.id,
    required this.kind,
    required this.amountCents,
    required this.reason,
    required this.staffId,
    required this.occurredAt,
    this.note,
    this.approverStaffId,
  });

  factory CashMovement.fromJson(Map<String, Object?> json) =>
      _$CashMovementFromJson(json);

  final String id;
  final CashMovementKind kind;
  final AnyCents amountCents;
  final CashMovementReason reason;
  final String? note;
  final String staffId;
  final String? approverStaffId;
  final DateTime occurredAt;

  Map<String, Object?> toJson() => _$CashMovementToJson(this);
}
