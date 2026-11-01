// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CashMovement _$CashMovementFromJson(Map<String, dynamic> json) => CashMovement(
  id: json['id'] as String,
  kind: CashMovementKind.fromJson(json['kind'] as String),
  amountCents: (json['amountCents'] as num).toInt(),
  reason: CashMovementReason.fromJson(json['reason'] as String),
  staffId: json['staffId'] as String,
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  note: json['note'] as String?,
  approverStaffId: json['approverStaffId'] as String?,
);

Map<String, dynamic> _$CashMovementToJson(CashMovement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$CashMovementKindEnumMap[instance.kind]!,
      'amountCents': instance.amountCents,
      'reason': _$CashMovementReasonEnumMap[instance.reason]!,
      'note': ?instance.note,
      'staffId': instance.staffId,
      'approverStaffId': ?instance.approverStaffId,
      'occurredAt': instance.occurredAt.toIso8601String(),
    };

const _$CashMovementKindEnumMap = {
  CashMovementKind.valueIn: 'IN',
  CashMovementKind.out: 'OUT',
  CashMovementKind.$unknown: r'$unknown',
};

const _$CashMovementReasonEnumMap = {
  CashMovementReason.changeFund: 'CHANGE_FUND',
  CashMovementReason.supplierPayment: 'SUPPLIER_PAYMENT',
  CashMovementReason.bankDrop: 'BANK_DROP',
  CashMovementReason.other: 'OTHER',
  CashMovementReason.$unknown: r'$unknown',
};
