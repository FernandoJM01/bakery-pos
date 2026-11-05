// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_v1_costs_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetV1CostsResponse _$GetV1CostsResponseFromJson(Map<String, dynamic> json) =>
    GetV1CostsResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => VariantCost.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetV1CostsResponseToJson(GetV1CostsResponse instance) =>
    <String, dynamic>{'items': instance.items};
