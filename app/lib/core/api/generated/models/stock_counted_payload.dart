// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lines.dart';

part 'stock_counted_payload.g.dart';

/// Payload of `stock.counted`. The server works out each difference from its own on-hand. M5 brief 4.6.
@JsonSerializable()
class StockCountedPayload {
  const StockCountedPayload({required this.staffId, required this.lines});

  factory StockCountedPayload.fromJson(Map<String, Object?> json) =>
      _$StockCountedPayloadFromJson(json);

  final String staffId;
  final List<Lines> lines;

  Map<String, Object?> toJson() => _$StockCountedPayloadToJson(this);
}
