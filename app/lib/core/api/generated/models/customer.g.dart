// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
  id: json['id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String?,
  rfc: json['rfc'] as String?,
  notes: json['notes'] as String?,
  isActive: json['isActive'] as bool,
  balanceCents: (json['balanceCents'] as num).toInt(),
);

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone': ?instance.phone,
  'rfc': ?instance.rfc,
  'notes': ?instance.notes,
  'isActive': instance.isActive,
  'balanceCents': instance.balanceCents,
};
