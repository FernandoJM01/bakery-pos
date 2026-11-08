// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'prepaid_kind.dart';

part 'prepaid_entry.g.dart';

@JsonSerializable()
class PrepaidEntry {
  const PrepaidEntry({
    required this.id,
    required this.kind,
    required this.amountCents,
    required this.ticketId,
    required this.occurredAt,
  });

  factory PrepaidEntry.fromJson(Map<String, Object?> json) =>
      _$PrepaidEntryFromJson(json);

  final String id;
  final PrepaidKind kind;

  /// Signed
  final int amountCents;
  final String? ticketId;
  final DateTime occurredAt;

  Map<String, Object?> toJson() => _$PrepaidEntryToJson(this);
}
