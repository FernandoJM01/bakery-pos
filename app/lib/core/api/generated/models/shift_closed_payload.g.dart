// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_closed_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftClosedPayload _$ShiftClosedPayloadFromJson(Map<String, dynamic> json) =>
    ShiftClosedPayload(
      shiftId: json['shiftId'] as String,
      zNumber: (json['zNumber'] as num).toInt(),
      staffId: json['staffId'] as String,
      count: (json['count'] as List<dynamic>)
          .map((e) => CashCountRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      countedCents: (json['countedCents'] as num).toInt(),
      expectedCents: (json['expectedCents'] as num).toInt(),
      varianceCents: (json['varianceCents'] as num).toInt(),
      flagged: json['flagged'] as bool,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$ShiftClosedPayloadToJson(ShiftClosedPayload instance) =>
    <String, dynamic>{
      'shiftId': instance.shiftId,
      'zNumber': instance.zNumber,
      'staffId': instance.staffId,
      'count': instance.count,
      'countedCents': instance.countedCents,
      'expectedCents': instance.expectedCents,
      'varianceCents': instance.varianceCents,
      'flagged': instance.flagged,
      'note': ?instance.note,
    };
