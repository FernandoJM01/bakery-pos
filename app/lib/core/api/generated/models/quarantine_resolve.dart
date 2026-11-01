// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'quarantine_resolve.g.dart';

@JsonSerializable()
class QuarantineResolve {
  const QuarantineResolve({required this.note});

  factory QuarantineResolve.fromJson(Map<String, Object?> json) =>
      _$QuarantineResolveFromJson(json);

  final String note;

  Map<String, Object?> toJson() => _$QuarantineResolveToJson(this);
}
