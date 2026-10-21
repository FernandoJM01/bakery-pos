// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'branch_create.g.dart';

@JsonSerializable()
class BranchCreate {
  const BranchCreate({
    required this.code,
    required this.name,
    this.timezone = 'America/Mexico_City',
    this.address,
  });

  factory BranchCreate.fromJson(Map<String, Object?> json) =>
      _$BranchCreateFromJson(json);

  final String code;
  final String name;
  final String? address;
  final String timezone;

  Map<String, Object?> toJson() => _$BranchCreateToJson(this);
}
