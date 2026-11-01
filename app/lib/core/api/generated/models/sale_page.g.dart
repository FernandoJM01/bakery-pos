// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalePage _$SalePageFromJson(Map<String, dynamic> json) => SalePage(
  items: (json['items'] as List<dynamic>)
      .map((e) => SaleSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['nextCursor'] as String?,
);

Map<String, dynamic> _$SalePageToJson(SalePage instance) => <String, dynamic>{
  'items': instance.items,
  'nextCursor': ?instance.nextCursor,
};
