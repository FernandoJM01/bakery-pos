// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'cash_count.dart';

part 'shift_closed_payload.g.dart';

/// Payload of `shift.closed`. The record `id` is a new ID; `shiftId` names the shift. The server recomputes.
/// expected, variance and the flag with M4 brief section 4.3 and rejects any difference. A note is required.
/// when flagged.
///
@JsonSerializable()
class ShiftClosedPayload {
  const ShiftClosedPayload({
    required this.shiftId,
    required this.zNumber,
    required this.staffId,
    required this.count,
    required this.countedCents,
    required this.expectedCents,
    required this.varianceCents,
    required this.flagged,
    this.note,
  });

  factory ShiftClosedPayload.fromJson(Map<String, Object?> json) =>
      _$ShiftClosedPayloadFromJson(json);

  final String shiftId;
  final int zNumber;
  final String staffId;
  final CashCount count;
  final AnyCents countedCents;

  /// Can be negative when more cash left than came in
  final int expectedCents;

  /// counted minus expected
  final int varianceCents;
  final bool flagged;
  final String? note;

  Map<String, Object?> toJson() => _$ShiftClosedPayloadToJson(this);
}
