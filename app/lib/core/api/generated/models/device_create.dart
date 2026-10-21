// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'device_type.dart';

part 'device_create.g.dart';

@JsonSerializable()
class DeviceCreate {
  const DeviceCreate({
    required this.branchId,
    required this.name,
    required this.type,
  });

  factory DeviceCreate.fromJson(Map<String, Object?> json) =>
      _$DeviceCreateFromJson(json);

  final String branchId;
  final String name;
  final DeviceType type;

  Map<String, Object?> toJson() => _$DeviceCreateToJson(this);
}
