// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tickets.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tickets _$TicketsFromJson(Map<String, dynamic> json) => Tickets(
  date: json['date'] as LocalDate,
  status: TicketStatus.fromJson(json['status'] as String),
  count: (json['count'] as num).toInt(),
  totalCents: (json['totalCents'] as num).toInt(),
);

Map<String, dynamic> _$TicketsToJson(Tickets instance) => <String, dynamic>{
  'date': instance.date,
  'status': _$TicketStatusEnumMap[instance.status]!,
  'count': instance.count,
  'totalCents': instance.totalCents,
};

const _$TicketStatusEnumMap = {
  TicketStatus.pending: 'PENDING',
  TicketStatus.pickedUp: 'PICKED_UP',
  TicketStatus.missed: 'MISSED',
  TicketStatus.skipped: 'SKIPPED',
  TicketStatus.$unknown: r'$unknown',
};
