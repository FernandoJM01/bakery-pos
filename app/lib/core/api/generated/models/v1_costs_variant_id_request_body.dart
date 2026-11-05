// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cents.dart';

part 'v1_costs_variant_id_request_body.g.dart';

@JsonSerializable()
class V1CostsVariantIdRequestBody {
  const V1CostsVariantIdRequestBody({required this.costCents});

  factory V1CostsVariantIdRequestBody.fromJson(Map<String, Object?> json) =>
      _$V1CostsVariantIdRequestBodyFromJson(json);

  final Cents? costCents;

  Map<String, Object?> toJson() => _$V1CostsVariantIdRequestBodyToJson(this);
}
