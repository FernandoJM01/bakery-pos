// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movements.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movements _$MovementsFromJson(Map<String, dynamic> json) => Movements(
  kind: CashMovementKind.fromJson(json['kind'] as String),
  reason: CashMovementReason.fromJson(json['reason'] as String),
  amountCents: (json['amountCents'] as num).toInt(),
);

Map<String, dynamic> _$MovementsToJson(Movements instance) => <String, dynamic>{
  'kind': _$CashMovementKindEnumMap[instance.kind]!,
  'reason': _$CashMovementReasonEnumMap[instance.reason]!,
  'amountCents': instance.amountCents,
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
