// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pin.dart';

part 'pin_login_request.g.dart';

@JsonSerializable()
class PinLoginRequest {
  const PinLoginRequest({required this.staffId, required this.pin});

  factory PinLoginRequest.fromJson(Map<String, Object?> json) =>
      _$PinLoginRequestFromJson(json);

  final String staffId;
  final Pin pin;

  Map<String, Object?> toJson() => _$PinLoginRequestToJson(this);
}
