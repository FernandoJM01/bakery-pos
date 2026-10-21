// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'role.dart';

part 'staff.g.dart';

@JsonSerializable()
class Staff {
  const Staff({
    required this.id,
    required this.fullName,
    required this.displayName,
    required this.role,
    required this.branchIds,
    required this.isActive,
    required this.hasPassword,
    required this.createdAt,
    required this.updatedAt,
    this.email,
    this.lockedUntil,
  });

  factory Staff.fromJson(Map<String, Object?> json) => _$StaffFromJson(json);

  final String id;
  final String fullName;

  /// Short name on tiles and receipts
  final String displayName;
  final Role role;
  final String? email;
  final List<String> branchIds;
  final bool isActive;
  final bool hasPassword;
  final DateTime? lockedUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$StaffToJson(this);
}
