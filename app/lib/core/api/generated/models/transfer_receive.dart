// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lines3.dart';

part 'transfer_receive.g.dart';

@JsonSerializable()
class TransferReceive {
  const TransferReceive({required this.lines});

  factory TransferReceive.fromJson(Map<String, Object?> json) =>
      _$TransferReceiveFromJson(json);

  /// One row per line of the transfer
  final List<Lines3> lines;

  Map<String, Object?> toJson() => _$TransferReceiveToJson(this);
}
