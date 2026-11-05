// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Me _$MeFromJson(Map<String, dynamic> json) => Me(
  staff: Staff.fromJson(json['staff'] as Map<String, dynamic>),
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => PermissionKey.fromJson(e as String))
      .toList(),
  deviceId: json['deviceId'] as String?,
);

Map<String, dynamic> _$MeToJson(Me instance) => <String, dynamic>{
  'staff': instance.staff,
  'permissions': instance.permissions
      .map((e) => _$PermissionKeyEnumMap[e]!)
      .toList(),
  'deviceId': ?instance.deviceId,
};

const _$PermissionKeyEnumMap = {
  PermissionKey.undefined0: 'sale.create',
  PermissionKey.undefined1: 'sale.void_line_before_payment',
  PermissionKey.undefined2: 'sale.void_after_payment',
  PermissionKey.undefined3: 'sale.refund',
  PermissionKey.undefined4: 'sale.discount_within_limit',
  PermissionKey.undefined5: 'sale.discount_over_limit',
  PermissionKey.undefined6: 'cash.open_shift',
  PermissionKey.undefined7: 'cash.close_shift',
  PermissionKey.undefined8: 'cash.movement',
  PermissionKey.undefined9: 'cash.open_drawer_no_sale',
  PermissionKey.undefined10: 'stock.production_entry',
  PermissionKey.undefined11: 'stock.waste',
  PermissionKey.undefined12: 'stock.count_adjust',
  PermissionKey.undefined13: 'stock.transfer',
  PermissionKey.undefined14: 'orders.manage',
  PermissionKey.undefined15: 'orders.pickup',
  PermissionKey.undefined16: 'oven.intake_pickup',
  PermissionKey.undefined17: 'oven.board',
  PermissionKey.undefined18: 'catalog.manage',
  PermissionKey.undefined19: 'catalog.cost',
  PermissionKey.undefined20: 'staff.manage',
  PermissionKey.undefined21: 'devices.manage',
  PermissionKey.undefined22: 'branches.manage',
  PermissionKey.undefined23: 'reports.branch',
  PermissionKey.undefined24: 'reports.all',
  PermissionKey.undefined25: 'audit.view',
  PermissionKey.undefined26: 'settings.manage',
  PermissionKey.$unknown: r'$unknown',
};
