// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'transfer_line.dart';
import 'transfer_status.dart';

part 'transfer.g.dart';

@JsonSerializable()
class Transfer {
  const Transfer({
    required this.id,
    required this.fromBranchId,
    required this.toBranchId,
    required this.status,
    required this.sentByStaffId,
    required this.sentAt,
    required this.flagged,
    required this.lines,
    this.receivedByStaffId,
    this.receivedAt,
  });

  factory Transfer.fromJson(Map<String, Object?> json) =>
      _$TransferFromJson(json);

  final String id;
  final String fromBranchId;
  final String toBranchId;
  final TransferStatus status;
  final String sentByStaffId;
  final DateTime sentAt;
  final String? receivedByStaffId;
  final DateTime? receivedAt;
  final bool flagged;
  final List<TransferLine> lines;

  Map<String, Object?> toJson() => _$TransferToJson(this);
}
