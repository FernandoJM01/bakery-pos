// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/audit_action.dart';
import '../models/audit_page.dart';

part 'audit_api_client.g.dart';

@RestApi()
abstract class AuditApiClient {
  factory AuditApiClient(Dio dio, {String? baseUrl}) = _AuditApiClient;

  /// Search the audit log.
  ///
  /// [staffId] - Matches actor or approver.
  @GET('/v1/audit-log')
  Future<AuditPage> listAuditLog({
    @Query('limit') int? limit = 50,
    @Query('from') DateTime? from,
    @Query('to') DateTime? to,
    @Query('branchId') String? branchId,
    @Query('staffId') String? staffId,
    @Query('action') AuditAction? action,
    @Query('cursor') String? cursor,
  });
}
