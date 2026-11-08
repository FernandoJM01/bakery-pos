// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';

part 'order_prepaid_payload.g.dart';

/// Payload of `order.prepaid`. The record `id` is the prepaid entry ID. Cash in the open shift (M6 brief 4.3).
@JsonSerializable()
class OrderPrepaidPayload {
  const OrderPrepaidPayload({
    required this.customerId,
    required this.shiftId,
    required this.amountCents,
    required this.staffId,
  });

  factory OrderPrepaidPayload.fromJson(Map<String, Object?> json) =>
      _$OrderPrepaidPayloadFromJson(json);

  final String customerId;
  final String shiftId;
  final AnyCents amountCents;
  final String staffId;

  Map<String, Object?> toJson() => _$OrderPrepaidPayloadToJson(this);
}
