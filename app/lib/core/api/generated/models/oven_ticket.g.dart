// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oven_ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvenTicket _$OvenTicketFromJson(Map<String, dynamic> json) => OvenTicket(
  id: json['id'] as String,
  branchId: json['branchId'] as String,
  tag: json['tag'] as String,
  customerName: json['customerName'] as String,
  phone: json['phone'] as String?,
  description: json['description'] as String,
  ruleId: json['ruleId'] as String,
  weightGrams: (json['weightGrams'] as num).toInt(),
  feeCents: (json['feeCents'] as num).toInt(),
  requestedAt: DateTime.parse(json['requestedAt'] as String),
  status: OvenStatus.fromJson(json['status'] as String),
  receivedAt: DateTime.parse(json['receivedAt'] as String),
  inOvenAt: json['inOvenAt'] == null
      ? null
      : DateTime.parse(json['inOvenAt'] as String),
  readyAt: json['readyAt'] == null
      ? null
      : DateTime.parse(json['readyAt'] as String),
  pickedUpAt: json['pickedUpAt'] == null
      ? null
      : DateTime.parse(json['pickedUpAt'] as String),
  paid: json['paid'] as bool,
);

Map<String, dynamic> _$OvenTicketToJson(OvenTicket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'branchId': instance.branchId,
      'tag': instance.tag,
      'customerName': instance.customerName,
      'phone': ?instance.phone,
      'description': instance.description,
      'ruleId': instance.ruleId,
      'weightGrams': instance.weightGrams,
      'feeCents': instance.feeCents,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'status': _$OvenStatusEnumMap[instance.status]!,
      'receivedAt': instance.receivedAt.toIso8601String(),
      'inOvenAt': ?instance.inOvenAt?.toIso8601String(),
      'readyAt': ?instance.readyAt?.toIso8601String(),
      'pickedUpAt': ?instance.pickedUpAt?.toIso8601String(),
      'paid': instance.paid,
    };

const _$OvenStatusEnumMap = {
  OvenStatus.received: 'RECEIVED',
  OvenStatus.inOven: 'IN_OVEN',
  OvenStatus.ready: 'READY',
  OvenStatus.pickedUp: 'PICKED_UP',
  OvenStatus.$unknown: r'$unknown',
};
