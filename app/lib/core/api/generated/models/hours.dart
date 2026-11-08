// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'hours.g.dart';

@JsonSerializable()
class Hours {
  const Hours({
    required this.hour,
    required this.netCents,
    required this.saleCount,
  });

  factory Hours.fromJson(Map<String, Object?> json) => _$HoursFromJson(json);

  final int hour;
  final int netCents;
  final int saleCount;

  Map<String, Object?> toJson() => _$HoursToJson(this);
}
