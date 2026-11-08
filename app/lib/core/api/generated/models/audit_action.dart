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

  /// Incorrect name has been replaced. Original name: `sale.discount_over_limit`.
  @JsonValue('sale.discount_over_limit')
  undefined26('sale.discount_over_limit'),

  /// Incorrect name has been replaced. Original name: `sale.refunded`.
  @JsonValue('sale.refunded')
  undefined27('sale.refunded'),

  /// Incorrect name has been replaced. Original name: `sale.voided`.
  @JsonValue('sale.voided')
  undefined28('sale.voided'),

  /// Incorrect name has been replaced. Original name: `sale.ticket_discarded`.
  @JsonValue('sale.ticket_discarded')
  undefined29('sale.ticket_discarded'),

  /// Incorrect name has been replaced. Original name: `cash.shift_opened`.
  @JsonValue('cash.shift_opened')
  undefined30('cash.shift_opened'),

  /// Incorrect name has been replaced. Original name: `cash.movement`.
  @JsonValue('cash.movement')
  undefined31('cash.movement'),

  /// Incorrect name has been replaced. Original name: `cash.shift_closed`.
  @JsonValue('cash.shift_closed')
  undefined32('cash.shift_closed'),

  /// Incorrect name has been replaced. Original name: `cash.variance_flagged`.
  @JsonValue('cash.variance_flagged')
  undefined33('cash.variance_flagged'),

  /// Incorrect name has been replaced. Original name: `cash.drawer_opened`.
  @JsonValue('cash.drawer_opened')
  undefined34('cash.drawer_opened'),

  /// Incorrect name has been replaced. Original name: `cash.note_added`.
  @JsonValue('cash.note_added')
  undefined35('cash.note_added'),

  /// Incorrect name has been replaced. Original name: `catalog.cost_changed`.
  @JsonValue('catalog.cost_changed')
  undefined36('catalog.cost_changed'),

  /// Incorrect name has been replaced. Original name: `stock.production_entered`.
  @JsonValue('stock.production_entered')
  undefined37('stock.production_entered'),

  /// Incorrect name has been replaced. Original name: `stock.waste_recorded`.
  @JsonValue('stock.waste_recorded')
  undefined38('stock.waste_recorded'),

  /// Incorrect name has been replaced. Original name: `stock.transfer_sent`.
  @JsonValue('stock.transfer_sent')
  undefined39('stock.transfer_sent'),

  /// Incorrect name has been replaced. Original name: `stock.transfer_received`.
  @JsonValue('stock.transfer_received')
  undefined40('stock.transfer_received'),

  /// Incorrect name has been replaced. Original name: `stock.transfer_mismatch`.
  @JsonValue('stock.transfer_mismatch')
  undefined41('stock.transfer_mismatch'),

  /// Incorrect name has been replaced. Original name: `stock.count_adjusted`.
  @JsonValue('stock.count_adjusted')
  undefined42('stock.count_adjusted'),

  /// Incorrect name has been replaced. Original name: `stock.ledger_mismatch`.
  @JsonValue('stock.ledger_mismatch')
  undefined43('stock.ledger_mismatch'),

  /// Incorrect name has been replaced. Original name: `customer.created`.
  @JsonValue('customer.created')
  undefined44('customer.created'),

  /// Incorrect name has been replaced. Original name: `customer.updated`.
  @JsonValue('customer.updated')
  undefined45('customer.updated'),

  /// Incorrect name has been replaced. Original name: `order.created`.
  @JsonValue('order.created')
  undefined46('order.created'),

  /// Incorrect name has been replaced. Original name: `order.updated`.
  @JsonValue('order.updated')
  undefined47('order.updated'),

  /// Incorrect name has been replaced. Original name: `order.paused`.
  @JsonValue('order.paused')
  undefined48('order.paused'),

  /// Incorrect name has been replaced. Original name: `order.skipped`.
  @JsonValue('order.skipped')
  undefined49('order.skipped'),

  /// Incorrect name has been replaced. Original name: `order.prepaid`.
  @JsonValue('order.prepaid')
  undefined50('order.prepaid'),

  /// Incorrect name has been replaced. Original name: `order.picked_up`.
  @JsonValue('order.picked_up')
  undefined51('order.picked_up'),

  /// Incorrect name has been replaced. Original name: `order.missed`.
  @JsonValue('order.missed')
  undefined52('order.missed'),

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
