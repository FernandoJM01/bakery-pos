// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oven_received_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvenReceivedPayload _$OvenReceivedPayloadFromJson(Map<String, dynamic> json) =>
    OvenReceivedPayload(
      tag: json['tag'] as String,
      customerName: json['customerName'] as String,
      description: json['description'] as String,
      ruleId: json['ruleId'] as String,
      weightGrams: (json['weightGrams'] as num).toInt(),
      feeCents: (json['feeCents'] as num).toInt(),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      staffId: json['staffId'] as String,
      phone: json['phone'] as String?,
      feeSaleId: json['feeSaleId'] as String?,
    );

Map<String, dynamic> _$OvenReceivedPayloadToJson(
  OvenReceivedPayload instance,
) => <String, dynamic>{
  'tag': instance.tag,
  'customerName': instance.customerName,
  'phone': ?instance.phone,
  'description': instance.description,
  'ruleId': instance.ruleId,
  'weightGrams': instance.weightGrams,
  'feeCents': instance.feeCents,
  'requestedAt': instance.requestedAt.toIso8601String(),
  'staffId': instance.staffId,
  'feeSaleId': ?instance.feeSaleId,
};
