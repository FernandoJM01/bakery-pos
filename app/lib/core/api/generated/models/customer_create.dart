// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'customer_create.g.dart';

@JsonSerializable()
class CustomerCreate {
  const CustomerCreate({required this.name, this.phone, this.rfc, this.notes});

  factory CustomerCreate.fromJson(Map<String, Object?> json) =>
      _$CustomerCreateFromJson(json);

  final String name;
  final String? phone;
  final String? rfc;
  final String? notes;

  Map<String, Object?> toJson() => _$CustomerCreateToJson(this);
}
