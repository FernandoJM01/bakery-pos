// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'oven_status.dart';

part 'oven_ticket.g.dart';

@JsonSerializable()
class OvenTicket {
  const OvenTicket({
    required this.id,
    required this.branchId,
    required this.tag,
    required this.customerName,
    required this.phone,
    required this.description,
    required this.ruleId,
    required this.weightGrams,
    required this.feeCents,
    required this.requestedAt,
    required this.status,
    required this.receivedAt,
    required this.inOvenAt,
    required this.readyAt,
    required this.pickedUpAt,
    required this.paid,
  });

  factory OvenTicket.fromJson(Map<String, Object?> json) =>
      _$OvenTicketFromJson(json);

  final String id;
  final String branchId;
  final String tag;
  final String customerName;
  final String? phone;
  final String description;
  final String ruleId;
  final int weightGrams;
  final AnyCents feeCents;
  final DateTime requestedAt;
  final OvenStatus status;
  final DateTime receivedAt;
  final DateTime? inOvenAt;

  /// The actual ready time, for the customer (M8.3)
  final DateTime? readyAt;
  final DateTime? pickedUpAt;
  final bool paid;

  Map<String, Object?> toJson() => _$OvenTicketToJson(this);
}
