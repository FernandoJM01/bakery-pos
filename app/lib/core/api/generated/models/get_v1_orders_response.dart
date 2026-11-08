// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'customer_order.dart';

part 'get_v1_orders_response.g.dart';

@JsonSerializable()
class GetV1OrdersResponse {
  const GetV1OrdersResponse({required this.items});

  factory GetV1OrdersResponse.fromJson(Map<String, Object?> json) =>
      _$GetV1OrdersResponseFromJson(json);

  final List<CustomerOrder> items;

  Map<String, Object?> toJson() => _$GetV1OrdersResponseToJson(this);
}
