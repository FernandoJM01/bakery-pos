// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'waste_entry.dart';

part 'waste_page.g.dart';

@JsonSerializable()
class WastePage {
  const WastePage({
    required this.items,
    required this.nextCursor,
    required this.totalCostCents,
  });

  factory WastePage.fromJson(Map<String, Object?> json) =>
      _$WastePageFromJson(json);

  final List<WasteEntry> items;
  final String? nextCursor;

  /// Over the whole filter, not the page
  final int totalCostCents;

  Map<String, Object?> toJson() => _$WastePageToJson(this);
}
