// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'oven_fee_rule.dart';
import 'oven_branch_state.dart';

part 'get_v1_oven_fees_response.g.dart';

@JsonSerializable()
class GetV1OvenFeesResponse {
  const GetV1OvenFeesResponse({required this.items, required this.branches});

  factory GetV1OvenFeesResponse.fromJson(Map<String, Object?> json) =>
      _$GetV1OvenFeesResponseFromJson(json);

  final List<OvenFeeRule> items;
  final List<OvenBranchState> branches;

  Map<String, Object?> toJson() => _$GetV1OvenFeesResponseToJson(this);
}
