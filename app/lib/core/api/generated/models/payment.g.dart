// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  method: PaymentMethod.fromJson(json['method'] as String),
  amountCents: (json['amountCents'] as num).toInt(),
  tenderedCents: (json['tenderedCents'] as num).toInt(),
  changeCents: (json['changeCents'] as num).toInt(),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'method': _$PaymentMethodEnumMap[instance.method]!,
  'amountCents': instance.amountCents,
  'tenderedCents': instance.tenderedCents,
  'changeCents': instance.changeCents,
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'CASH',
  PaymentMethod.prepaid: 'PREPAID',
  PaymentMethod.$unknown: r'$unknown',
};
