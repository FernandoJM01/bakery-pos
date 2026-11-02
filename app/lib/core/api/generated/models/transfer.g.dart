// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transfer _$TransferFromJson(Map<String, dynamic> json) => Transfer(
  id: json['id'] as String,
  fromBranchId: json['fromBranchId'] as String,
  toBranchId: json['toBranchId'] as String,
  status: TransferStatus.fromJson(json['status'] as String),
  sentByStaffId: json['sentByStaffId'] as String,
  sentAt: DateTime.parse(json['sentAt'] as String),
  flagged: json['flagged'] as bool,
  lines: (json['lines'] as List<dynamic>)
      .map((e) => TransferLine.fromJson(e as Map<String, dynamic>))
      .toList(),
  receivedByStaffId: json['receivedByStaffId'] as String?,
  receivedAt: json['receivedAt'] == null
      ? null
      : DateTime.parse(json['receivedAt'] as String),
);

Map<String, dynamic> _$TransferToJson(Transfer instance) => <String, dynamic>{
  'id': instance.id,
  'fromBranchId': instance.fromBranchId,
  'toBranchId': instance.toBranchId,
  'status': _$TransferStatusEnumMap[instance.status]!,
  'sentByStaffId': instance.sentByStaffId,
  'sentAt': instance.sentAt.toIso8601String(),
  'receivedByStaffId': ?instance.receivedByStaffId,
  'receivedAt': ?instance.receivedAt?.toIso8601String(),
  'flagged': instance.flagged,
  'lines': instance.lines,
};

const _$TransferStatusEnumMap = {
  TransferStatus.sent: 'SENT',
  TransferStatus.received: 'RECEIVED',
  TransferStatus.$unknown: r'$unknown',
};
