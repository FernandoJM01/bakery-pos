// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'ticket.g.dart';

@JsonSerializable()
class Ticket {
  const Ticket({required this.lineCount, required this.amountCents});

  factory Ticket.fromJson(Map<String, Object?> json) => _$TicketFromJson(json);

  final int lineCount;
  final int amountCents;

  Map<String, Object?> toJson() => _$TicketToJson(this);
}
