// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferCreate _$TransferCreateFromJson(Map<String, dynamic> json) =>
    TransferCreate(
      fromBranchId: json['fromBranchId'] as String,
      toBranchId: json['toBranchId'] as String,
      lines: (json['lines'] as List<dynamic>)
          .map((e) => Lines2.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TransferCreateToJson(TransferCreate instance) =>
    <String, dynamic>{
      'fromBranchId': instance.fromBranchId,
      'toBranchId': instance.toBranchId,
      'lines': instance.lines,
    };
