// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncRecord _$SyncRecordFromJson(Map<String, dynamic> json) => SyncRecord(
  id: json['id'] as String,
  type: json['type'] as SyncRecordType,
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  payload: json['payload'],
  actorStaffId: json['actorStaffId'] as String?,
);

Map<String, dynamic> _$SyncRecordToJson(SyncRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'actorStaffId': ?instance.actorStaffId,
      'payload': ?instance.payload,
    };
