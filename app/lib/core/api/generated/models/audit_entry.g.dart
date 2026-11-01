// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditEntry _$AuditEntryFromJson(Map<String, dynamic> json) => AuditEntry(
  id: json['id'] as String,
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  action: AuditAction.fromJson(json['action'] as String),
  branchId: json['branchId'] as String?,
  deviceId: json['deviceId'] as String?,
  actorStaffId: json['actorStaffId'] as String?,
  approverStaffId: json['approverStaffId'] as String?,
  entityType: json['entityType'] as String?,
  entityId: json['entityId'] as String?,
  data: json['data'],
);

Map<String, dynamic> _$AuditEntryToJson(AuditEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'branchId': ?instance.branchId,
      'deviceId': ?instance.deviceId,
      'actorStaffId': ?instance.actorStaffId,
      'approverStaffId': ?instance.approverStaffId,
      'action': _$AuditActionEnumMap[instance.action]!,
      'entityType': ?instance.entityType,
      'entityId': ?instance.entityId,
      'data': ?instance.data,
    };

const _$AuditActionEnumMap = {
  AuditAction.undefined0: 'auth.login_success',
  AuditAction.undefined1: 'auth.login_failure',
  AuditAction.undefined2: 'auth.locked',
  AuditAction.undefined3: 'auth.logout',
  AuditAction.undefined4: 'auth.approval_granted',
  AuditAction.undefined5: 'auth.approval_denied',
  AuditAction.undefined6: 'staff.created',
  AuditAction.undefined7: 'staff.updated',
  AuditAction.undefined8: 'staff.deactivated',
  AuditAction.undefined9: 'staff.pin_changed',
  AuditAction.undefined10: 'device.created',
  AuditAction.undefined11: 'device.activated',
  AuditAction.undefined12: 'device.revoked',
  AuditAction.undefined13: 'branch.created',
  AuditAction.undefined14: 'branch.updated',
  AuditAction.undefined15: 'catalog.category_created',
  AuditAction.undefined16: 'catalog.category_updated',
  AuditAction.undefined17: 'catalog.product_created',
  AuditAction.undefined18: 'catalog.product_updated',
  AuditAction.undefined19: 'catalog.variant_created',
  AuditAction.undefined20: 'catalog.variant_updated',
  AuditAction.undefined21: 'catalog.price_changed',
  AuditAction.undefined22: 'catalog.branch_price_changed',
  AuditAction.undefined23: 'catalog.tax_rate_created',
  AuditAction.undefined24: 'catalog.tax_rate_updated',
  AuditAction.undefined25: 'sync.quarantine_resolved',
  AuditAction.undefined26: 'sale.discount_over_limit',
  AuditAction.undefined27: 'sale.refunded',
  AuditAction.undefined28: 'sale.voided',
  AuditAction.undefined29: 'sale.ticket_discarded',
  AuditAction.$unknown: r'$unknown',
};
