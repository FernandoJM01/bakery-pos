// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quarantine_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuarantineEntry _$QuarantineEntryFromJson(Map<String, dynamic> json) =>
    QuarantineEntry(
      recordId: json['recordId'] as String,
      deviceId: json['deviceId'] as String,
      branchId: json['branchId'] as String,
      type: json['type'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      errorCode: json['errorCode'] as String,
      errorMessage: json['errorMessage'] as String,
      payload: json['payload'],
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolvedByStaffId: json['resolvedByStaffId'] as String?,
      resolutionNote: json['resolutionNote'] as String?,
    );

Map<String, dynamic> _$QuarantineEntryToJson(QuarantineEntry instance) =>
    <String, dynamic>{
      'recordId': instance.recordId,
      'deviceId': instance.deviceId,
      'branchId': instance.branchId,
      'type': instance.type,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'receivedAt': instance.receivedAt.toIso8601String(),
      'errorCode': instance.errorCode,
      'errorMessage': instance.errorMessage,
      'payload': ?instance.payload,
      'resolvedAt': ?instance.resolvedAt?.toIso8601String(),
      'resolvedByStaffId': ?instance.resolvedByStaffId,
      'resolutionNote': ?instance.resolutionNote,
    };
