// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'branches.g.dart';

@JsonSerializable()
class Branches {
  const Branches({
    required this.branchId,
    required this.name,
    required this.netCents,
    required this.saleCount,
  });

  factory Branches.fromJson(Map<String, Object?> json) =>
      _$BranchesFromJson(json);

  final String branchId;
  final String name;
  final int netCents;
  final int saleCount;

  Map<String, Object?> toJson() => _$BranchesToJson(this);
}
