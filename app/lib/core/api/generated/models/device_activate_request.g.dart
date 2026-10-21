// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_activate_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceActivateRequest _$DeviceActivateRequestFromJson(
  Map<String, dynamic> json,
) => DeviceActivateRequest(
  enrollmentCode: json['enrollmentCode'] as String,
  appVersion: json['appVersion'] as String,
);

Map<String, dynamic> _$DeviceActivateRequestToJson(
  DeviceActivateRequest instance,
) => <String, dynamic>{
  'enrollmentCode': instance.enrollmentCode,
  'appVersion': instance.appVersion,
};
