// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerDetail _$CustomerDetailFromJson(Map<String, dynamic> json) =>
    CustomerDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      rfc: json['rfc'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool,
      balanceCents: (json['balanceCents'] as num).toInt(),
      orders: (json['orders'] as List<dynamic>)
          .map((e) => CustomerOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => PrepaidEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CustomerDetailToJson(CustomerDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': ?instance.phone,
      'rfc': ?instance.rfc,
      'notes': ?instance.notes,
      'isActive': instance.isActive,
      'balanceCents': instance.balanceCents,
      'orders': instance.orders,
      'entries': instance.entries,
    };
