// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'local_date.dart';
import 'order_ticket_line.dart';
import 'pickup_time.dart';
import 'ticket_status.dart';

part 'order_ticket.g.dart';

/// One due day of an order, priced the day it was made. A pickup sale must copy its lines (M6 brief 4.4).
@JsonSerializable()
class OrderTicket {
  const OrderTicket({
    required this.id,
    required this.orderId,
    required this.branchId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.balanceCents,
    required this.dueDate,
    required this.pickupTime,
    required this.status,
    required this.totalCents,
    required this.saleId,
    required this.lines,
  });

  factory OrderTicket.fromJson(Map<String, Object?> json) =>
      _$OrderTicketFromJson(json);

  final String id;
  final String orderId;
  final String branchId;
  final String customerId;
  final String customerName;
  final String? customerPhone;

  /// The customer's balance when this was read
  final int balanceCents;
  final LocalDate dueDate;
  final PickupTime pickupTime;
  final TicketStatus status;
  final AnyCents totalCents;
  final String? saleId;
  final List<OrderTicketLine> lines;

  Map<String, Object?> toJson() => _$OrderTicketToJson(this);
}
