// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'category_update.g.dart';

@JsonSerializable()
class CategoryUpdate {
  const CategoryUpdate({this.name, this.color, this.sortOrder, this.isActive});

  factory CategoryUpdate.fromJson(Map<String, Object?> json) =>
      _$CategoryUpdateFromJson(json);

  final String? name;
  final String? color;
  final int? sortOrder;
  final bool? isActive;

  Map<String, Object?> toJson() => _$CategoryUpdateToJson(this);
}
