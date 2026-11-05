// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferLine _$TransferLineFromJson(Map<String, dynamic> json) => TransferLine(
  variantId: json['variantId'] as String,
  productName: json['productName'] as String,
  variantName: json['variantName'] as String,
  producedOn: json['producedOn'] as LocalDate,
  quantitySent: (json['quantitySent'] as num).toInt(),
  quantityReceived: (json['quantityReceived'] as num?)?.toInt(),
);

Map<String, dynamic> _$TransferLineToJson(TransferLine instance) =>
    <String, dynamic>{
      'variantId': instance.variantId,
      'productName': instance.productName,
      'variantName': instance.variantName,
      'producedOn': instance.producedOn,
      'quantitySent': instance.quantitySent,
      'quantityReceived': ?instance.quantityReceived,
    };
