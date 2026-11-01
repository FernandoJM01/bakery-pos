// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'offline_audit_payload_action.dart';

part 'offline_audit_payload.g.dart';

/// Payload of `audit.offline_event`. Never contains a PIN.
@JsonSerializable()
class OfflineAuditPayload {
  const OfflineAuditPayload({
    required this.action,
    required this.staffId,
    this.approverStaffId,
    this.approvalAction,
    this.reference,
  });

  factory OfflineAuditPayload.fromJson(Map<String, Object?> json) =>
      _$OfflineAuditPayloadFromJson(json);

  final OfflineAuditPayloadAction action;

  /// Who logged in, who failed, who was locked, or who asked for the approval
  final String staffId;

  /// Required for `auth.approval_granted`
  final String? approverStaffId;

  /// The permission key (`PermissionKey`) that was approved; required for `auth.approval_granted`
  final String? approvalAction;
  final String? reference;

  Map<String, Object?> toJson() => _$OfflineAuditPayloadToJson(this);
}
