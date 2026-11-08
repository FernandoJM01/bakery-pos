// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';
import 'ticket_status.dart';

part 'tickets.g.dart';

@JsonSerializable()
class Tickets {
  const Tickets({
    required this.date,
    required this.status,
    required this.count,
    required this.totalCents,
  });

  factory Tickets.fromJson(Map<String, Object?> json) =>
      _$TicketsFromJson(json);

  final LocalDate date;
  final TicketStatus status;
  final int count;
  final int totalCents;

  Map<String, Object?> toJson() => _$TicketsToJson(this);
}
