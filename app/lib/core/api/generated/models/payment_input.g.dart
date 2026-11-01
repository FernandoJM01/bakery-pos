// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentInput _$PaymentInputFromJson(Map<String, dynamic> json) => PaymentInput(
  method: PaymentMethod.fromJson(json['method'] as String),
  amountCents: (json['amountCents'] as num).toInt(),
  tenderedCents: (json['tenderedCents'] as num).toInt(),
  changeCents: (json['changeCents'] as num).toInt(),
);

Map<String, dynamic> _$PaymentInputToJson(PaymentInput instance) =>
    <String, dynamic>{
      'method': _$PaymentMethodEnumMap[instance.method]!,
      'amountCents': instance.amountCents,
      'tenderedCents': instance.tenderedCents,
      'changeCents': instance.changeCents,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'CASH',
  PaymentMethod.$unknown: r'$unknown',
};
