// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.color,
    required this.isActive,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, Object?> json) =>
      _$CategoryFromJson(json);

  final String id;
  final String name;
  final int sortOrder;
  final String? color;
  final bool isActive;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$CategoryToJson(this);
}
