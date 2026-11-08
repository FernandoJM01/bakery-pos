// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oven_board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvenBoard _$OvenBoardFromJson(Map<String, dynamic> json) => OvenBoard(
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  today: json['today'] as LocalDate,
  enabled: json['enabled'] as bool,
  rules: (json['rules'] as List<dynamic>)
      .map((e) => OvenFeeRule.fromJson(e as Map<String, dynamic>))
      .toList(),
  tickets: (json['tickets'] as List<dynamic>)
      .map((e) => OvenTicket.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OvenBoardToJson(OvenBoard instance) => <String, dynamic>{
  'generatedAt': instance.generatedAt.toIso8601String(),
  'today': instance.today,
  'enabled': instance.enabled,
  'rules': instance.rules,
  'tickets': instance.tickets,
};
