// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'shift_summary.dart';

part 'shift_page.g.dart';

@JsonSerializable()
class ShiftPage {
  const ShiftPage({required this.items, required this.nextCursor});

  factory ShiftPage.fromJson(Map<String, Object?> json) =>
      _$ShiftPageFromJson(json);

  final List<ShiftSummary> items;
  final String? nextCursor;

  Map<String, Object?> toJson() => _$ShiftPageToJson(this);
}
