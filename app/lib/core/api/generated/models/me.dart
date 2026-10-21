// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'permission_key.dart';
import 'staff.dart';

part 'me.g.dart';

@JsonSerializable()
class Me {
  const Me({required this.staff, required this.permissions, this.deviceId});

  factory Me.fromJson(Map<String, Object?> json) => _$MeFromJson(json);

  final Staff staff;
  final List<PermissionKey> permissions;
  final String? deviceId;

  Map<String, Object?> toJson() => _$MeToJson(this);
}
