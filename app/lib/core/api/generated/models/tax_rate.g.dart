// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_rate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxRate _$TaxRateFromJson(Map<String, dynamic> json) => TaxRate(
  id: json['id'] as String,
  kind: TaxKind.fromJson(json['kind'] as String),
  name: json['name'] as String,
  rateBp: (json['rateBp'] as num).toInt(),
  isActive: json['isActive'] as bool,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TaxRateToJson(TaxRate instance) => <String, dynamic>{
  'id': instance.id,
  'kind': _$TaxKindEnumMap[instance.kind]!,
  'name': instance.name,
  'rateBp': instance.rateBp,
  'isActive': instance.isActive,
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$TaxKindEnumMap = {
  TaxKind.iva: 'IVA',
  TaxKind.ieps: 'IEPS',
  TaxKind.$unknown: r'$unknown',
};
