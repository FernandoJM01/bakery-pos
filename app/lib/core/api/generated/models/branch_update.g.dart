// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchUpdate _$BranchUpdateFromJson(Map<String, dynamic> json) => BranchUpdate(
  name: json['name'] as String?,
  address: json['address'] as String?,
  timezone: json['timezone'] as String?,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$BranchUpdateToJson(BranchUpdate instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'address': ?instance.address,
      'timezone': ?instance.timezone,
      'isActive': ?instance.isActive,
    };
