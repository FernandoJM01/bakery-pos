// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_movement_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CashMovementPayload _$CashMovementPayloadFromJson(Map<String, dynamic> json) =>
    CashMovementPayload(
      shiftId: json['shiftId'] as String,
      kind: CashMovementKind.fromJson(json['kind'] as String),
      amountCents: (json['amountCents'] as num).toInt(),
      reason: CashMovementReason.fromJson(json['reason'] as String),
      staffId: json['staffId'] as String,
      note: json['note'] as String?,
      approverStaffId: json['approverStaffId'] as String?,
    );

Map<String, dynamic> _$CashMovementPayloadToJson(
  CashMovementPayload instance,
) => <String, dynamic>{
  'shiftId': instance.shiftId,
  'kind': _$CashMovementKindEnumMap[instance.kind]!,
  'amountCents': instance.amountCents,
  'reason': _$CashMovementReasonEnumMap[instance.reason]!,
  'note': ?instance.note,
  'staffId': instance.staffId,
  'approverStaffId': ?instance.approverStaffId,
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
