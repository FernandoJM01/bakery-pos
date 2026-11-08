// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum SalesGroup {
  @JsonValue('day')
  day('day'),
  @JsonValue('hour')
  hour('hour'),
  @JsonValue('branch')
  branch('branch'),
  @JsonValue('device')
  device('device'),
  @JsonValue('cashier')
  cashier('cashier'),
  @JsonValue('product')
  product('product'),
  @JsonValue('taxRate')
  taxRate('taxRate'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const SalesGroup(this.json);

  factory SalesGroup.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<SalesGroup> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
