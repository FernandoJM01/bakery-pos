// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_receive.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferReceive _$TransferReceiveFromJson(Map<String, dynamic> json) =>
    TransferReceive(
      lines: (json['lines'] as List<dynamic>)
          .map((e) => Lines3.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TransferReceiveToJson(TransferReceive instance) =>
    <String, dynamic>{'lines': instance.lines};
