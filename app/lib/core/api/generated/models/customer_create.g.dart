// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerCreate _$CustomerCreateFromJson(Map<String, dynamic> json) =>
    CustomerCreate(
      name: json['name'] as String,
      phone: json['phone'] as String?,
      rfc: json['rfc'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CustomerCreateToJson(CustomerCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': ?instance.phone,
      'rfc': ?instance.rfc,
      'notes': ?instance.notes,
    };
