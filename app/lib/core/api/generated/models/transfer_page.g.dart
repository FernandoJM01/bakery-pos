// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferPage _$TransferPageFromJson(Map<String, dynamic> json) => TransferPage(
  items: (json['items'] as List<dynamic>)
      .map((e) => Transfer.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['nextCursor'] as String?,
);

Map<String, dynamic> _$TransferPageToJson(TransferPage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextCursor': ?instance.nextCursor,
    };
