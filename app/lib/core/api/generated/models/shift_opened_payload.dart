// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'cash_count.dart';

part 'shift_opened_payload.g.dart';

/// Payload of `shift.opened`. The record `id` is the shift ID. M4 brief section 4.1.
@JsonSerializable()
class ShiftOpenedPayload {
  const ShiftOpenedPayload({
    required this.staffId,
    required this.floatCents,
    required this.count,
  });

  factory ShiftOpenedPayload.fromJson(Map<String, Object?> json) =>
      _$ShiftOpenedPayloadFromJson(json);

  final String staffId;
  final AnyCents floatCents;
  final CashCount count;

  Map<String, Object?> toJson() => _$ShiftOpenedPayloadToJson(this);
}
