// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'waste_reason.dart';

part 'stock_wasted_payload.g.dart';

/// Payload of `stock.wasted`. Oldest lots first unless `lotId` names one.
@JsonSerializable()
class StockWastedPayload {
  const StockWastedPayload({
    required this.variantId,
    required this.quantity,
    required this.reason,
    required this.staffId,
    this.lotId,
  });

  factory StockWastedPayload.fromJson(Map<String, Object?> json) =>
      _$StockWastedPayloadFromJson(json);

  final String variantId;
  final int quantity;
  final WasteReason reason;
  final String? lotId;
  final String staffId;

  Map<String, Object?> toJson() => _$StockWastedPayloadToJson(this);
}
