// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quarantine_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuarantinePage _$QuarantinePageFromJson(Map<String, dynamic> json) =>
    QuarantinePage(
      items: (json['items'] as List<dynamic>)
          .map((e) => QuarantineEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$QuarantinePageToJson(QuarantinePage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextCursor': ?instance.nextCursor,
    };
