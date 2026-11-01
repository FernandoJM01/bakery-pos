// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
  lineCount: (json['lineCount'] as num).toInt(),
  amountCents: (json['amountCents'] as num).toInt(),
);

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
  'lineCount': instance.lineCount,
  'amountCents': instance.amountCents,
};
