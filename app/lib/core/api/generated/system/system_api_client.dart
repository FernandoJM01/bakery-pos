// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/health.dart';

part 'system_api_client.g.dart';

@RestApi()
abstract class SystemApiClient {
  factory SystemApiClient(Dio dio, {String? baseUrl}) = _SystemApiClient;

  /// Liveness and database connectivity
  @GET('/health')
  Future<Health> getHealth();
}
