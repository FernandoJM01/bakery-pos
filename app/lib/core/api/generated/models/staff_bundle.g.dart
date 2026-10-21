// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffBundle _$StaffBundleFromJson(Map<String, dynamic> json) => StaffBundle(
  branchId: json['branchId'] as String,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  staff: (json['staff'] as List<dynamic>)
      .map((e) => StaffBundleEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  roles: (json['roles'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => PermissionKey.fromJson(e as String))
          .toList(),
    ),
  ),
);

Map<String, dynamic> _$StaffBundleToJson(StaffBundle instance) =>
    <String, dynamic>{
      'branchId': instance.branchId,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'staff': instance.staff,
      'roles': instance.roles.map(
        (k, e) =>
            MapEntry(k, e.map((e) => _$PermissionKeyEnumMap[e]!).toList()),
      ),
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
  PermissionKey.undefined19: 'staff.manage',
  PermissionKey.undefined20: 'devices.manage',
  PermissionKey.undefined21: 'branches.manage',
  PermissionKey.undefined22: 'reports.branch',
  PermissionKey.undefined23: 'reports.all',
  PermissionKey.undefined24: 'audit.view',
  PermissionKey.undefined25: 'settings.manage',
  PermissionKey.$unknown: r'$unknown',
};
