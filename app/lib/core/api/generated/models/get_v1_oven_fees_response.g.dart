// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_v1_oven_fees_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetV1OvenFeesResponse _$GetV1OvenFeesResponseFromJson(
  Map<String, dynamic> json,
) => GetV1OvenFeesResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => OvenFeeRule.fromJson(e as Map<String, dynamic>))
      .toList(),
  branches: (json['branches'] as List<dynamic>)
      .map((e) => OvenBranchState.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetV1OvenFeesResponseToJson(
  GetV1OvenFeesResponse instance,
) => <String, dynamic>{'items': instance.items, 'branches': instance.branches};
