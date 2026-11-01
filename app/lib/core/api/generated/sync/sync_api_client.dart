// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/catalog_changes.dart';
import '../models/quarantine_entry.dart';
import '../models/quarantine_page.dart';
import '../models/quarantine_resolve.dart';
import '../models/status.dart';
import '../models/sync_push_request.dart';
import '../models/sync_push_response.dart';

part 'sync_api_client.g.dart';

@RestApi()
abstract class SyncApiClient {
  factory SyncApiClient(Dio dio, {String? baseUrl}) = _SyncApiClient;

  /// Catalog rows changed after a sequence number, for the device's branch.
  ///
  /// [since] - The `nextSince` of the previous page, or 0 for a full download.
  ///
  /// [limit] - Maximum rows per page, summed over all lists.
  @GET('/v1/sync/catalog')
  Future<CatalogChanges> pullCatalog({
    @Query('since') required int since,
    @Query('limit') int? limit = 500,
  });

  /// Deliver records from the till's outbox.
  ///
  /// Each record is applied in its own transaction, so one bad record never blocks the others.
  /// Records are idempotent by `id`: sending one again returns `DUPLICATE` (or `QUARANTINED` if it was quarantined).
  /// Rate-limited to 60 requests a minute per device.
  @POST('/v1/sync/push')
  Future<SyncPushResponse> pushRecords({@Body() required SyncPushRequest body});

  /// Records the server could not apply
  @GET('/v1/sync/quarantine')
  Future<QuarantinePage> listQuarantine({
    @Query('deviceId') String? deviceId,
    @Query('cursor') String? cursor,
    @Query('status') Status? status = Status.open,
    @Query('limit') int? limit = 50,
  });

  /// Mark a quarantined record as resolved (it is not re-applied)
  @POST('/v1/sync/quarantine/{recordId}/resolve')
  Future<QuarantineEntry> resolveQuarantine({
    @Path('recordId') required String recordId,
    @Body() required QuarantineResolve body,
  });
}
