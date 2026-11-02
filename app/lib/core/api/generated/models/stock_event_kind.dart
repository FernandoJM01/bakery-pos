// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum StockEventKind {
  @JsonValue('PRODUCTION')
  production('PRODUCTION'),
  @JsonValue('SALE')
  sale('SALE'),
  @JsonValue('REFUND_RETURN')
  refundReturn('REFUND_RETURN'),
  @JsonValue('WASTE')
  waste('WASTE'),
  @JsonValue('TRANSFER_OUT')
  transferOut('TRANSFER_OUT'),
  @JsonValue('TRANSFER_IN')
  transferIn('TRANSFER_IN'),
  @JsonValue('COUNT_ADJUST')
  countAdjust('COUNT_ADJUST'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const StockEventKind(this.json);

  factory StockEventKind.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<StockEventKind> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
