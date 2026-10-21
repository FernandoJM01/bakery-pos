// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'branch.dart';
import 'device.dart';

part 'device_activate_response.g.dart';

@JsonSerializable()
class DeviceActivateResponse {
  const DeviceActivateResponse({
    required this.device,
    required this.deviceToken,
    required this.branch,
  });

  factory DeviceActivateResponse.fromJson(Map<String, Object?> json) =>
      _$DeviceActivateResponseFromJson(json);

  final Device device;

  /// Shown once. Store in secure storage; send as X-Device-Token.
  final String deviceToken;
  final Branch branch;

  Map<String, Object?> toJson() => _$DeviceActivateResponseToJson(this);
}
