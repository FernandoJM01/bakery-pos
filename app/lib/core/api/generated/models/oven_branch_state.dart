// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'oven_branch_state.g.dart';

/// Whether a branch takes dishes for the oven (M8.5)
@JsonSerializable()
class OvenBranchState {
  const OvenBranchState({
    required this.branchId,
    required this.name,
    required this.enabled,
  });

  factory OvenBranchState.fromJson(Map<String, Object?> json) =>
      _$OvenBranchStateFromJson(json);

  final String branchId;
  final String name;
  final bool enabled;

  Map<String, Object?> toJson() => _$OvenBranchStateToJson(this);
}
