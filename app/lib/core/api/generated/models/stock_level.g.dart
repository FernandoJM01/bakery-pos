// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_level.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockLevel _$StockLevelFromJson(Map<String, dynamic> json) => StockLevel(
  branchId: json['branchId'] as String,
  variantId: json['variantId'] as String,
  productName: json['productName'] as String,
  variantName: json['variantName'] as String,
  onHand: (json['onHand'] as num).toInt(),
  freshUnits: (json['freshUnits'] as num).toInt(),
  dayOldUnits: (json['dayOldUnits'] as num).toInt(),
  wasteDueUnits: (json['wasteDueUnits'] as num).toInt(),
);

Map<String, dynamic> _$StockLevelToJson(StockLevel instance) =>
    <String, dynamic>{
      'branchId': instance.branchId,
      'variantId': instance.variantId,
      'productName': instance.productName,
      'variantName': instance.variantName,
      'onHand': instance.onHand,
      'freshUnits': instance.freshUnits,
      'dayOldUnits': instance.dayOldUnits,
      'wasteDueUnits': instance.wasteDueUnits,
    };
