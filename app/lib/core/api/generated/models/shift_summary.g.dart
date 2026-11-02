// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftSummary _$ShiftSummaryFromJson(Map<String, dynamic> json) => ShiftSummary(
  id: json['id'] as String,
  branchId: json['branchId'] as String,
  deviceId: json['deviceId'] as String,
  status: ShiftStatus.fromJson(json['status'] as String),
  openedAt: DateTime.parse(json['openedAt'] as String),
  openedByStaffId: json['openedByStaffId'] as String,
  openedByName: json['openedByName'] as String,
  floatCents: (json['floatCents'] as num).toInt(),
  flagged: json['flagged'] as bool,
  zNumber: (json['zNumber'] as num?)?.toInt(),
  zLabel: json['zLabel'] as String?,
  closedAt: json['closedAt'] == null
      ? null
      : DateTime.parse(json['closedAt'] as String),
  closedByStaffId: json['closedByStaffId'] as String?,
  closedByName: json['closedByName'] as String?,
  expectedCents: (json['expectedCents'] as num?)?.toInt(),
  countedCents: (json['countedCents'] as num?)?.toInt(),
  varianceCents: (json['varianceCents'] as num?)?.toInt(),
);

Map<String, dynamic> _$ShiftSummaryToJson(ShiftSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'branchId': instance.branchId,
      'deviceId': instance.deviceId,
      'status': _$ShiftStatusEnumMap[instance.status]!,
      'zNumber': ?instance.zNumber,
      'zLabel': ?instance.zLabel,
      'openedAt': instance.openedAt.toIso8601String(),
      'openedByStaffId': instance.openedByStaffId,
      'openedByName': instance.openedByName,
      'closedAt': ?instance.closedAt?.toIso8601String(),
      'closedByStaffId': ?instance.closedByStaffId,
      'closedByName': ?instance.closedByName,
      'floatCents': instance.floatCents,
      'expectedCents': ?instance.expectedCents,
      'countedCents': ?instance.countedCents,
      'varianceCents': ?instance.varianceCents,
      'flagged': instance.flagged,
    };

const _$ShiftStatusEnumMap = {
  ShiftStatus.open: 'OPEN',
  ShiftStatus.closed: 'CLOSED',
  ShiftStatus.$unknown: r'$unknown',
};
