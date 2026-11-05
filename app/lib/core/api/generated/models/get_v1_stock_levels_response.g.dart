// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_v1_stock_levels_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetV1StockLevelsResponse _$GetV1StockLevelsResponseFromJson(
  Map<String, dynamic> json,
) => GetV1StockLevelsResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => StockLevel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetV1StockLevelsResponseToJson(
  GetV1StockLevelsResponse instance,
) => <String, dynamic>{'items': instance.items};
