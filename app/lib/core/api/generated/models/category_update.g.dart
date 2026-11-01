// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryUpdate _$CategoryUpdateFromJson(Map<String, dynamic> json) =>
    CategoryUpdate(
      name: json['name'] as String?,
      color: json['color'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$CategoryUpdateToJson(CategoryUpdate instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'color': ?instance.color,
      'sortOrder': ?instance.sortOrder,
      'isActive': ?instance.isActive,
    };
