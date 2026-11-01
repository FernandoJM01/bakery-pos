// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_line_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleLineInput _$SaleLineInputFromJson(Map<String, dynamic> json) =>
    SaleLineInput(
      lineNo: (json['lineNo'] as num).toInt(),
      variantId: json['variantId'] as String,
      productName: json['productName'] as String,
      variantName: json['variantName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPriceCents: (json['unitPriceCents'] as num).toInt(),
      ivaRateId: json['ivaRateId'] as String,
      ivaBp: (json['ivaBp'] as num).toInt(),
      iepsBp: (json['iepsBp'] as num).toInt(),
      grossCents: (json['grossCents'] as num).toInt(),
      lineDiscountCents: (json['lineDiscountCents'] as num).toInt(),
      orderDiscountCents: (json['orderDiscountCents'] as num).toInt(),
      netCents: (json['netCents'] as num).toInt(),
      baseCents: (json['baseCents'] as num).toInt(),
      iepsCents: (json['iepsCents'] as num).toInt(),
      ivaCents: (json['ivaCents'] as num).toInt(),
      iepsRateId: json['iepsRateId'] as String?,
      discount: json['discount'] == null
          ? null
          : DiscountInput.fromJson(json['discount'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SaleLineInputToJson(SaleLineInput instance) =>
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
      'discount': ?instance.discount,
      'grossCents': instance.grossCents,
      'lineDiscountCents': instance.lineDiscountCents,
      'orderDiscountCents': instance.orderDiscountCents,
      'netCents': instance.netCents,
      'baseCents': instance.baseCents,
      'iepsCents': instance.iepsCents,
      'ivaCents': instance.ivaCents,
    };
