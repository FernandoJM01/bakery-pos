// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';

part 'v1_orders_order_id_pause_request_body.g.dart';

@JsonSerializable()
class V1OrdersOrderIdPauseRequestBody {
  const V1OrdersOrderIdPauseRequestBody({required this.from, this.until});

  factory V1OrdersOrderIdPauseRequestBody.fromJson(Map<String, Object?> json) =>
      _$V1OrdersOrderIdPauseRequestBodyFromJson(json);

  final LocalDate from;
  final LocalDate? until;

  Map<String, Object?> toJson() =>
      _$V1OrdersOrderIdPauseRequestBodyToJson(this);
}
