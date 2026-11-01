// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sync_push_result.dart';

part 'sync_push_response.g.dart';

@JsonSerializable()
class SyncPushResponse {
  const SyncPushResponse({required this.results, required this.serverTime});

  factory SyncPushResponse.fromJson(Map<String, Object?> json) =>
      _$SyncPushResponseFromJson(json);

  final List<SyncPushResult> results;
  final DateTime serverTime;

  Map<String, Object?> toJson() => _$SyncPushResponseToJson(this);
}
