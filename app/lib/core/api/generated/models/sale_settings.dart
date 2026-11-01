// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'basis_points.dart';

part 'sale_settings.g.dart';

@JsonSerializable()
class SaleSettings {
  const SaleSettings({required this.discountLimitBp});

  factory SaleSettings.fromJson(Map<String, Object?> json) =>
      _$SaleSettingsFromJson(json);

  /// Largest discount share a cashier may give without a manager (`1000` = 10%). M3 brief 4.2 step 7.
  final BasisPoints discountLimitBp;

  Map<String, Object?> toJson() => _$SaleSettingsToJson(this);
}
