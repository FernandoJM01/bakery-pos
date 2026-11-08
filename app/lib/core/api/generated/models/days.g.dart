// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'days.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Days _$DaysFromJson(Map<String, dynamic> json) => Days(
  date: json['date'] as LocalDate,
  netCents: (json['netCents'] as num).toInt(),
  saleCount: (json['saleCount'] as num).toInt(),
);

Map<String, dynamic> _$DaysToJson(Days instance) => <String, dynamic>{
  'date': instance.date,
  'netCents': instance.netCents,
  'saleCount': instance.saleCount,
};
