// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oven_status_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvenStatusPayload _$OvenStatusPayloadFromJson(Map<String, dynamic> json) =>
    OvenStatusPayload(
      ticketId: json['ticketId'] as String,
      status: OvenStatusPayloadStatus.fromJson(json['status'] as String),
      staffId: json['staffId'] as String,
    );

Map<String, dynamic> _$OvenStatusPayloadToJson(OvenStatusPayload instance) =>
    <String, dynamic>{
      'ticketId': instance.ticketId,
      'status': _$OvenStatusPayloadStatusEnumMap[instance.status]!,
      'staffId': instance.staffId,
    };

const _$OvenStatusPayloadStatusEnumMap = {
  OvenStatusPayloadStatus.inOven: 'IN_OVEN',
  OvenStatusPayloadStatus.ready: 'READY',
  OvenStatusPayloadStatus.$unknown: r'$unknown',
};
