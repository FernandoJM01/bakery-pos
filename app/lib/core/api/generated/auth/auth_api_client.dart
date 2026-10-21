// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/approval_request.dart';
import '../models/approval_response.dart';
import '../models/login_response.dart';
import '../models/me.dart';
import '../models/password_login_request.dart';
import '../models/pin_login_request.dart';
import '../models/refresh_request.dart';
import '../models/token_pair.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String? baseUrl}) = _AuthApiClient;

  /// Staff PIN login on an enrolled device
  @POST('/v1/auth/pin-login')
  Future<LoginResponse> pinLogin({@Body() required PinLoginRequest body});

  /// Back office login with email and password
  @POST('/v1/auth/password-login')
  Future<LoginResponse> passwordLogin({
    @Body() required PasswordLoginRequest body,
  });

  /// Rotate a refresh token for a new token pair
  @POST('/v1/auth/refresh')
  Future<TokenPair> refreshToken({@Body() required RefreshRequest body});

  /// Revoke the current session
  @POST('/v1/auth/logout')
  Future<void> logout();

  /// A manager approves a sensitive action with their PIN.
  ///
  /// Returns a single-use token valid for 2 minutes. The endpoint that performs the action.
  /// receives it in the `X-Approval-Token` header (used from M3 onwards).
  /// The approver must hold the permission named in `action` and work in the device's branch.
  @POST('/v1/auth/approvals')
  Future<ApprovalResponse> createApproval({
    @Body() required ApprovalRequest body,
  });

  /// Current staff member, branches and permissions
  @GET('/v1/me')
  Future<Me> getMe();
}
