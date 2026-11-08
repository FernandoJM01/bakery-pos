// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerUpdate _$CustomerUpdateFromJson(Map<String, dynamic> json) =>
    CustomerUpdate(
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      rfc: json['rfc'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$CustomerUpdateToJson(CustomerUpdate instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'phone': ?instance.phone,
      'rfc': ?instance.rfc,
      'notes': ?instance.notes,
      'isActive': ?instance.isActive,
    };
