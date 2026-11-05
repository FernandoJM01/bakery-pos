// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_event_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockEventPage _$StockEventPageFromJson(Map<String, dynamic> json) =>
    StockEventPage(
      items: (json['items'] as List<dynamic>)
          .map((e) => StockEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$StockEventPageToJson(StockEventPage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextCursor': ?instance.nextCursor,
    };
