// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'shortages.g.dart';

@JsonSerializable()
class Shortages {
  const Shortages({required this.variantId, required this.quantity});

  factory Shortages.fromJson(Map<String, Object?> json) =>
      _$ShortagesFromJson(json);

  final String variantId;
  final int quantity;

  Map<String, Object?> toJson() => _$ShortagesToJson(this);
}
