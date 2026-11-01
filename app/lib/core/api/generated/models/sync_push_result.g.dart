// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_push_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncPushResult _$SyncPushResultFromJson(Map<String, dynamic> json) =>
    SyncPushResult(
      id: json['id'] as String,
      status: SyncResultStatus.fromJson(json['status'] as String),
      errorCode: json['errorCode'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SyncPushResultToJson(SyncPushResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$SyncResultStatusEnumMap[instance.status]!,
      'errorCode': ?instance.errorCode,
      'message': ?instance.message,
    };

const _$SyncResultStatusEnumMap = {
  SyncResultStatus.applied: 'APPLIED',
  SyncResultStatus.duplicate: 'DUPLICATE',
  SyncResultStatus.quarantined: 'QUARANTINED',
  SyncResultStatus.$unknown: r'$unknown',
};
