// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lines.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lines _$LinesFromJson(Map<String, dynamic> json) => Lines(
  variantId: json['variantId'] as String,
  counted: (json['counted'] as num).toInt(),
);

Map<String, dynamic> _$LinesToJson(Lines instance) => <String, dynamic>{
  'variantId': instance.variantId,
  'counted': instance.counted,
};
