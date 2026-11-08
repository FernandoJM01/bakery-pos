// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderTicket _$OrderTicketFromJson(Map<String, dynamic> json) => OrderTicket(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  branchId: json['branchId'] as String,
  customerId: json['customerId'] as String,
  customerName: json['customerName'] as String,
  customerPhone: json['customerPhone'] as String?,
  balanceCents: (json['balanceCents'] as num).toInt(),
  dueDate: json['dueDate'] as LocalDate,
  pickupTime: json['pickupTime'] as PickupTime,
  status: TicketStatus.fromJson(json['status'] as String),
  totalCents: (json['totalCents'] as num).toInt(),
  saleId: json['saleId'] as String?,
  lines: (json['lines'] as List<dynamic>)
      .map((e) => OrderTicketLine.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OrderTicketToJson(OrderTicket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'branchId': instance.branchId,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'customerPhone': ?instance.customerPhone,
      'balanceCents': instance.balanceCents,
      'dueDate': instance.dueDate,
      'pickupTime': instance.pickupTime,
      'status': _$TicketStatusEnumMap[instance.status]!,
      'totalCents': instance.totalCents,
      'saleId': ?instance.saleId,
      'lines': instance.lines,
    };

const _$TicketStatusEnumMap = {
  TicketStatus.pending: 'PENDING',
  TicketStatus.pickedUp: 'PICKED_UP',
  TicketStatus.missed: 'MISSED',
  TicketStatus.skipped: 'SKIPPED',
  TicketStatus.$unknown: r'$unknown',
};
