// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';
import 'missed_rule.dart';
import 'order_kind.dart';
import 'order_line_input.dart';
import 'pickup_time.dart';
import 'weekdays.dart';

part 'order_create.g.dart';

@JsonSerializable()
class OrderCreate {
  const OrderCreate({
    required this.weekdays,
    required this.startDate,
    required this.pickupTime,
    required this.missedRule,
    required this.lines,
    required this.customerId,
    required this.branchId,
    required this.kind,
    this.endDate,
    this.note,
  });

  factory OrderCreate.fromJson(Map<String, Object?> json) =>
      _$OrderCreateFromJson(json);

  final Weekdays weekdays;
  final LocalDate startDate;
  final LocalDate? endDate;
  final PickupTime pickupTime;
  final MissedRule missedRule;
  final String? note;
  final List<OrderLineInput> lines;
  final String customerId;
  final String branchId;
  final OrderKind kind;

  Map<String, Object?> toJson() => _$OrderCreateToJson(this);
}
