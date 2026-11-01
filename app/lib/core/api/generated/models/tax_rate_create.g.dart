// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_rate_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxRateCreate _$TaxRateCreateFromJson(Map<String, dynamic> json) =>
    TaxRateCreate(
      kind: TaxKind.fromJson(json['kind'] as String),
      name: json['name'] as String,
      rateBp: (json['rateBp'] as num).toInt(),
    );

Map<String, dynamic> _$TaxRateCreateToJson(TaxRateCreate instance) =>
    <String, dynamic>{
      'kind': _$TaxKindEnumMap[instance.kind]!,
      'name': instance.name,
      'rateBp': instance.rateBp,
    };

const _$TaxKindEnumMap = {
  TaxKind.iva: 'IVA',
  TaxKind.ieps: 'IEPS',
  TaxKind.$unknown: r'$unknown',
};
