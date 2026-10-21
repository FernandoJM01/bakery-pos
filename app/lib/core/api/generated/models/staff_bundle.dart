// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'permission_key.dart';
import 'staff_bundle_entry.dart';

part 'staff_bundle.g.dart';

@JsonSerializable()
class StaffBundle {
  const StaffBundle({
    required this.branchId,
    required this.generatedAt,
    required this.staff,
    required this.roles,
  });

  factory StaffBundle.fromJson(Map<String, Object?> json) =>
      _$StaffBundleFromJson(json);

  final String branchId;
  final DateTime generatedAt;
  final List<StaffBundleEntry> staff;

  /// Permission keys per role, so the till can check permissions offline.
  final Map<String, List<PermissionKey>> roles;

  Map<String, Object?> toJson() => _$StaffBundleToJson(this);
}
