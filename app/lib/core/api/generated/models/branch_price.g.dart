// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchPrice _$BranchPriceFromJson(Map<String, dynamic> json) => BranchPrice(
  variantId: json['variantId'] as String,
  branchId: json['branchId'] as String,
  priceCents: (json['priceCents'] as num).toInt(),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BranchPriceToJson(BranchPrice instance) =>
    <String, dynamic>{
      'variantId': instance.variantId,
      'branchId': instance.branchId,
      'priceCents': instance.priceCents,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
