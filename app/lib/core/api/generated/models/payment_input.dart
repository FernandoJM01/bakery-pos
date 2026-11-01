// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'any_cents.dart';
import 'payment_method.dart';

part 'payment_input.g.dart';

@JsonSerializable()
class PaymentInput {
  const PaymentInput({
    required this.method,
    required this.amountCents,
    required this.tenderedCents,
    required this.changeCents,
  });

  factory PaymentInput.fromJson(Map<String, Object?> json) =>
      _$PaymentInputFromJson(json);

  final PaymentMethod method;
  final AnyCents amountCents;
  final AnyCents tenderedCents;
  final AnyCents changeCents;

  Map<String, Object?> toJson() => _$PaymentInputToJson(this);
}
