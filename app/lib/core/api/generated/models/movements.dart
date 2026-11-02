// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cash_movement_kind.dart';
import 'cash_movement_reason.dart';

part 'movements.g.dart';

@JsonSerializable()
class Movements {
  const Movements({
    required this.kind,
    required this.reason,
    required this.amountCents,
  });

  factory Movements.fromJson(Map<String, Object?> json) =>
      _$MovementsFromJson(json);

  final CashMovementKind kind;
  final CashMovementReason reason;
  final int amountCents;

  Map<String, Object?> toJson() => _$MovementsToJson(this);
}
