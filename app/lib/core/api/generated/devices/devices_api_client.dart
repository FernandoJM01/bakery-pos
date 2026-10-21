// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/device.dart';
import '../models/device_activate_request.dart';
import '../models/device_activate_response.dart';
import '../models/device_create.dart';
import '../models/device_enrollment.dart';
import '../models/staff_bundle.dart';

part 'devices_api_client.g.dart';

@RestApi()
abstract class DevicesApiClient {
  factory DevicesApiClient(Dio dio, {String? baseUrl}) = _DevicesApiClient;

  /// Exchange a one-time enrollment code for a device token
  @POST('/v1/devices/activate')
  Future<DeviceActivateResponse> activateDevice({
    @Body() required DeviceActivateRequest body,
  });

  /// Active staff of the device's branch, with offline PIN verifiers
  @GET('/v1/devices/me/staff')
  Future<StaffBundle> getDeviceStaffBundle();

  /// List devices
  @GET('/v1/devices')
  Future<List<Device>> listDevices({@Query('branchId') String? branchId});

  /// Register a device and get an enrollment code
  @POST('/v1/devices')
  Future<DeviceEnrollment> createDevice({@Body() required DeviceCreate body});

  /// Issue a new enrollment code.
  ///
  /// Issues a new code for a PENDING device; previous codes stop working.
  @POST('/v1/devices/{deviceId}/enrollment-code')
  Future<DeviceEnrollment> regenerateEnrollmentCode({
    @Path('deviceId') required String deviceId,
  });

  /// Revoke a device
  @POST('/v1/devices/{deviceId}/revoke')
  Future<Device> revokeDevice({@Path('deviceId') required String deviceId});
}
