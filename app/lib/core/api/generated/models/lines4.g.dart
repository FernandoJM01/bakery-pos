// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lines4.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lines4 _$Lines4FromJson(Map<String, dynamic> json) => Lines4(
  variantId: json['variantId'] as String,
  productName: json['productName'] as String,
  variantName: json['variantName'] as String,
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$Lines4ToJson(Lines4 instance) => <String, dynamic>{
  'variantId': instance.variantId,
  'productName': instance.productName,
  'variantName': instance.variantName,
  'quantity': instance.quantity,
};
