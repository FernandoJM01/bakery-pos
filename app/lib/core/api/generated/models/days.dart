// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';

part 'days.g.dart';

@JsonSerializable()
class Days {
  const Days({
    required this.date,
    required this.netCents,
    required this.saleCount,
  });

  factory Days.fromJson(Map<String, Object?> json) => _$DaysFromJson(json);

  final LocalDate date;
  final int netCents;
  final int saleCount;

  Map<String, Object?> toJson() => _$DaysToJson(this);
}
