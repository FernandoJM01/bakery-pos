// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'variant_cost.dart';

part 'get_v1_costs_response.g.dart';

@JsonSerializable()
class GetV1CostsResponse {
  const GetV1CostsResponse({required this.items});

  factory GetV1CostsResponse.fromJson(Map<String, Object?> json) =>
      _$GetV1CostsResponseFromJson(json);

  final List<VariantCost> items;

  Map<String, Object?> toJson() => _$GetV1CostsResponseToJson(this);
}
