// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'oven_status_payload_status.dart';

part 'oven_status_payload.g.dart';

/// Payload of `oven.status`. A step never goes back; the furthest one stands.
@JsonSerializable()
class OvenStatusPayload {
  const OvenStatusPayload({
    required this.ticketId,
    required this.status,
    required this.staffId,
  });

  factory OvenStatusPayload.fromJson(Map<String, Object?> json) =>
      _$OvenStatusPayloadFromJson(json);

  final String ticketId;
  final OvenStatusPayloadStatus status;
  final String staffId;

  Map<String, Object?> toJson() => _$OvenStatusPayloadToJson(this);
}
