// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prepaid_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrepaidEntry _$PrepaidEntryFromJson(Map<String, dynamic> json) => PrepaidEntry(
  id: json['id'] as String,
  kind: PrepaidKind.fromJson(json['kind'] as String),
  amountCents: (json['amountCents'] as num).toInt(),
  ticketId: json['ticketId'] as String?,
  occurredAt: DateTime.parse(json['occurredAt'] as String),
);

Map<String, dynamic> _$PrepaidEntryToJson(PrepaidEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$PrepaidKindEnumMap[instance.kind]!,
      'amountCents': instance.amountCents,
      'ticketId': ?instance.ticketId,
      'occurredAt': instance.occurredAt.toIso8601String(),
    };

const _$PrepaidKindEnumMap = {
  PrepaidKind.payment: 'PAYMENT',
  PrepaidKind.pickup: 'PICKUP',
  PrepaidKind.missed: 'MISSED',
  PrepaidKind.adjustment: 'ADJUSTMENT',
  PrepaidKind.$unknown: r'$unknown',
};
