// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oven_ticket_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvenTicketList _$OvenTicketListFromJson(Map<String, dynamic> json) =>
    OvenTicketList(
      branches: (json['branches'] as List<dynamic>)
          .map((e) => OvenBranchState.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List<dynamic>)
          .map((e) => OvenTicket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OvenTicketListToJson(OvenTicketList instance) =>
    <String, dynamic>{'branches': instance.branches, 'items': instance.items};
