// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'oven_picked_up_payload.g.dart';

/// Payload of `oven.picked_up`. The fee is paid exactly once, at drop-off or here.
@JsonSerializable()
class OvenPickedUpPayload {
  const OvenPickedUpPayload({
    required this.ticketId,
    required this.staffId,
    this.feeSaleId,
  });

  factory OvenPickedUpPayload.fromJson(Map<String, Object?> json) =>
      _$OvenPickedUpPayloadFromJson(json);

  final String ticketId;
  final String staffId;

  /// The fee sale, when paid at pickup
  final String? feeSaleId;

  Map<String, Object?> toJson() => _$OvenPickedUpPayloadToJson(this);
}
