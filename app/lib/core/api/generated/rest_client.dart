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
import 'shifts/shifts_api_client.dart';
import 'stock/stock_api_client.dart';
import 'catalog/catalog_api_client.dart';
import 'orders/orders_api_client.dart';
import 'reports/reports_api_client.dart';
import 'sync/sync_api_client.dart';
import 'sales/sales_api_client.dart';

/// Bakery POS API `v0.7.0-m7`.
///
/// Contract for Milestones 1 (foundation, access, roles, devices), 2 (catalog and sync), 3 (sales), 4 (cash shifts, audit and printing), 5 (stock and day-old bread), 6 (customers and orders) and 7 (reports).
/// Owned by the architect. Developers must not edit this file; open an issue labelled `contract` instead.
///
/// Conventions:.
/// - IDs are UUID v7 strings.
/// - Timestamps are UTC ISO 8601 (`date-time`).
/// - Every operation declares `x-permission` (a permission key) or `x-public: true`.
///   Operations that need an enrolled till also declare `x-device: required`.
/// - Errors always use the `Error` schema with a stable `code`.
/// - Money is integer centavos with tax included, in fields ending in `Cents`; rates are basis points (`Bp`).
///
class RestClient {
  RestClient(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '0.7.0-m7';

  SystemApiClient? _system;
  DevicesApiClient? _devices;
  AuthApiClient? _auth;
  BranchesApiClient? _branches;
  StaffApiClient? _staff;
  AuditApiClient? _audit;
  ShiftsApiClient? _shifts;
  StockApiClient? _stock;
  CatalogApiClient? _catalog;
  OrdersApiClient? _orders;
  ReportsApiClient? _reports;
  SyncApiClient? _sync;
  SalesApiClient? _sales;

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

  ShiftsApiClient get shifts =>
      _shifts ??= ShiftsApiClient(_dio, baseUrl: _baseUrl);

  StockApiClient get stock =>
      _stock ??= StockApiClient(_dio, baseUrl: _baseUrl);

  CatalogApiClient get catalog =>
      _catalog ??= CatalogApiClient(_dio, baseUrl: _baseUrl);

  OrdersApiClient get orders =>
      _orders ??= OrdersApiClient(_dio, baseUrl: _baseUrl);

  ReportsApiClient get reports =>
      _reports ??= ReportsApiClient(_dio, baseUrl: _baseUrl);

  SyncApiClient get sync => _sync ??= SyncApiClient(_dio, baseUrl: _baseUrl);

  SalesApiClient get sales =>
      _sales ??= SalesApiClient(_dio, baseUrl: _baseUrl);
}
