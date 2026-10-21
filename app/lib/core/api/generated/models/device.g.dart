// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
  id: json['id'] as String,
  branchId: json['branchId'] as String,
  name: json['name'] as String,
  type: DeviceType.fromJson(json['type'] as String),
  status: DeviceStatus.fromJson(json['status'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastSeenAt: json['lastSeenAt'] == null
      ? null
      : DateTime.parse(json['lastSeenAt'] as String),
  appVersion: json['appVersion'] as String?,
  revokedAt: json['revokedAt'] == null
      ? null
      : DateTime.parse(json['revokedAt'] as String),
);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'id': instance.id,
  'branchId': instance.branchId,
  'name': instance.name,
  'type': _$DeviceTypeEnumMap[instance.type]!,
  'status': _$DeviceStatusEnumMap[instance.status]!,
  'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
  'appVersion': instance.appVersion,
  'createdAt': instance.createdAt.toIso8601String(),
  'revokedAt': instance.revokedAt?.toIso8601String(),
};

const _$DeviceTypeEnumMap = {
  DeviceType.till: 'TILL',
  DeviceType.production: 'PRODUCTION',
  DeviceType.$unknown: r'$unknown',
};

const _$DeviceStatusEnumMap = {
  DeviceStatus.pending: 'PENDING',
  DeviceStatus.active: 'ACTIVE',
  DeviceStatus.revoked: 'REVOKED',
  DeviceStatus.$unknown: r'$unknown',
};
