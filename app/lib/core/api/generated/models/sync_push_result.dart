// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sync_result_status.dart';

part 'sync_push_result.g.dart';

@JsonSerializable()
class SyncPushResult {
  const SyncPushResult({
    required this.id,
    required this.status,
    this.errorCode,
    this.message,
  });

  factory SyncPushResult.fromJson(Map<String, Object?> json) =>
      _$SyncPushResultFromJson(json);

  final String id;
  final SyncResultStatus status;

  /// Set when QUARANTINED - `SYNC_UNKNOWN_TYPE`, `SYNC_INVALID_PAYLOAD` or `SYNC_REJECTED`
  final String? errorCode;
  final String? message;

  Map<String, Object?> toJson() => _$SyncPushResultToJson(this);
}
