// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum OfflineAuditPayloadAction {
  /// Incorrect name has been replaced. Original name: `auth.login_success`.
  @JsonValue('auth.login_success')
  undefined0('auth.login_success'),

  /// Incorrect name has been replaced. Original name: `auth.login_failure`.
  @JsonValue('auth.login_failure')
  undefined1('auth.login_failure'),

  /// Incorrect name has been replaced. Original name: `auth.locked`.
  @JsonValue('auth.locked')
  undefined2('auth.locked'),

  /// Incorrect name has been replaced. Original name: `auth.approval_granted`.
  @JsonValue('auth.approval_granted')
  undefined3('auth.approval_granted'),

  /// Incorrect name has been replaced. Original name: `sale.ticket_discarded`.
  @JsonValue('sale.ticket_discarded')
  undefined4('sale.ticket_discarded'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const OfflineAuditPayloadAction(this.json);

  factory OfflineAuditPayloadAction.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<OfflineAuditPayloadAction> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
