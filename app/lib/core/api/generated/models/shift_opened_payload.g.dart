// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_opened_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftOpenedPayload _$ShiftOpenedPayloadFromJson(Map<String, dynamic> json) =>
    ShiftOpenedPayload(
      staffId: json['staffId'] as String,
      floatCents: (json['floatCents'] as num).toInt(),
      count: (json['count'] as List<dynamic>)
          .map((e) => CashCountRow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ShiftOpenedPayloadToJson(ShiftOpenedPayload instance) =>
    <String, dynamic>{
      'staffId': instance.staffId,
      'floatCents': instance.floatCents,
      'count': instance.count,
    };
