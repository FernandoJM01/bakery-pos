// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleLine _$SaleLineFromJson(Map<String, dynamic> json) => SaleLine(
  dayOld: json['dayOld'] as bool,
  fullPriceCents: (json['fullPriceCents'] as num).toInt(),
  lineNo: (json['lineNo'] as num).toInt(),
  variantId: json['variantId'] as String,
  productName: json['productName'] as String,
  variantName: json['variantName'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPriceCents: (json['unitPriceCents'] as num).toInt(),
  grossCents: (json['grossCents'] as num).toInt(),
  lineDiscountCents: (json['lineDiscountCents'] as num).toInt(),
  orderDiscountCents: (json['orderDiscountCents'] as num).toInt(),
  netCents: (json['netCents'] as num).toInt(),
  ivaRateId: json['ivaRateId'] as String,
  ivaBp: (json['ivaBp'] as num).toInt(),
  iepsRateId: json['iepsRateId'] as String?,
  iepsBp: (json['iepsBp'] as num).toInt(),
  baseCents: (json['baseCents'] as num).toInt(),
  iepsCents: (json['iepsCents'] as num).toInt(),
  ivaCents: (json['ivaCents'] as num).toInt(),
  refundedQuantity: (json['refundedQuantity'] as num).toInt(),
  refundedCents: (json['refundedCents'] as num?)?.toInt(),
);

Map<String, dynamic> _$SaleLineToJson(SaleLine instance) => <String, dynamic>{
  'dayOld': instance.dayOld,
  'fullPriceCents': instance.fullPriceCents,
  'lineNo': instance.lineNo,
  'variantId': instance.variantId,
  'productName': instance.productName,
  'variantName': instance.variantName,
  'quantity': instance.quantity,
  'unitPriceCents': instance.unitPriceCents,
  'grossCents': instance.grossCents,
  'lineDiscountCents': instance.lineDiscountCents,
  'orderDiscountCents': instance.orderDiscountCents,
  'netCents': instance.netCents,
  'ivaRateId': instance.ivaRateId,
  'ivaBp': instance.ivaBp,
  'iepsRateId': ?instance.iepsRateId,
  'iepsBp': instance.iepsBp,
  'baseCents': instance.baseCents,
  'iepsCents': instance.iepsCents,
  'ivaCents': instance.ivaCents,
  'refundedQuantity': instance.refundedQuantity,
  'refundedCents': ?instance.refundedCents,
};
