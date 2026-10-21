// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/pin_set.dart';
import '../models/role.dart';
import '../models/staff.dart';
import '../models/staff_create.dart';
import '../models/staff_update.dart';

part 'staff_api_client.g.dart';

@RestApi()
abstract class StaffApiClient {
  factory StaffApiClient(Dio dio, {String? baseUrl}) = _StaffApiClient;

  /// List staff
  @GET('/v1/staff')
  Future<List<Staff>> listStaff({
    @Query('includeInactive') bool? includeInactive = false,
    @Query('branchId') String? branchId,
    @Query('role') Role? role,
  });

  /// Create a staff member
  @POST('/v1/staff')
  Future<Staff> createStaff({@Body() required StaffCreate body});

  /// Get a staff member
  @GET('/v1/staff/{staffId}')
  Future<Staff> getStaff({@Path('staffId') required String staffId});

  /// Update or deactivate a staff member.
  ///
  /// Setting `isActive` to false revokes all of the staff member's sessions.
  @PATCH('/v1/staff/{staffId}')
  Future<Staff> updateStaff({
    @Path('staffId') required String staffId,
    @Body() required StaffUpdate body,
  });

  /// Set a staff member's PIN.
  ///
  /// Sets a new PIN, clears lockout and revokes the staff member's sessions.
  @PUT('/v1/staff/{staffId}/pin')
  Future<void> setStaffPin({
    @Path('staffId') required String staffId,
    @Body() required PinSet body,
  });
}
