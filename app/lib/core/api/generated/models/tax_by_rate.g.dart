// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_by_rate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxByRate _$TaxByRateFromJson(Map<String, dynamic> json) => TaxByRate(
  kind: TaxKind.fromJson(json['kind'] as String),
  rateBp: (json['rateBp'] as num).toInt(),
  baseCents: (json['baseCents'] as num).toInt(),
  taxCents: (json['taxCents'] as num).toInt(),
);

Map<String, dynamic> _$TaxByRateToJson(TaxByRate instance) => <String, dynamic>{
  'kind': _$TaxKindEnumMap[instance.kind]!,
  'rateBp': instance.rateBp,
  'baseCents': instance.baseCents,
  'taxCents': instance.taxCents,
};

const _$TaxKindEnumMap = {
  TaxKind.iva: 'IVA',
  TaxKind.ieps: 'IEPS',
  TaxKind.$unknown: r'$unknown',
};
