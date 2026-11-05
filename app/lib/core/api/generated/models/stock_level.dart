// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'stock_level.g.dart';

@JsonSerializable()
class StockLevel {
  const StockLevel({
    required this.branchId,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.onHand,
    required this.freshUnits,
    required this.dayOldUnits,
    required this.wasteDueUnits,
  });

  factory StockLevel.fromJson(Map<String, Object?> json) =>
      _$StockLevelFromJson(json);

  final String branchId;
  final String variantId;
  final String productName;
  final String variantName;

  /// Sum of the ledger; negative when more was sold than entered
  final int onHand;
  final int freshUnits;
  final int dayOldUnits;
  final int wasteDueUnits;

  Map<String, Object?> toJson() => _$StockLevelToJson(this);
}
