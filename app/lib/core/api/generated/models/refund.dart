// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'refund_kind.dart';
import 'refund_line.dart';
import 'refund_reason.dart';

part 'refund.g.dart';

@JsonSerializable()
class Refund {
  const Refund({
    required this.id,
    required this.kind,
    required this.reason,
    required this.note,
    required this.deviceId,
    required this.staffId,
    required this.approverStaffId,
    required this.occurredAt,
    required this.totalCents,
    required this.lines,
  });

  factory Refund.fromJson(Map<String, Object?> json) => _$RefundFromJson(json);

  final String id;
  final RefundKind kind;
  final RefundReason reason;
  final String? note;
  final String deviceId;
  final String staffId;
  final String? approverStaffId;
  final DateTime occurredAt;
  final AnyCents totalCents;
  final List<RefundLine> lines;

  Map<String, Object?> toJson() => _$RefundToJson(this);
}
