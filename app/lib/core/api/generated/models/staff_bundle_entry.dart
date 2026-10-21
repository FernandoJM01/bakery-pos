// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'role.dart';

part 'staff_bundle_entry.g.dart';

@JsonSerializable()
class StaffBundleEntry {
  const StaffBundleEntry({
    required this.id,
    required this.displayName,
    required this.role,
    required this.offlinePinVerifier,
    required this.pinUpdatedAt,
  });

  factory StaffBundleEntry.fromJson(Map<String, Object?> json) =>
      _$StaffBundleEntryFromJson(json);

  final String id;
  final String displayName;
  final Role role;

  /// Argon2id encoded hash (PHC string format, m=65536, t=3, p=1) of the PIN with its own random salt,.
  /// computed when the PIN is set. It is NOT the server's `pin_hash`. Stored only in the till's.
  /// encrypted storage.
  ///
  final String offlinePinVerifier;
  final DateTime pinUpdatedAt;

  Map<String, Object?> toJson() => _$StaffBundleEntryToJson(this);
}
