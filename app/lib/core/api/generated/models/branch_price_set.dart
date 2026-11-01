// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cents.dart';

part 'branch_price_set.g.dart';

@JsonSerializable()
class BranchPriceSet {
  const BranchPriceSet({required this.priceCents});

  factory BranchPriceSet.fromJson(Map<String, Object?> json) =>
      _$BranchPriceSetFromJson(json);

  final Cents priceCents;

  Map<String, Object?> toJson() => _$BranchPriceSetToJson(this);
}
