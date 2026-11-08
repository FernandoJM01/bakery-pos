// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'customer_order.dart';
import 'prepaid_entry.dart';

part 'customer_detail.g.dart';

@JsonSerializable()
class CustomerDetail {
  const CustomerDetail({
    required this.id,
    required this.name,
    required this.phone,
    required this.rfc,
    required this.notes,
    required this.isActive,
    required this.balanceCents,
    required this.orders,
    required this.entries,
  });

  factory CustomerDetail.fromJson(Map<String, Object?> json) =>
      _$CustomerDetailFromJson(json);

  final String id;
  final String name;
  final String? phone;
  final String? rfc;
  final String? notes;
  final bool isActive;

  /// Prepaid balance; negative when the customer owes
  final int balanceCents;
  final List<CustomerOrder> orders;

  /// The last 100, newest first
  final List<PrepaidEntry> entries;

  Map<String, Object?> toJson() => _$CustomerDetailToJson(this);
}
