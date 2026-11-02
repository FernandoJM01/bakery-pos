// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_audit_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfflineAuditPayload _$OfflineAuditPayloadFromJson(Map<String, dynamic> json) =>
    OfflineAuditPayload(
      action: OfflineAuditPayloadAction.fromJson(json['action'] as String),
      staffId: json['staffId'] as String,
      approverStaffId: json['approverStaffId'] as String?,
      approvalAction: json['approvalAction'] as String?,
      reference: json['reference'] as String?,
      ticket: json['ticket'] == null
          ? null
          : Ticket.fromJson(json['ticket'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OfflineAuditPayloadToJson(
  OfflineAuditPayload instance,
) => <String, dynamic>{
  'action': _$OfflineAuditPayloadActionEnumMap[instance.action]!,
  'staffId': instance.staffId,
  'approverStaffId': ?instance.approverStaffId,
  'approvalAction': ?instance.approvalAction,
  'reference': ?instance.reference,
  'ticket': ?instance.ticket,
};

const _$OfflineAuditPayloadActionEnumMap = {
  OfflineAuditPayloadAction.undefined0: 'auth.login_success',
  OfflineAuditPayloadAction.undefined1: 'auth.login_failure',
  OfflineAuditPayloadAction.undefined2: 'auth.locked',
  OfflineAuditPayloadAction.undefined3: 'auth.approval_granted',
  OfflineAuditPayloadAction.undefined4: 'sale.ticket_discarded',
  OfflineAuditPayloadAction.undefined5: 'cash.drawer_opened',
  OfflineAuditPayloadAction.$unknown: r'$unknown',
};
