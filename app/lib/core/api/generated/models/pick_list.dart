// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';
import 'order_ticket.dart';
import 'totals.dart';

part 'pick_list.g.dart';

@JsonSerializable()
class PickList {
  const PickList({
    required this.date,
    required this.totals,
    required this.tickets,
  });

  factory PickList.fromJson(Map<String, Object?> json) =>
      _$PickListFromJson(json);

  final LocalDate date;
  final List<Totals> totals;
  final List<OrderTicket> tickets;

  Map<String, Object?> toJson() => _$PickListToJson(this);
}
