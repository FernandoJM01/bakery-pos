// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branches.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Branches _$BranchesFromJson(Map<String, dynamic> json) => Branches(
  branchId: json['branchId'] as String,
  name: json['name'] as String,
  netCents: (json['netCents'] as num).toInt(),
  saleCount: (json['saleCount'] as num).toInt(),
);

Map<String, dynamic> _$BranchesToJson(Branches instance) => <String, dynamic>{
  'branchId': instance.branchId,
  'name': instance.name,
  'netCents': instance.netCents,
  'saleCount': instance.saleCount,
};
