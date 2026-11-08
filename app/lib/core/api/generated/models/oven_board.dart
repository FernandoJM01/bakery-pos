// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';
import 'oven_fee_rule.dart';
import 'oven_ticket.dart';

part 'oven_board.g.dart';

@JsonSerializable()
class OvenBoard {
  const OvenBoard({
    required this.generatedAt,
    required this.today,
    required this.enabled,
    required this.rules,
    required this.tickets,
  });

  factory OvenBoard.fromJson(Map<String, Object?> json) =>
      _$OvenBoardFromJson(json);

  final DateTime generatedAt;
  final LocalDate today;
  final bool enabled;
  final List<OvenFeeRule> rules;
  final List<OvenTicket> tickets;

  Map<String, Object?> toJson() => _$OvenBoardToJson(this);
}
