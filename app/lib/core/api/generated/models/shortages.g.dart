// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shortages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shortages _$ShortagesFromJson(Map<String, dynamic> json) => Shortages(
  variantId: json['variantId'] as String,
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$ShortagesToJson(Shortages instance) => <String, dynamic>{
  'variantId': instance.variantId,
  'quantity': instance.quantity,
};
