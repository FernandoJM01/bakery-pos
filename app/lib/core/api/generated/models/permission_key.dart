// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum PermissionKey {
  /// Incorrect name has been replaced. Original name: `sale.create`.
  @JsonValue('sale.create')
  undefined0('sale.create'),

  /// Incorrect name has been replaced. Original name: `sale.void_line_before_payment`.
  @JsonValue('sale.void_line_before_payment')
  undefined1('sale.void_line_before_payment'),

  /// Incorrect name has been replaced. Original name: `sale.void_after_payment`.
  @JsonValue('sale.void_after_payment')
  undefined2('sale.void_after_payment'),

  /// Incorrect name has been replaced. Original name: `sale.refund`.
  @JsonValue('sale.refund')
  undefined3('sale.refund'),

  /// Incorrect name has been replaced. Original name: `sale.discount_within_limit`.
  @JsonValue('sale.discount_within_limit')
  undefined4('sale.discount_within_limit'),

  /// Incorrect name has been replaced. Original name: `sale.discount_over_limit`.
  @JsonValue('sale.discount_over_limit')
  undefined5('sale.discount_over_limit'),

  /// Incorrect name has been replaced. Original name: `cash.open_shift`.
  @JsonValue('cash.open_shift')
  undefined6('cash.open_shift'),

  /// Incorrect name has been replaced. Original name: `cash.close_shift`.
  @JsonValue('cash.close_shift')
  undefined7('cash.close_shift'),

  /// Incorrect name has been replaced. Original name: `cash.movement`.
  @JsonValue('cash.movement')
  undefined8('cash.movement'),

  /// Incorrect name has been replaced. Original name: `cash.open_drawer_no_sale`.
  @JsonValue('cash.open_drawer_no_sale')
  undefined9('cash.open_drawer_no_sale'),

  /// Incorrect name has been replaced. Original name: `stock.production_entry`.
  @JsonValue('stock.production_entry')
  undefined10('stock.production_entry'),

  /// Incorrect name has been replaced. Original name: `stock.waste`.
  @JsonValue('stock.waste')
  undefined11('stock.waste'),

  /// Incorrect name has been replaced. Original name: `stock.count_adjust`.
  @JsonValue('stock.count_adjust')
  undefined12('stock.count_adjust'),

  /// Incorrect name has been replaced. Original name: `stock.transfer`.
  @JsonValue('stock.transfer')
  undefined13('stock.transfer'),

  /// Incorrect name has been replaced. Original name: `orders.manage`.
  @JsonValue('orders.manage')
  undefined14('orders.manage'),

  /// Incorrect name has been replaced. Original name: `orders.pickup`.
  @JsonValue('orders.pickup')
  undefined15('orders.pickup'),

  /// Incorrect name has been replaced. Original name: `oven.intake_pickup`.
  @JsonValue('oven.intake_pickup')
  undefined16('oven.intake_pickup'),

  /// Incorrect name has been replaced. Original name: `oven.board`.
  @JsonValue('oven.board')
  undefined17('oven.board'),

  /// Incorrect name has been replaced. Original name: `catalog.manage`.
  @JsonValue('catalog.manage')
  undefined18('catalog.manage'),

  /// Incorrect name has been replaced. Original name: `staff.manage`.
  @JsonValue('staff.manage')
  undefined19('staff.manage'),

  /// Incorrect name has been replaced. Original name: `devices.manage`.
  @JsonValue('devices.manage')
  undefined20('devices.manage'),

  /// Incorrect name has been replaced. Original name: `branches.manage`.
  @JsonValue('branches.manage')
  undefined21('branches.manage'),

  /// Incorrect name has been replaced. Original name: `reports.branch`.
  @JsonValue('reports.branch')
  undefined22('reports.branch'),

  /// Incorrect name has been replaced. Original name: `reports.all`.
  @JsonValue('reports.all')
  undefined23('reports.all'),

  /// Incorrect name has been replaced. Original name: `audit.view`.
  @JsonValue('audit.view')
  undefined24('audit.view'),

  /// Incorrect name has been replaced. Original name: `settings.manage`.
  @JsonValue('settings.manage')
  undefined25('settings.manage'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const PermissionKey(this.json);

  factory PermissionKey.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<PermissionKey> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
