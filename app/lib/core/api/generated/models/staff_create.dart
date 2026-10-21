// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pin.dart';
import 'role.dart';

part 'staff_create.g.dart';

@JsonSerializable()
class StaffCreate {
  const StaffCreate({
    required this.fullName,
    required this.displayName,
    required this.role,
    required this.branchIds,
    required this.pin,
    this.email,
    this.password,
  });

  factory StaffCreate.fromJson(Map<String, Object?> json) =>
      _$StaffCreateFromJson(json);

  final String fullName;
  final String displayName;
  final Role role;
  final String? email;

  /// Required when role is OWNER; optional for BRANCH_MANAGER.
  final String? password;
  final List<String> branchIds;
  final Pin pin;

  Map<String, Object?> toJson() => _$StaffCreateToJson(this);
}
