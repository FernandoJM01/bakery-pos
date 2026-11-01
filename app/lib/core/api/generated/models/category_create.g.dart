// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryCreate _$CategoryCreateFromJson(Map<String, dynamic> json) =>
    CategoryCreate(
      name: json['name'] as String,
      color: json['color'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CategoryCreateToJson(CategoryCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'color': ?instance.color,
      'sortOrder': ?instance.sortOrder,
    };
