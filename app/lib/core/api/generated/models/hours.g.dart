// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hours.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hours _$HoursFromJson(Map<String, dynamic> json) => Hours(
  hour: (json['hour'] as num).toInt(),
  netCents: (json['netCents'] as num).toInt(),
  saleCount: (json['saleCount'] as num).toInt(),
);

Map<String, dynamic> _$HoursToJson(Hours instance) => <String, dynamic>{
  'hour': instance.hour,
  'netCents': instance.netCents,
  'saleCount': instance.saleCount,
};
