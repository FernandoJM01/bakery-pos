// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'basis_points.dart';
import 'tax_kind.dart';

part 'tax_rate.g.dart';

@JsonSerializable()
class TaxRate {
  const TaxRate({
    required this.id,
    required this.kind,
    required this.name,
    required this.rateBp,
    required this.isActive,
    required this.updatedAt,
  });

  factory TaxRate.fromJson(Map<String, Object?> json) =>
      _$TaxRateFromJson(json);

  final String id;
  final TaxKind kind;
  final String name;
  final BasisPoints rateBp;
  final bool isActive;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$TaxRateToJson(this);
}
