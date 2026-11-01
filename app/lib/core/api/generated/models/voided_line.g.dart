// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voided_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoidedLine _$VoidedLineFromJson(Map<String, dynamic> json) => VoidedLine(
  variantId: json['variantId'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPriceCents: (json['unitPriceCents'] as num).toInt(),
  voidedAt: DateTime.parse(json['voidedAt'] as String),
  staffId: json['staffId'] as String,
);

Map<String, dynamic> _$VoidedLineToJson(VoidedLine instance) =>
    <String, dynamic>{
      'variantId': instance.variantId,
      'quantity': instance.quantity,
      'unitPriceCents': instance.unitPriceCents,
      'voidedAt': instance.voidedAt.toIso8601String(),
      'staffId': instance.staffId,
    };
