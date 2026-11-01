// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'payment_method.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  const Payment({
    required this.method,
    required this.amountCents,
    required this.tenderedCents,
    required this.changeCents,
  });

  factory Payment.fromJson(Map<String, Object?> json) =>
      _$PaymentFromJson(json);

  final PaymentMethod method;
  final AnyCents amountCents;
  final AnyCents tenderedCents;
  final AnyCents changeCents;

  Map<String, Object?> toJson() => _$PaymentToJson(this);
}
