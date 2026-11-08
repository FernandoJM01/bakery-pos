// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'customer.g.dart';

@JsonSerializable()
class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.rfc,
    required this.notes,
    required this.isActive,
    required this.balanceCents,
  });

  factory Customer.fromJson(Map<String, Object?> json) =>
      _$CustomerFromJson(json);

  final String id;
  final String name;
  final String? phone;
  final String? rfc;
  final String? notes;
  final bool isActive;

  /// Prepaid balance; negative when the customer owes
  final int balanceCents;

  Map<String, Object?> toJson() => _$CustomerToJson(this);
}
