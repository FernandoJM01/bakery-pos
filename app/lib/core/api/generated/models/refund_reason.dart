// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum RefundReason {
  @JsonValue('CUSTOMER_RETURN')
  customerReturn('CUSTOMER_RETURN'),
  @JsonValue('WRONG_ITEM')
  wrongItem('WRONG_ITEM'),
  @JsonValue('QUALITY')
  quality('QUALITY'),
  @JsonValue('CASHIER_ERROR')
  cashierError('CASHIER_ERROR'),
  @JsonValue('OTHER')
  other('OTHER'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const RefundReason(this.json);

  factory RefundReason.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<RefundReason> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
