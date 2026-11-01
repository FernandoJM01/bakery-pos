// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'tax_rate_update.g.dart';

@JsonSerializable()
class TaxRateUpdate {
  const TaxRateUpdate({this.name, this.isActive});

  factory TaxRateUpdate.fromJson(Map<String, Object?> json) =>
      _$TaxRateUpdateFromJson(json);

  final String? name;
  final bool? isActive;

  Map<String, Object?> toJson() => _$TaxRateUpdateToJson(this);
}
