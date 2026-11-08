// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_prepaid_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderPrepaidPayload _$OrderPrepaidPayloadFromJson(Map<String, dynamic> json) =>
    OrderPrepaidPayload(
      customerId: json['customerId'] as String,
      shiftId: json['shiftId'] as String,
      amountCents: (json['amountCents'] as num).toInt(),
      staffId: json['staffId'] as String,
    );

Map<String, dynamic> _$OrderPrepaidPayloadToJson(
  OrderPrepaidPayload instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'shiftId': instance.shiftId,
  'amountCents': instance.amountCents,
  'staffId': instance.staffId,
};
