// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_bundle_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffBundleEntry _$StaffBundleEntryFromJson(Map<String, dynamic> json) =>
    StaffBundleEntry(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      role: Role.fromJson(json['role'] as String),
      offlinePinVerifier: json['offlinePinVerifier'] as String,
      pinUpdatedAt: DateTime.parse(json['pinUpdatedAt'] as String),
    );

Map<String, dynamic> _$StaffBundleEntryToJson(StaffBundleEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'role': _$RoleEnumMap[instance.role]!,
      'offlinePinVerifier': instance.offlinePinVerifier,
      'pinUpdatedAt': instance.pinUpdatedAt.toIso8601String(),
    };

const _$RoleEnumMap = {
  Role.owner: 'OWNER',
  Role.branchManager: 'BRANCH_MANAGER',
  Role.cashier: 'CASHIER',
  Role.baker: 'BAKER',
  Role.$unknown: r'$unknown',
};
