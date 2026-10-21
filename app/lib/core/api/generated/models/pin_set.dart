// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pin.dart';

part 'pin_set.g.dart';

@JsonSerializable()
class PinSet {
  const PinSet({required this.pin});

  factory PinSet.fromJson(Map<String, Object?> json) => _$PinSetFromJson(json);

  final Pin pin;

  Map<String, Object?> toJson() => _$PinSetToJson(this);
}
