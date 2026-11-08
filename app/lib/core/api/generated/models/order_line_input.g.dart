// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_line_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderLineInput _$OrderLineInputFromJson(Map<String, dynamic> json) =>
    OrderLineInput(
      variantId: json['variantId'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$OrderLineInputToJson(OrderLineInput instance) =>
    <String, dynamic>{
      'variantId': instance.variantId,
      'quantity': instance.quantity,
    };
