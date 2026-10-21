// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'branch_update.g.dart';

@JsonSerializable()
class BranchUpdate {
  const BranchUpdate({this.name, this.address, this.timezone, this.isActive});

  factory BranchUpdate.fromJson(Map<String, Object?> json) =>
      _$BranchUpdateFromJson(json);

  final String? name;
  final String? address;
  final String? timezone;
  final bool? isActive;

  Map<String, Object?> toJson() => _$BranchUpdateToJson(this);
}
