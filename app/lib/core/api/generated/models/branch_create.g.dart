// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchCreate _$BranchCreateFromJson(Map<String, dynamic> json) => BranchCreate(
  code: json['code'] as String,
  name: json['name'] as String,
  timezone: json['timezone'] as String? ?? 'America/Mexico_City',
  address: json['address'] as String?,
);

Map<String, dynamic> _$BranchCreateToJson(BranchCreate instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'address': ?instance.address,
      'timezone': instance.timezone,
    };
