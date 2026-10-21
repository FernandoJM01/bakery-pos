// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceCreate _$DeviceCreateFromJson(Map<String, dynamic> json) => DeviceCreate(
  branchId: json['branchId'] as String,
  name: json['name'] as String,
  type: DeviceType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$DeviceCreateToJson(DeviceCreate instance) =>
    <String, dynamic>{
      'branchId': instance.branchId,
      'name': instance.name,
      'type': _$DeviceTypeEnumMap[instance.type]!,
    };

const _$DeviceTypeEnumMap = {
  DeviceType.till: 'TILL',
  DeviceType.production: 'PRODUCTION',
  DeviceType.$unknown: r'$unknown',
};
