// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'basis_points.dart';
import 'tax_kind.dart';

part 'tax_by_rate.g.dart';

@JsonSerializable()
class TaxByRate {
  const TaxByRate({
    required this.kind,
    required this.rateBp,
    required this.baseCents,
    required this.taxCents,
  });

  factory TaxByRate.fromJson(Map<String, Object?> json) =>
      _$TaxByRateFromJson(json);

  final TaxKind kind;
  final BasisPoints rateBp;

  /// The amount this rate applies to (for IVA, base plus IEPS)
  final AnyCents baseCents;
  final AnyCents taxCents;

  Map<String, Object?> toJson() => _$TaxByRateToJson(this);
}
