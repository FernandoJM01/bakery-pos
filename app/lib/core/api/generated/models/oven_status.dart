// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum OvenStatus {
  @JsonValue('RECEIVED')
  received('RECEIVED'),
  @JsonValue('IN_OVEN')
  inOven('IN_OVEN'),
  @JsonValue('READY')
  ready('READY'),
  @JsonValue('PICKED_UP')
  pickedUp('PICKED_UP'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const OvenStatus(this.json);

  factory OvenStatus.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<OvenStatus> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
