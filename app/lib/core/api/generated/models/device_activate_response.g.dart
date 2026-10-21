// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_activate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceActivateResponse _$DeviceActivateResponseFromJson(
  Map<String, dynamic> json,
) => DeviceActivateResponse(
  device: Device.fromJson(json['device'] as Map<String, dynamic>),
  deviceToken: json['deviceToken'] as String,
  branch: Branch.fromJson(json['branch'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DeviceActivateResponseToJson(
  DeviceActivateResponse instance,
) => <String, dynamic>{
  'device': instance.device,
  'deviceToken': instance.deviceToken,
  'branch': instance.branch,
};
