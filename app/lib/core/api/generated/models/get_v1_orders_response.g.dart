// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_v1_orders_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetV1OrdersResponse _$GetV1OrdersResponseFromJson(Map<String, dynamic> json) =>
    GetV1OrdersResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => CustomerOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetV1OrdersResponseToJson(
  GetV1OrdersResponse instance,
) => <String, dynamic>{'items': instance.items};
