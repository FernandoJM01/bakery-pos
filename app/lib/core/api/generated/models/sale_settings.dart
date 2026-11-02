// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'basis_points.dart';

part 'sale_settings.g.dart';

@JsonSerializable()
class SaleSettings {
  const SaleSettings({
    required this.discountLimitBp,
    required this.cashVarianceFlagCents,
  });

  factory SaleSettings.fromJson(Map<String, Object?> json) =>
      _$SaleSettingsFromJson(json);

  /// Largest discount share a cashier may give without a manager (`1000` = 10%). M3 brief 4.2 step 7.
  final BasisPoints discountLimitBp;

  /// A close whose difference passes this amount, in either direction, is flagged (`5000` = $50.00). M4 brief section 2.
  final AnyCents cashVarianceFlagCents;

  Map<String, Object?> toJson() => _$SaleSettingsToJson(this);
}
