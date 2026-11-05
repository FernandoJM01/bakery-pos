// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';

part 'stock_produced_payload.g.dart';

/// Payload of `stock.produced`. The record `id` is the lot ID. M5 brief 4.1.
@JsonSerializable()
class StockProducedPayload {
  const StockProducedPayload({
    required this.variantId,
    required this.quantity,
    required this.producedOn,
    required this.staffId,
  });

  factory StockProducedPayload.fromJson(Map<String, Object?> json) =>
      _$StockProducedPayloadFromJson(json);

  final String variantId;
  final int quantity;
  final LocalDate producedOn;
  final String staffId;

  Map<String, Object?> toJson() => _$StockProducedPayloadToJson(this);
}
