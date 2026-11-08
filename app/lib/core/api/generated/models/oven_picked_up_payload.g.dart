// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oven_picked_up_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvenPickedUpPayload _$OvenPickedUpPayloadFromJson(Map<String, dynamic> json) =>
    OvenPickedUpPayload(
      ticketId: json['ticketId'] as String,
      staffId: json['staffId'] as String,
      feeSaleId: json['feeSaleId'] as String?,
    );

Map<String, dynamic> _$OvenPickedUpPayloadToJson(
  OvenPickedUpPayload instance,
) => <String, dynamic>{
  'ticketId': instance.ticketId,
  'staffId': instance.staffId,
  'feeSaleId': ?instance.feeSaleId,
};
