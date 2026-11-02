// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';

part 'lines3.g.dart';

@JsonSerializable()
class Lines3 {
  const Lines3({
    required this.variantId,
    required this.producedOn,
    required this.quantityReceived,
  });

  factory Lines3.fromJson(Map<String, Object?> json) => _$Lines3FromJson(json);

  final String variantId;
  final LocalDate producedOn;
  final int quantityReceived;

  Map<String, Object?> toJson() => _$Lines3ToJson(this);
}
