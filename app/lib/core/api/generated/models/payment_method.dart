// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// `PREPAID` is a pickup paid from the customer's balance; tendered and change are 0 (M6 brief 2).
@JsonEnum()
enum PaymentMethod {
  @JsonValue('CASH')
  cash('CASH'),
  @JsonValue('PREPAID')
  prepaid('PREPAID'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const PaymentMethod(this.json);

  factory PaymentMethod.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<PaymentMethod> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
