// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balances.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Balances _$BalancesFromJson(Map<String, dynamic> json) => Balances(
  customerId: json['customerId'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String?,
  balanceCents: (json['balanceCents'] as num).toInt(),
);

Map<String, dynamic> _$BalancesToJson(Balances instance) => <String, dynamic>{
  'customerId': instance.customerId,
  'name': instance.name,
  'phone': ?instance.phone,
  'balanceCents': instance.balanceCents,
};
