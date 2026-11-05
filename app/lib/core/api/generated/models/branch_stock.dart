// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'branch_lot.dart';
import 'shortages.dart';

part 'branch_stock.g.dart';

@JsonSerializable()
class BranchStock {
  const BranchStock({
    required this.generatedAt,
    required this.lots,
    required this.shortages,
  });

  factory BranchStock.fromJson(Map<String, Object?> json) =>
      _$BranchStockFromJson(json);

  final DateTime generatedAt;
  final List<BranchLot> lots;

  /// Units sold with no lot to take from, per variant
  final List<Shortages> shortages;

  Map<String, Object?> toJson() => _$BranchStockToJson(this);
}
