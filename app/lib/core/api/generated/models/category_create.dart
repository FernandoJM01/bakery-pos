// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'category_create.g.dart';

@JsonSerializable()
class CategoryCreate {
  const CategoryCreate({required this.name, this.color, this.sortOrder});

  factory CategoryCreate.fromJson(Map<String, Object?> json) =>
      _$CategoryCreateFromJson(json);

  final String name;
  final String? color;
  final int? sortOrder;

  Map<String, Object?> toJson() => _$CategoryCreateToJson(this);
}
