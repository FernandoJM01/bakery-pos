// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';
import 'missed_rule.dart';
import 'order_line_input.dart';
import 'pickup_time.dart';
import 'weekdays.dart';

part 'order_update.g.dart';

@JsonSerializable()
class OrderUpdate {
  const OrderUpdate({
    required this.weekdays,
    required this.startDate,
    required this.pickupTime,
    required this.missedRule,
    required this.lines,
    this.endDate,
    this.note,
  });

  factory OrderUpdate.fromJson(Map<String, Object?> json) =>
      _$OrderUpdateFromJson(json);

  final Weekdays weekdays;
  final LocalDate startDate;
  final LocalDate? endDate;
  final PickupTime pickupTime;
  final MissedRule missedRule;
  final String? note;
  final List<OrderLineInput> lines;

  Map<String, Object?> toJson() => _$OrderUpdateToJson(this);
}
