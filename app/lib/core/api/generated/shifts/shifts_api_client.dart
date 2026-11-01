// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/shift_detail.dart';
import '../models/shift_page.dart';
import '../models/v1_shifts_shift_id_notes_request_body.dart';

part 'shifts_api_client.g.dart';

@RestApi()
abstract class ShiftsApiClient {
  factory ShiftsApiClient(Dio dio, {String? baseUrl}) = _ShiftsApiClient;

  /// Cash shifts for the back office, newest first.
  ///
  /// Owners (`reports.all`) see every branch. Staff with only `reports.branch` see their own branches;.
  /// asking for another branch returns 403. Shifts are created on tills and arrive through sync.
  ///
  /// [from] - Shifts opened at or after this time.
  ///
  /// [to] - Shifts opened before this time.
  ///
  /// [flagged] - Only shifts with a flagged difference.
  @GET('/v1/shifts')
  Future<ShiftPage> listShifts({
    @Query('limit') int? limit = 50,
    @Query('from') DateTime? from,
    @Query('to') DateTime? to,
    @Query('branchId') String? branchId,
    @Query('deviceId') String? deviceId,
    @Query('flagged') bool? flagged,
    @Query('cursor') String? cursor,
  });

  /// A shift with its counts, movements and Z report.
  ///
  /// A shift of a branch outside the caller's scope reads as 404.
  @GET('/v1/shifts/{shiftId}')
  Future<ShiftDetail> getShift({@Path('shiftId') required String shiftId});

  /// Adds a manager's note to a closed shift.
  ///
  /// Counts never change; a correction is a note beside them. Writes `cash.note_added`.
  @POST('/v1/shifts/{shiftId}/notes')
  Future<ShiftDetail> addShiftNote({
    @Path('shiftId') required String shiftId,
    @Body() required V1ShiftsShiftIdNotesRequestBody body,
  });
}
