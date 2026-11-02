// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_count_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CashCountRow _$CashCountRowFromJson(Map<String, dynamic> json) => CashCountRow(
  denominationCents: Denomination.fromJson(
    (json['denominationCents'] as num).toInt(),
  ),
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$CashCountRowToJson(CashCountRow instance) =>
    <String, dynamic>{
      'denominationCents': _$DenominationEnumMap[instance.denominationCents]!,
      'quantity': instance.quantity,
    };

const _$DenominationEnumMap = {
  Denomination.value100000: 100000,
  Denomination.value50000: 50000,
  Denomination.value20000: 20000,
  Denomination.value10000: 10000,
  Denomination.value5000: 5000,
  Denomination.value2000: 2000,
  Denomination.value1000: 1000,
  Denomination.value500: 500,
  Denomination.value200: 200,
  Denomination.value100: 100,
  Denomination.value50: 50,
  Denomination.$unknown: r'$unknown',
};
