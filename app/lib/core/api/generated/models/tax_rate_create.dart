// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'basis_points.dart';
import 'tax_kind.dart';

part 'tax_rate_create.g.dart';

@JsonSerializable()
class TaxRateCreate {
  const TaxRateCreate({
    required this.kind,
    required this.name,
    required this.rateBp,
  });

  factory TaxRateCreate.fromJson(Map<String, Object?> json) =>
      _$TaxRateCreateFromJson(json);

  final TaxKind kind;
  final String name;
  final BasisPoints rateBp;

  Map<String, Object?> toJson() => _$TaxRateCreateToJson(this);
}
