// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'permission_key.dart';
import 'pin.dart';

part 'approval_request.g.dart';

@JsonSerializable()
class ApprovalRequest {
  const ApprovalRequest({
    required this.approverStaffId,
    required this.pin,
    required this.action,
    this.reference,
  });

  factory ApprovalRequest.fromJson(Map<String, Object?> json) =>
      _$ApprovalRequestFromJson(json);

  final String approverStaffId;
  final Pin pin;
  final PermissionKey action;

  /// What is being approved, for example a sale folio.
  final String? reference;

  Map<String, Object?> toJson() => _$ApprovalRequestToJson(this);
}
