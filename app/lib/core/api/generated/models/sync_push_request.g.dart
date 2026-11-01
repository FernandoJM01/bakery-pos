// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_push_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncPushRequest _$SyncPushRequestFromJson(Map<String, dynamic> json) =>
    SyncPushRequest(
      records: (json['records'] as List<dynamic>)
          .map((e) => SyncRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SyncPushRequestToJson(SyncPushRequest instance) =>
    <String, dynamic>{'records': instance.records};
