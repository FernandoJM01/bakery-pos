// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'v1_oven_branches_branch_id_request_body.g.dart';

@JsonSerializable()
class V1OvenBranchesBranchIdRequestBody {
  const V1OvenBranchesBranchIdRequestBody({required this.enabled});

  factory V1OvenBranchesBranchIdRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$V1OvenBranchesBranchIdRequestBodyFromJson(json);

  final bool enabled;

  Map<String, Object?> toJson() =>
      _$V1OvenBranchesBranchIdRequestBodyToJson(this);
}
