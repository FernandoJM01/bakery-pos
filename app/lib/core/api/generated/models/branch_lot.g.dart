// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_lot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchLot _$BranchLotFromJson(Map<String, dynamic> json) => BranchLot(
  id: json['id'] as String,
  variantId: json['variantId'] as String,
  producedOn: json['producedOn'] as LocalDate,
  quantityLeft: (json['quantityLeft'] as num).toInt(),
);

Map<String, dynamic> _$BranchLotToJson(BranchLot instance) => <String, dynamic>{
  'id': instance.id,
  'variantId': instance.variantId,
  'producedOn': instance.producedOn,
  'quantityLeft': instance.quantityLeft,
};
