// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'device_status.dart';
import 'device_type.dart';

part 'device.g.dart';

@JsonSerializable()
class Device {
  const Device({
    required this.id,
    required this.branchId,
    required this.name,
    required this.type,
    required this.status,
    required this.createdAt,
    this.lastSeenAt,
    this.appVersion,
    this.revokedAt,
  });

  factory Device.fromJson(Map<String, Object?> json) => _$DeviceFromJson(json);

  final String id;
  final String branchId;
  final String name;
  final DeviceType type;
  final DeviceStatus status;
  final DateTime? lastSeenAt;
  final String? appVersion;
  final DateTime createdAt;
  final DateTime? revokedAt;

  Map<String, Object?> toJson() => _$DeviceToJson(this);
}
