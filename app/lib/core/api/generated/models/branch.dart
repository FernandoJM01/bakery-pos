// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'branch.g.dart';

@JsonSerializable()
class Branch {
  const Branch({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.timezone = 'America/Mexico_City',
    this.address,
  });

  factory Branch.fromJson(Map<String, Object?> json) => _$BranchFromJson(json);

  final String id;
  final String code;
  final String name;
  final String? address;
  final String timezone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$BranchToJson(this);
}
