// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffUpdate _$StaffUpdateFromJson(Map<String, dynamic> json) => StaffUpdate(
  fullName: json['fullName'] as String?,
  displayName: json['displayName'] as String?,
  role: json['role'] == null ? null : Role.fromJson(json['role'] as String),
  email: json['email'] as String?,
  password: json['password'] as String?,
  branchIds: (json['branchIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$StaffUpdateToJson(StaffUpdate instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'displayName': instance.displayName,
      'role': _$RoleEnumMap[instance.role],
      'email': instance.email,
      'password': instance.password,
      'branchIds': instance.branchIds,
      'isActive': instance.isActive,
    };

const _$RoleEnumMap = {
  Role.owner: 'OWNER',
  Role.branchManager: 'BRANCH_MANAGER',
  Role.cashier: 'CASHIER',
  Role.baker: 'BAKER',
  Role.$unknown: r'$unknown',
};
