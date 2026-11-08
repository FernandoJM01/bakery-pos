// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totals.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Totals _$TotalsFromJson(Map<String, dynamic> json) => Totals(
  variantId: json['variantId'] as String,
  productName: json['productName'] as String,
  variantName: json['variantName'] as String,
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$TotalsToJson(Totals instance) => <String, dynamic>{
  'variantId': instance.variantId,
  'productName': instance.productName,
  'variantName': instance.variantName,
  'quantity': instance.quantity,
};
