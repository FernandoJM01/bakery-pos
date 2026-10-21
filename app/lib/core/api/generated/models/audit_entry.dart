// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'audit_action.dart';

part 'audit_entry.g.dart';

@JsonSerializable()
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.occurredAt,
    required this.action,
    this.branchId,
    this.deviceId,
    this.actorStaffId,
    this.approverStaffId,
    this.entityType,
    this.entityId,
    this.data,
  });

  factory AuditEntry.fromJson(Map<String, Object?> json) =>
      _$AuditEntryFromJson(json);

  final String id;
  final DateTime occurredAt;
  final String? branchId;
  final String? deviceId;
  final String? actorStaffId;
  final String? approverStaffId;
  final AuditAction action;
  final String? entityType;
  final String? entityId;

  /// Never contains PINs, passwords or tokens.
  final dynamic data;

  Map<String, Object?> toJson() => _$AuditEntryToJson(this);
}
