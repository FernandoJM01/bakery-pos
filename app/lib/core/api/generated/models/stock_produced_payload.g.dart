// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_produced_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockProducedPayload _$StockProducedPayloadFromJson(
  Map<String, dynamic> json,
) => StockProducedPayload(
  variantId: json['variantId'] as String,
  quantity: (json['quantity'] as num).toInt(),
  producedOn: json['producedOn'] as LocalDate,
  staffId: json['staffId'] as String,
);

Map<String, dynamic> _$StockProducedPayloadToJson(
  StockProducedPayload instance,
) => <String, dynamic>{
  'variantId': instance.variantId,
  'quantity': instance.quantity,
  'producedOn': instance.producedOn,
  'staffId': instance.staffId,
};
