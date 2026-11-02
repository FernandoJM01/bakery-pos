// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockCheck _$StockCheckFromJson(Map<String, dynamic> json) => StockCheck(
  checkedAt: json['checkedAt'] == null
      ? null
      : DateTime.parse(json['checkedAt'] as String),
  rowsChecked: (json['rowsChecked'] as num).toInt(),
  mismatches: (json['mismatches'] as num).toInt(),
);

Map<String, dynamic> _$StockCheckToJson(StockCheck instance) =>
    <String, dynamic>{
      'checkedAt': ?instance.checkedAt?.toIso8601String(),
      'rowsChecked': instance.rowsChecked,
      'mismatches': instance.mismatches,
    };
