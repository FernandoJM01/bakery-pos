// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_ticket_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderTicketLine _$OrderTicketLineFromJson(Map<String, dynamic> json) =>
    OrderTicketLine(
      lineNo: (json['lineNo'] as num).toInt(),
      variantId: json['variantId'] as String,
      productName: json['productName'] as String,
      variantName: json['variantName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPriceCents: (json['unitPriceCents'] as num).toInt(),
      ivaRateId: json['ivaRateId'] as String,
      ivaBp: (json['ivaBp'] as num).toInt(),
      iepsRateId: json['iepsRateId'] as String?,
      iepsBp: (json['iepsBp'] as num).toInt(),
    );

Map<String, dynamic> _$OrderTicketLineToJson(OrderTicketLine instance) =>
    <String, dynamic>{
      'lineNo': instance.lineNo,
      'variantId': instance.variantId,
      'productName': instance.productName,
      'variantName': instance.variantName,
      'quantity': instance.quantity,
      'unitPriceCents': instance.unitPriceCents,
      'ivaRateId': instance.ivaRateId,
      'ivaBp': instance.ivaBp,
      'iepsRateId': ?instance.iepsRateId,
      'iepsBp': instance.iepsBp,
    };
