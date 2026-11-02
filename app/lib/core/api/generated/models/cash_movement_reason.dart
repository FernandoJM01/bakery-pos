// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum CashMovementReason {
  @JsonValue('CHANGE_FUND')
  changeFund('CHANGE_FUND'),
  @JsonValue('SUPPLIER_PAYMENT')
  supplierPayment('SUPPLIER_PAYMENT'),
  @JsonValue('BANK_DROP')
  bankDrop('BANK_DROP'),
  @JsonValue('OTHER')
  other('OTHER'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const CashMovementReason(this.json);

  factory CashMovementReason.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<CashMovementReason> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
