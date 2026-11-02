// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'cash_count.dart';
import 'cash_movement.dart';
import 'shift_note.dart';
import 'shift_status.dart';
import 'z_report.dart';

part 'shift_detail.g.dart';

@JsonSerializable()
class ShiftDetail {
  const ShiftDetail({
    required this.id,
    required this.branchId,
    required this.deviceId,
    required this.status,
    required this.openedAt,
    required this.openedByStaffId,
    required this.openedByName,
    required this.floatCents,
    required this.flagged,
    required this.openCount,
    required this.movements,
    required this.notes,
    this.zNumber,
    this.zLabel,
    this.closedAt,
    this.closedByStaffId,
    this.closedByName,
    this.expectedCents,
    this.countedCents,
    this.varianceCents,
    this.closeCount,
    this.zReport,
  });

  factory ShiftDetail.fromJson(Map<String, Object?> json) =>
      _$ShiftDetailFromJson(json);

  final String id;
  final String branchId;
  final String deviceId;
  final ShiftStatus status;
  final int? zNumber;
  final String? zLabel;
  final DateTime openedAt;
  final String openedByStaffId;
  final String openedByName;
  final DateTime? closedAt;
  final String? closedByStaffId;
  final String? closedByName;
  final AnyCents floatCents;
  final int? expectedCents;
  final int? countedCents;
  final int? varianceCents;
  final bool flagged;
  final CashCount openCount;
  final CashCount? closeCount;
  final List<CashMovement> movements;
  final List<ShiftNote> notes;
  final ZReport? zReport;

  Map<String, Object?> toJson() => _$ShiftDetailToJson(this);
}
