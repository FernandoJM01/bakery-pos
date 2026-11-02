// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waste_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WastePage _$WastePageFromJson(Map<String, dynamic> json) => WastePage(
  items: (json['items'] as List<dynamic>)
      .map((e) => WasteEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['nextCursor'] as String?,
  totalCostCents: (json['totalCostCents'] as num).toInt(),
);

Map<String, dynamic> _$WastePageToJson(WastePage instance) => <String, dynamic>{
  'items': instance.items,
  'nextCursor': ?instance.nextCursor,
  'totalCostCents': instance.totalCostCents,
};
