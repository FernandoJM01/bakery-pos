// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftPage _$ShiftPageFromJson(Map<String, dynamic> json) => ShiftPage(
  items: (json['items'] as List<dynamic>)
      .map((e) => ShiftSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['nextCursor'] as String?,
);

Map<String, dynamic> _$ShiftPageToJson(ShiftPage instance) => <String, dynamic>{
  'items': instance.items,
  'nextCursor': ?instance.nextCursor,
};
