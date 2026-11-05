// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waste_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WasteEntry _$WasteEntryFromJson(Map<String, dynamic> json) => WasteEntry(
  id: json['id'] as String,
  branchId: json['branchId'] as String,
  variantId: json['variantId'] as String,
  productName: json['productName'] as String,
  variantName: json['variantName'] as String,
  quantity: (json['quantity'] as num).toInt(),
  reason: WasteReason.fromJson(json['reason'] as String),
  staffId: json['staffId'] as String,
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  costCents: (json['costCents'] as num?)?.toInt(),
);

Map<String, dynamic> _$WasteEntryToJson(WasteEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'branchId': instance.branchId,
      'variantId': instance.variantId,
      'productName': instance.productName,
      'variantName': instance.variantName,
      'quantity': instance.quantity,
      'reason': _$WasteReasonEnumMap[instance.reason]!,
      'staffId': instance.staffId,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'costCents': ?instance.costCents,
    };

const _$WasteReasonEnumMap = {
  WasteReason.burnt: 'BURNT',
  WasteReason.expired: 'EXPIRED',
  WasteReason.damaged: 'DAMAGED',
  WasteReason.unsold: 'UNSOLD',
  WasteReason.$unknown: r'$unknown',
};
