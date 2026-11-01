// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'quarantine_entry.dart';

part 'quarantine_page.g.dart';

@JsonSerializable()
class QuarantinePage {
  const QuarantinePage({required this.items, this.nextCursor});

  factory QuarantinePage.fromJson(Map<String, Object?> json) =>
      _$QuarantinePageFromJson(json);

  final List<QuarantineEntry> items;
  final String? nextCursor;

  Map<String, Object?> toJson() => _$QuarantinePageToJson(this);
}
