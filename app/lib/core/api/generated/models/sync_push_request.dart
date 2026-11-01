// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sync_record.dart';

part 'sync_push_request.g.dart';

@JsonSerializable()
class SyncPushRequest {
  const SyncPushRequest({required this.records});

  factory SyncPushRequest.fromJson(Map<String, Object?> json) =>
      _$SyncPushRequestFromJson(json);

  final List<SyncRecord> records;

  Map<String, Object?> toJson() => _$SyncPushRequestToJson(this);
}
