// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'role.dart';

part 'staff_update.g.dart';

@JsonSerializable()
class StaffUpdate {
  const StaffUpdate({
    this.fullName,
    this.displayName,
    this.role,
    this.email,
    this.password,
    this.branchIds,
    this.isActive,
  });

  factory StaffUpdate.fromJson(Map<String, Object?> json) =>
      _$StaffUpdateFromJson(json);

  final String? fullName;
  final String? displayName;
  final Role? role;
  final String? email;
  final String? password;
  final List<String>? branchIds;
  final bool? isActive;

  Map<String, Object?> toJson() => _$StaffUpdateToJson(this);
}
