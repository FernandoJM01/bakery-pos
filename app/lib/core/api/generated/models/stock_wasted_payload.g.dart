// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_wasted_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockWastedPayload _$StockWastedPayloadFromJson(Map<String, dynamic> json) =>
    StockWastedPayload(
      variantId: json['variantId'] as String,
      quantity: (json['quantity'] as num).toInt(),
      reason: WasteReason.fromJson(json['reason'] as String),
      staffId: json['staffId'] as String,
      lotId: json['lotId'] as String?,
    );

Map<String, dynamic> _$StockWastedPayloadToJson(StockWastedPayload instance) =>
    <String, dynamic>{
      'variantId': instance.variantId,
      'quantity': instance.quantity,
      'reason': _$WasteReasonEnumMap[instance.reason]!,
      'lotId': ?instance.lotId,
      'staffId': instance.staffId,
    };

const _$WasteReasonEnumMap = {
  WasteReason.burnt: 'BURNT',
  WasteReason.expired: 'EXPIRED',
  WasteReason.damaged: 'DAMAGED',
  WasteReason.unsold: 'UNSOLD',
  WasteReason.$unknown: r'$unknown',
};
