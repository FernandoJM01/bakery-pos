// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'balances.g.dart';

@JsonSerializable()
class Balances {
  const Balances({
    required this.customerId,
    required this.name,
    required this.phone,
    required this.balanceCents,
  });

  factory Balances.fromJson(Map<String, Object?> json) =>
      _$BalancesFromJson(json);

  final String customerId;
  final String name;
  final String? phone;
  final int balanceCents;

  Map<String, Object?> toJson() => _$BalancesToJson(this);
}
