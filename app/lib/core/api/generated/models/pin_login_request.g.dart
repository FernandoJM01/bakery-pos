// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PinLoginRequest _$PinLoginRequestFromJson(Map<String, dynamic> json) =>
    PinLoginRequest(
      staffId: json['staffId'] as String,
      pin: json['pin'] as Pin,
    );

Map<String, dynamic> _$PinLoginRequestToJson(PinLoginRequest instance) =>
    <String, dynamic>{'staffId': instance.staffId, 'pin': instance.pin};
