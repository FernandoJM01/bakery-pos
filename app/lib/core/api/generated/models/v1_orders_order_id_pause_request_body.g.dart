// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v1_orders_order_id_pause_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

V1OrdersOrderIdPauseRequestBody _$V1OrdersOrderIdPauseRequestBodyFromJson(
  Map<String, dynamic> json,
) => V1OrdersOrderIdPauseRequestBody(
  from: json['from'] as LocalDate,
  until: json['until'] as LocalDate?,
);

Map<String, dynamic> _$V1OrdersOrderIdPauseRequestBodyToJson(
  V1OrdersOrderIdPauseRequestBody instance,
) => <String, dynamic>{'from': instance.from, 'until': ?instance.until};
