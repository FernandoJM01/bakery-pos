// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'stock_level.dart';

part 'get_v1_stock_levels_response.g.dart';

@JsonSerializable()
class GetV1StockLevelsResponse {
  const GetV1StockLevelsResponse({required this.items});

  factory GetV1StockLevelsResponse.fromJson(Map<String, Object?> json) =>
      _$GetV1StockLevelsResponseFromJson(json);

  final List<StockLevel> items;

  Map<String, Object?> toJson() => _$GetV1StockLevelsResponseToJson(this);
}
