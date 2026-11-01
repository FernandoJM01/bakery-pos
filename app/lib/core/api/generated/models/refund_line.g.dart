// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefundLine _$RefundLineFromJson(Map<String, dynamic> json) => RefundLine(
  lineNo: (json['lineNo'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  amountCents: (json['amountCents'] as num).toInt(),
  baseCents: (json['baseCents'] as num).toInt(),
  iepsCents: (json['iepsCents'] as num).toInt(),
  ivaCents: (json['ivaCents'] as num).toInt(),
  restock: json['restock'] as bool,
);

Map<String, dynamic> _$RefundLineToJson(RefundLine instance) =>
    <String, dynamic>{
      'lineNo': instance.lineNo,
      'quantity': instance.quantity,
      'amountCents': instance.amountCents,
      'baseCents': instance.baseCents,
      'iepsCents': instance.iepsCents,
      'ivaCents': instance.ivaCents,
      'restock': instance.restock,
    };
