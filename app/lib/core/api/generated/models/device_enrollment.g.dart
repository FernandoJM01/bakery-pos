// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_enrollment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceEnrollment _$DeviceEnrollmentFromJson(Map<String, dynamic> json) =>
    DeviceEnrollment(
      device: Device.fromJson(json['device'] as Map<String, dynamic>),
      enrollmentCode: json['enrollmentCode'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$DeviceEnrollmentToJson(DeviceEnrollment instance) =>
    <String, dynamic>{
      'device': instance.device,
      'enrollmentCode': instance.enrollmentCode,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
