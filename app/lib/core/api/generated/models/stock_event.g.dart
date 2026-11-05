// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockEvent _$StockEventFromJson(Map<String, dynamic> json) => StockEvent(
  id: json['id'] as String,
  kind: StockEventKind.fromJson(json['kind'] as String),
  quantity: (json['quantity'] as num).toInt(),
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  lotId: json['lotId'] as String?,
  referenceType: json['referenceType'] as String?,
  referenceId: json['referenceId'] as String?,
  staffId: json['staffId'] as String?,
);

Map<String, dynamic> _$StockEventToJson(StockEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$StockEventKindEnumMap[instance.kind]!,
      'quantity': instance.quantity,
      'lotId': ?instance.lotId,
      'referenceType': ?instance.referenceType,
      'referenceId': ?instance.referenceId,
      'staffId': ?instance.staffId,
      'occurredAt': instance.occurredAt.toIso8601String(),
    };

const _$StockEventKindEnumMap = {
  StockEventKind.production: 'PRODUCTION',
  StockEventKind.sale: 'SALE',
  StockEventKind.refundReturn: 'REFUND_RETURN',
  StockEventKind.waste: 'WASTE',
  StockEventKind.transferOut: 'TRANSFER_OUT',
  StockEventKind.transferIn: 'TRANSFER_IN',
  StockEventKind.countAdjust: 'COUNT_ADJUST',
  StockEventKind.$unknown: r'$unknown',
};
