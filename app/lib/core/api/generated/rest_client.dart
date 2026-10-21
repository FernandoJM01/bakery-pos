// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'system/system_api_client.dart';
import 'devices/devices_api_client.dart';
import 'auth/auth_api_client.dart';
import 'branches/branches_api_client.dart';
import 'staff/staff_api_client.dart';
import 'audit/audit_api_client.dart';

/// Bakery POS API `v0.1.0-m1`.
///
/// Contract for Milestone 1 (foundation, access, roles, devices).
/// Owned by the architect. Developers must not edit this file; open an issue labelled `contract` instead.
///
/// Conventions:.
/// - IDs are UUID v7 strings.
/// - Timestamps are UTC ISO 8601 (`date-time`).
/// - Every operation declares `x-permission` (a permission key) or `x-public: true`.
///   Operations that need an enrolled till also declare `x-device: required`.
/// - Errors always use the `Error` schema with a stable `code`.
///
class RestClient {
  RestClient(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '0.1.0-m1';

  SystemApiClient? _system;
  DevicesApiClient? _devices;
  AuthApiClient? _auth;
  BranchesApiClient? _branches;
  StaffApiClient? _staff;
  AuditApiClient? _audit;

  SystemApiClient get system =>
      _system ??= SystemApiClient(_dio, baseUrl: _baseUrl);

  DevicesApiClient get devices =>
      _devices ??= DevicesApiClient(_dio, baseUrl: _baseUrl);

  AuthApiClient get auth => _auth ??= AuthApiClient(_dio, baseUrl: _baseUrl);

  BranchesApiClient get branches =>
      _branches ??= BranchesApiClient(_dio, baseUrl: _baseUrl);

  StaffApiClient get staff =>
      _staff ??= StaffApiClient(_dio, baseUrl: _baseUrl);

  AuditApiClient get audit =>
      _audit ??= AuditApiClient(_dio, baseUrl: _baseUrl);
}
