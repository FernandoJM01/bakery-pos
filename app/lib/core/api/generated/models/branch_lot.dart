// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';

part 'branch_lot.g.dart';

@JsonSerializable()
class BranchLot {
  const BranchLot({
    required this.id,
    required this.variantId,
    required this.producedOn,
    required this.quantityLeft,
  });

  factory BranchLot.fromJson(Map<String, Object?> json) =>
      _$BranchLotFromJson(json);

  final String id;
  final String variantId;
  final LocalDate producedOn;
  final int quantityLeft;

  Map<String, Object?> toJson() => _$BranchLotToJson(this);
}
