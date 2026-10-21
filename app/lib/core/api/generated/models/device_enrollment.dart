// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'device.dart';

part 'device_enrollment.g.dart';

@JsonSerializable()
class DeviceEnrollment {
  const DeviceEnrollment({
    required this.device,
    required this.enrollmentCode,
    required this.expiresAt,
  });

  factory DeviceEnrollment.fromJson(Map<String, Object?> json) =>
      _$DeviceEnrollmentFromJson(json);

  final Device device;

  /// Shown once. Valid 30 minutes, single use.
  final String enrollmentCode;
  final DateTime expiresAt;

  Map<String, Object?> toJson() => _$DeviceEnrollmentToJson(this);
}
