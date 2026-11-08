// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';
import 'order_ticket.dart';

part 'branch_tickets.g.dart';

@JsonSerializable()
class BranchTickets {
  const BranchTickets({
    required this.generatedAt,
    required this.today,
    required this.items,
  });

  factory BranchTickets.fromJson(Map<String, Object?> json) =>
      _$BranchTicketsFromJson(json);

  final DateTime generatedAt;
  final LocalDate today;
  final List<OrderTicket> items;

  Map<String, Object?> toJson() => _$BranchTicketsToJson(this);
}
