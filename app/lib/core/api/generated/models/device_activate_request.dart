// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'device_activate_request.g.dart';

@JsonSerializable()
class DeviceActivateRequest {
  const DeviceActivateRequest({
    required this.enrollmentCode,
    required this.appVersion,
  });

  factory DeviceActivateRequest.fromJson(Map<String, Object?> json) =>
      _$DeviceActivateRequestFromJson(json);

  final String enrollmentCode;
  final String appVersion;

  Map<String, Object?> toJson() => _$DeviceActivateRequestToJson(this);
}
