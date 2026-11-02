// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lines3.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lines3 _$Lines3FromJson(Map<String, dynamic> json) => Lines3(
  variantId: json['variantId'] as String,
  producedOn: json['producedOn'] as LocalDate,
  quantityReceived: (json['quantityReceived'] as num).toInt(),
);

Map<String, dynamic> _$Lines3ToJson(Lines3 instance) => <String, dynamic>{
  'variantId': instance.variantId,
  'producedOn': instance.producedOn,
  'quantityReceived': instance.quantityReceived,
};
