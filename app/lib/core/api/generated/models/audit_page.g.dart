// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditPage _$AuditPageFromJson(Map<String, dynamic> json) => AuditPage(
  items: (json['items'] as List<dynamic>)
      .map((e) => AuditEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['nextCursor'] as String?,
);

Map<String, dynamic> _$AuditPageToJson(AuditPage instance) => <String, dynamic>{
  'items': instance.items,
  'nextCursor': instance.nextCursor,
};
