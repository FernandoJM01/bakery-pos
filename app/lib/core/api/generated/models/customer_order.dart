// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lines4.dart';
import 'local_date.dart';
import 'missed_rule.dart';
import 'order_kind.dart';
import 'order_status.dart';
import 'pickup_time.dart';
import 'weekdays.dart';

part 'customer_order.g.dart';

@JsonSerializable()
class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.branchId,
    required this.kind,
    required this.weekdays,
    required this.startDate,
    required this.endDate,
    required this.pickupTime,
    required this.missedRule,
    required this.status,
    required this.pausedFrom,
    required this.pausedUntil,
    required this.note,
    required this.lines,
    required this.skips,
  });

  factory CustomerOrder.fromJson(Map<String, Object?> json) =>
      _$CustomerOrderFromJson(json);

  final String id;
  final String customerId;
  final String customerName;
  final String branchId;
  final OrderKind kind;
  final Weekdays weekdays;
  final LocalDate startDate;
  final LocalDate? endDate;
  final PickupTime pickupTime;
  final MissedRule missedRule;
  final OrderStatus status;
  final LocalDate? pausedFrom;
  final LocalDate? pausedUntil;
  final String? note;
  final List<Lines4> lines;
  final List<LocalDate> skips;

  Map<String, Object?> toJson() => _$CustomerOrderToJson(this);
}
