// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Health _$HealthFromJson(Map<String, dynamic> json) => Health(
  status: HealthStatus.fromJson(json['status'] as String),
  database: HealthDatabase.fromJson(json['database'] as String),
  version: json['version'] as String,
);

Map<String, dynamic> _$HealthToJson(Health instance) => <String, dynamic>{
  'status': _$HealthStatusEnumMap[instance.status]!,
  'database': _$HealthDatabaseEnumMap[instance.database]!,
  'version': instance.version,
};

const _$HealthStatusEnumMap = {
  HealthStatus.ok: 'ok',
  HealthStatus.degraded: 'degraded',
  HealthStatus.$unknown: r'$unknown',
};

const _$HealthDatabaseEnumMap = {
  HealthDatabase.ok: 'ok',
  HealthDatabase.unreachable: 'unreachable',
  HealthDatabase.$unknown: r'$unknown',
};
