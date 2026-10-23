// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffCreate _$StaffCreateFromJson(Map<String, dynamic> json) => StaffCreate(
  fullName: json['fullName'] as String,
  displayName: json['displayName'] as String,
  role: Role.fromJson(json['role'] as String),
  branchIds: (json['branchIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  pin: json['pin'] as Pin,
  email: json['email'] as String?,
  password: json['password'] as String?,
);

Map<String, dynamic> _$StaffCreateToJson(StaffCreate instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'displayName': instance.displayName,
      'role': _$RoleEnumMap[instance.role]!,
      'email': ?instance.email,
      'password': ?instance.password,
      'branchIds': instance.branchIds,
      'pin': instance.pin,
    };

const _$RoleEnumMap = {
  Role.owner: 'OWNER',
  Role.branchManager: 'BRANCH_MANAGER',
  Role.cashier: 'CASHIER',
  Role.baker: 'BAKER',
  Role.$unknown: r'$unknown',
};
