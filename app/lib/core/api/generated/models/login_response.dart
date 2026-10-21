// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'me.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.me,
  });

  factory LoginResponse.fromJson(Map<String, Object?> json) =>
      _$LoginResponseFromJson(json);

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;

  /// Till sessions end at 04:00 branch local time the next day; back office sessions after 12 hours.
  final DateTime refreshTokenExpiresAt;
  final Me me;

  Map<String, Object?> toJson() => _$LoginResponseToJson(this);
}
