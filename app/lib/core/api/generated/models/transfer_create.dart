// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lines2.dart';

part 'transfer_create.g.dart';

@JsonSerializable()
class TransferCreate {
  const TransferCreate({
    required this.fromBranchId,
    required this.toBranchId,
    required this.lines,
  });

  factory TransferCreate.fromJson(Map<String, Object?> json) =>
      _$TransferCreateFromJson(json);

  final String fromBranchId;
  final String toBranchId;
  final List<Lines2> lines;

  Map<String, Object?> toJson() => _$TransferCreateToJson(this);
}
