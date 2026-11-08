// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'put_v1_oven_branches_branch_id_response.g.dart';

@JsonSerializable()
class PutV1OvenBranchesBranchIdResponse {
  const PutV1OvenBranchesBranchIdResponse({
    required this.branchId,
    required this.enabled,
  });

  factory PutV1OvenBranchesBranchIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PutV1OvenBranchesBranchIdResponseFromJson(json);

  final String branchId;
  final bool enabled;

  Map<String, Object?> toJson() =>
      _$PutV1OvenBranchesBranchIdResponseToJson(this);
}
