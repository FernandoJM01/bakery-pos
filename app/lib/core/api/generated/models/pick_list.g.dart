// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pick_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickList _$PickListFromJson(Map<String, dynamic> json) => PickList(
  date: json['date'] as LocalDate,
  totals: (json['totals'] as List<dynamic>)
      .map((e) => Totals.fromJson(e as Map<String, dynamic>))
      .toList(),
  tickets: (json['tickets'] as List<dynamic>)
      .map((e) => OrderTicket.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PickListToJson(PickList instance) => <String, dynamic>{
  'date': instance.date,
  'totals': instance.totals,
  'tickets': instance.tickets,
};
