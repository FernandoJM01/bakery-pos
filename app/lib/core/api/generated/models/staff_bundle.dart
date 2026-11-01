// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'permission_key.dart';
import 'sale_settings.dart';
import 'staff_bundle_entry.dart';

part 'staff_bundle.g.dart';

/// `folioPrefix` and `saleSettings` are sent by every server from 0.3.0-m3. They are optional in the schema only so.
/// a till can tell an older server apart; a till without `folioPrefix` must not sell.
///
@JsonSerializable()
class StaffBundle {
  const StaffBundle({
    required this.branchId,
    required this.generatedAt,
    required this.staff,
    required this.roles,
    this.folioPrefix,
    this.saleSettings,
  });

  factory StaffBundle.fromJson(Map<String, Object?> json) =>
      _$StaffBundleFromJson(json);

  final String branchId;
  final DateTime generatedAt;

  /// This device's folio prefix (`Device.folioPrefix`); null for production stations.
  final String? folioPrefix;
  final SaleSettings? saleSettings;
  final List<StaffBundleEntry> staff;

  /// Permission keys per role, so the till can check permissions offline.
  final Map<String, List<PermissionKey>> roles;

  Map<String, Object?> toJson() => _$StaffBundleToJson(this);
}
