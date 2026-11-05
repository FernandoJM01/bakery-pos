// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'waste_reason.dart';

part 'waste_entry.g.dart';

@JsonSerializable()
class WasteEntry {
  const WasteEntry({
    required this.id,
    required this.branchId,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.reason,
    required this.staffId,
    required this.occurredAt,
    this.costCents,
  });

  factory WasteEntry.fromJson(Map<String, Object?> json) =>
      _$WasteEntryFromJson(json);

  final String id;
  final String branchId;
  final String variantId;
  final String productName;
  final String variantName;
  final int quantity;
  final WasteReason reason;
  final String staffId;
  final DateTime occurredAt;

  /// Unit cost when wasted; null when none was set
  final int? costCents;

  Map<String, Object?> toJson() => _$WasteEntryToJson(this);
}
