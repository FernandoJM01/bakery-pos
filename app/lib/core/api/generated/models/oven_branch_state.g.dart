// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oven_branch_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvenBranchState _$OvenBranchStateFromJson(Map<String, dynamic> json) =>
    OvenBranchState(
      branchId: json['branchId'] as String,
      name: json['name'] as String,
      enabled: json['enabled'] as bool,
    );

Map<String, dynamic> _$OvenBranchStateToJson(OvenBranchState instance) =>
    <String, dynamic>{
      'branchId': instance.branchId,
      'name': instance.name,
      'enabled': instance.enabled,
    };
