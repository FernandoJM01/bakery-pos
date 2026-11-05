// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_stock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchStock _$BranchStockFromJson(Map<String, dynamic> json) => BranchStock(
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  lots: (json['lots'] as List<dynamic>)
      .map((e) => BranchLot.fromJson(e as Map<String, dynamic>))
      .toList(),
  shortages: (json['shortages'] as List<dynamic>)
      .map((e) => Shortages.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BranchStockToJson(BranchStock instance) =>
    <String, dynamic>{
      'generatedAt': instance.generatedAt.toIso8601String(),
      'lots': instance.lots,
      'shortages': instance.shortages,
    };
