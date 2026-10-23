// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Staff _$StaffFromJson(Map<String, dynamic> json) => Staff(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  displayName: json['displayName'] as String,
  role: Role.fromJson(json['role'] as String),
  branchIds: (json['branchIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isActive: json['isActive'] as bool,
  hasPassword: json['hasPassword'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  email: json['email'] as String?,
  lockedUntil: json['lockedUntil'] == null
      ? null
      : DateTime.parse(json['lockedUntil'] as String),
);

Map<String, dynamic> _$StaffToJson(Staff instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'displayName': instance.displayName,
  'role': _$RoleEnumMap[instance.role]!,
  'email': ?instance.email,
  'branchIds': instance.branchIds,
  'isActive': instance.isActive,
  'hasPassword': instance.hasPassword,
  'lockedUntil': ?instance.lockedUntil?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$RoleEnumMap = {
  Role.owner: 'OWNER',
  Role.branchManager: 'BRANCH_MANAGER',
  Role.cashier: 'CASHIER',
  Role.baker: 'BAKER',
  Role.$unknown: r'$unknown',
};
