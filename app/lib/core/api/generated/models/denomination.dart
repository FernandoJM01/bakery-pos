// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Value of a bill or coin in centavos. Bills and coins of the same value share a row.
@JsonEnum()
enum Denomination {
  @JsonValue(100000)
  value100000(100000),
  @JsonValue(50000)
  value50000(50000),
  @JsonValue(20000)
  value20000(20000),
  @JsonValue(10000)
  value10000(10000),
  @JsonValue(5000)
  value5000(5000),
  @JsonValue(2000)
  value2000(2000),
  @JsonValue(1000)
  value1000(1000),
  @JsonValue(500)
  value500(500),
  @JsonValue(200)
  value200(200),
  @JsonValue(100)
  value100(100),
  @JsonValue(50)
  value50(50),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const Denomination(this.json);

  factory Denomination.fromJson(int json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final int? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<Denomination> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
