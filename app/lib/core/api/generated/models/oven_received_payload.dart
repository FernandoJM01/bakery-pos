// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';

part 'oven_received_payload.g.dart';

/// Payload of `oven.received`. The record `id` is the oven ticket ID. The fee must match the rule (M8.1).
@JsonSerializable()
class OvenReceivedPayload {
  const OvenReceivedPayload({
    required this.tag,
    required this.customerName,
    required this.description,
    required this.ruleId,
    required this.weightGrams,
    required this.feeCents,
    required this.requestedAt,
    required this.staffId,
    this.phone,
    this.feeSaleId,
  });

  factory OvenReceivedPayload.fromJson(Map<String, Object?> json) =>
      _$OvenReceivedPayloadFromJson(json);

  final String tag;
  final String customerName;
  final String? phone;
  final String description;
  final String ruleId;
  final int weightGrams;
  final AnyCents feeCents;
  final DateTime requestedAt;
  final String staffId;

  /// The fee sale, when paid at drop-off
  final String? feeSaleId;

  Map<String, Object?> toJson() => _$OvenReceivedPayloadToJson(this);
}
