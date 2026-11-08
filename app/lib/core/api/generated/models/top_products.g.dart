// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_products.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopProducts _$TopProductsFromJson(Map<String, dynamic> json) => TopProducts(
  variantId: json['variantId'] as String,
  label: json['label'] as String,
  quantity: (json['quantity'] as num).toInt(),
  netCents: (json['netCents'] as num).toInt(),
);

Map<String, dynamic> _$TopProductsToJson(TopProducts instance) =>
    <String, dynamic>{
      'variantId': instance.variantId,
      'label': instance.label,
      'quantity': instance.quantity,
      'netCents': instance.netCents,
    };
