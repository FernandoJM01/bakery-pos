// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sync_record_type.dart';

part 'sync_record.g.dart';

@JsonSerializable()
class SyncRecord {
  const SyncRecord({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.payload,
    this.actorStaffId,
  });

  factory SyncRecord.fromJson(Map<String, Object?> json) =>
      _$SyncRecordFromJson(json);

  /// UUID v7 created on the till when the record was written; the idempotency key.
  final String id;
  final SyncRecordType type;
  final DateTime occurredAt;
  final String? actorStaffId;
  final dynamic payload;

  Map<String, Object?> toJson() => _$SyncRecordToJson(this);
}
