// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'stock_check.g.dart';

@JsonSerializable()
class StockCheck {
  const StockCheck({
    required this.checkedAt,
    required this.rowsChecked,
    required this.mismatches,
  });

  factory StockCheck.fromJson(Map<String, Object?> json) =>
      _$StockCheckFromJson(json);

  final DateTime? checkedAt;
  final int rowsChecked;
  final int mismatches;

  Map<String, Object?> toJson() => _$StockCheckToJson(this);
}
