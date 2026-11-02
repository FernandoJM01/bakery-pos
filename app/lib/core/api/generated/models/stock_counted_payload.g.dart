// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_counted_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockCountedPayload _$StockCountedPayloadFromJson(Map<String, dynamic> json) =>
    StockCountedPayload(
      staffId: json['staffId'] as String,
      lines: (json['lines'] as List<dynamic>)
          .map((e) => Lines.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StockCountedPayloadToJson(
  StockCountedPayload instance,
) => <String, dynamic>{'staffId': instance.staffId, 'lines': instance.lines};
