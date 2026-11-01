// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum AuditAction {
  /// Incorrect name has been replaced. Original name: `auth.login_success`.
  @JsonValue('auth.login_success')
  undefined0('auth.login_success'),

  /// Incorrect name has been replaced. Original name: `auth.login_failure`.
  @JsonValue('auth.login_failure')
  undefined1('auth.login_failure'),

  /// Incorrect name has been replaced. Original name: `auth.locked`.
  @JsonValue('auth.locked')
  undefined2('auth.locked'),

  /// Incorrect name has been replaced. Original name: `auth.logout`.
  @JsonValue('auth.logout')
  undefined3('auth.logout'),

  /// Incorrect name has been replaced. Original name: `auth.approval_granted`.
  @JsonValue('auth.approval_granted')
  undefined4('auth.approval_granted'),

  /// Incorrect name has been replaced. Original name: `auth.approval_denied`.
  @JsonValue('auth.approval_denied')
  undefined5('auth.approval_denied'),

  /// Incorrect name has been replaced. Original name: `staff.created`.
  @JsonValue('staff.created')
  undefined6('staff.created'),

  /// Incorrect name has been replaced. Original name: `staff.updated`.
  @JsonValue('staff.updated')
  undefined7('staff.updated'),

  /// Incorrect name has been replaced. Original name: `staff.deactivated`.
  @JsonValue('staff.deactivated')
  undefined8('staff.deactivated'),

  /// Incorrect name has been replaced. Original name: `staff.pin_changed`.
  @JsonValue('staff.pin_changed')
  undefined9('staff.pin_changed'),

  /// Incorrect name has been replaced. Original name: `device.created`.
  @JsonValue('device.created')
  undefined10('device.created'),

  /// Incorrect name has been replaced. Original name: `device.activated`.
  @JsonValue('device.activated')
  undefined11('device.activated'),

  /// Incorrect name has been replaced. Original name: `device.revoked`.
  @JsonValue('device.revoked')
  undefined12('device.revoked'),

  /// Incorrect name has been replaced. Original name: `branch.created`.
  @JsonValue('branch.created')
  undefined13('branch.created'),

  /// Incorrect name has been replaced. Original name: `branch.updated`.
  @JsonValue('branch.updated')
  undefined14('branch.updated'),

  /// Incorrect name has been replaced. Original name: `catalog.category_created`.
  @JsonValue('catalog.category_created')
  undefined15('catalog.category_created'),

  /// Incorrect name has been replaced. Original name: `catalog.category_updated`.
  @JsonValue('catalog.category_updated')
  undefined16('catalog.category_updated'),

  /// Incorrect name has been replaced. Original name: `catalog.product_created`.
  @JsonValue('catalog.product_created')
  undefined17('catalog.product_created'),

  /// Incorrect name has been replaced. Original name: `catalog.product_updated`.
  @JsonValue('catalog.product_updated')
  undefined18('catalog.product_updated'),

  /// Incorrect name has been replaced. Original name: `catalog.variant_created`.
  @JsonValue('catalog.variant_created')
  undefined19('catalog.variant_created'),

  /// Incorrect name has been replaced. Original name: `catalog.variant_updated`.
  @JsonValue('catalog.variant_updated')
  undefined20('catalog.variant_updated'),

  /// Incorrect name has been replaced. Original name: `catalog.price_changed`.
  @JsonValue('catalog.price_changed')
  undefined21('catalog.price_changed'),

  /// Incorrect name has been replaced. Original name: `catalog.branch_price_changed`.
  @JsonValue('catalog.branch_price_changed')
  undefined22('catalog.branch_price_changed'),

  /// Incorrect name has been replaced. Original name: `catalog.tax_rate_created`.
  @JsonValue('catalog.tax_rate_created')
  undefined23('catalog.tax_rate_created'),

  /// Incorrect name has been replaced. Original name: `catalog.tax_rate_updated`.
  @JsonValue('catalog.tax_rate_updated')
  undefined24('catalog.tax_rate_updated'),

  /// Incorrect name has been replaced. Original name: `sync.quarantine_resolved`.
  @JsonValue('sync.quarantine_resolved')
  undefined25('sync.quarantine_resolved'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const AuditAction(this.json);

  factory AuditAction.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<AuditAction> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
