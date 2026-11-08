// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'customer_update.g.dart';

@JsonSerializable()
class CustomerUpdate {
  const CustomerUpdate({
    this.name,
    this.phone,
    this.rfc,
    this.notes,
    this.isActive,
  });

  factory CustomerUpdate.fromJson(Map<String, Object?> json) =>
      _$CustomerUpdateFromJson(json);

  final String? name;
  final String? phone;
  final String? rfc;
  final String? notes;
  final bool? isActive;

  Map<String, Object?> toJson() => _$CustomerUpdateToJson(this);
}
