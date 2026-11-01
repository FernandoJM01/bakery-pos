// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'quarantine_entry.g.dart';

@JsonSerializable()
class QuarantineEntry {
  const QuarantineEntry({
    required this.recordId,
    required this.deviceId,
    required this.branchId,
    required this.type,
    required this.occurredAt,
    required this.receivedAt,
    required this.errorCode,
    required this.errorMessage,
    required this.payload,
    required this.resolvedAt,
    required this.resolvedByStaffId,
    required this.resolutionNote,
  });

  factory QuarantineEntry.fromJson(Map<String, Object?> json) =>
      _$QuarantineEntryFromJson(json);

  final String recordId;
  final String deviceId;
  final String branchId;
  final String type;
  final DateTime occurredAt;
  final DateTime receivedAt;
  final String errorCode;
  final String errorMessage;
  final dynamic payload;
  final DateTime? resolvedAt;
  final String? resolvedByStaffId;
  final String? resolutionNote;

  Map<String, Object?> toJson() => _$QuarantineEntryToJson(this);
}
