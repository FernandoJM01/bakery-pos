// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'stock_event_kind.dart';

part 'stock_event.g.dart';

@JsonSerializable()
class StockEvent {
  const StockEvent({
    required this.id,
    required this.kind,
    required this.quantity,
    required this.occurredAt,
    this.lotId,
    this.referenceType,
    this.referenceId,
    this.staffId,
  });

  factory StockEvent.fromJson(Map<String, Object?> json) =>
      _$StockEventFromJson(json);

  final String id;
  final StockEventKind kind;

  /// Signed
  final int quantity;
  final String? lotId;
  final String? referenceType;
  final String? referenceId;
  final String? staffId;
  final DateTime occurredAt;

  Map<String, Object?> toJson() => _$StockEventToJson(this);
}
