// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'customer.dart';

part 'get_v1_customers_response.g.dart';

@JsonSerializable()
class GetV1CustomersResponse {
  const GetV1CustomersResponse({required this.items});

  factory GetV1CustomersResponse.fromJson(Map<String, Object?> json) =>
      _$GetV1CustomersResponseFromJson(json);

  final List<Customer> items;

  Map<String, Object?> toJson() => _$GetV1CustomersResponseToJson(this);
}
