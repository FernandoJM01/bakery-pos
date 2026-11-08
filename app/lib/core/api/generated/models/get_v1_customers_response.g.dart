// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_v1_customers_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetV1CustomersResponse _$GetV1CustomersResponseFromJson(
  Map<String, dynamic> json,
) => GetV1CustomersResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => Customer.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetV1CustomersResponseToJson(
  GetV1CustomersResponse instance,
) => <String, dynamic>{'items': instance.items};
