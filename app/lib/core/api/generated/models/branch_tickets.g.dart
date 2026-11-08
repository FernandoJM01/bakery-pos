// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_tickets.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchTickets _$BranchTicketsFromJson(Map<String, dynamic> json) =>
    BranchTickets(
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      today: json['today'] as LocalDate,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderTicket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BranchTicketsToJson(BranchTickets instance) =>
    <String, dynamic>{
      'generatedAt': instance.generatedAt.toIso8601String(),
      'today': instance.today,
      'items': instance.items,
    };
