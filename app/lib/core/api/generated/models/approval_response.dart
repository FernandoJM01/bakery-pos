// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'permission_key.dart';

part 'approval_response.g.dart';

@JsonSerializable()
class ApprovalResponse {
  const ApprovalResponse({
    required this.approvalToken,
    required this.expiresAt,
    required this.approverStaffId,
    required this.action,
  });

  factory ApprovalResponse.fromJson(Map<String, Object?> json) =>
      _$ApprovalResponseFromJson(json);

  final String approvalToken;
  final DateTime expiresAt;
  final String approverStaffId;
  final PermissionKey action;

  Map<String, Object?> toJson() => _$ApprovalResponseToJson(this);
}
