// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/dashboard.dart';
import '../models/format.dart';
import '../models/local_date.dart';
import '../models/orders_report.dart';
import '../models/sales_group.dart';
import '../models/sales_report.dart';
import '../models/stock_report.dart';

part 'reports_api_client.g.dart';

@RestApi()
abstract class ReportsApiClient {
  factory ReportsApiClient(Dio dio, {String? baseUrl}) = _ReportsApiClient;

  /// The owner's day at a glance, against the same weekday last week.
  ///
  /// Defaults to today at the first branch. Owners (`reports.all`) see every branch; others see their own.
  @GET('/v1/reports/dashboard')
  Future<Dashboard> getDashboard({
    @Query('date') LocalDate? date,
    @Query('branchId') String? branchId,
  });

  /// Sales grouped by day, hour, branch, till, cashier, product or tax rate.
  ///
  /// Days and hours are the branch's own. Sales and refunds count on the day each happened, as on the Z report, so the two agree (M9.1). At most 400 days.
  @GET('/v1/reports/sales')
  Future<SalesReport> getSalesReport({
    @Query('from') required LocalDate from,
    @Query('to') required LocalDate to,
    @Query('groupBy') required SalesGroup groupBy,
    @Query('branchId') String? branchId,
  });

  /// The sales report as CSV or Excel.
  ///
  /// Pesos with two decimals; CSV is UTF-8 with a BOM so Excel reads the accents (M9.4).
  @GET('/v1/reports/sales/export')
  @DioResponseType(ResponseType.stream)
  Stream<String> exportSalesReport({
    @Query('from') required LocalDate from,
    @Query('to') required LocalDate to,
    @Query('groupBy') required SalesGroup groupBy,
    @Query('format') required Format format,
    @Query('branchId') String? branchId,
  });

  /// Per product and branch, what was produced, sold, day-old sold, wasted and left (M9.2)
  @GET('/v1/reports/stock')
  Future<StockReport> getStockReport({
    @Query('from') required LocalDate from,
    @Query('to') required LocalDate to,
    @Query('branchId') String? branchId,
  });

  /// The stock report as CSV or Excel.
  ///
  /// Pesos with two decimals; CSV is UTF-8 with a BOM so Excel reads the accents (M9.4).
  @GET('/v1/reports/stock/export')
  @DioResponseType(ResponseType.stream)
  Stream<String> exportStockReport({
    @Query('from') required LocalDate from,
    @Query('to') required LocalDate to,
    @Query('format') required Format format,
    @Query('branchId') String? branchId,
  });

  /// Order tickets by day and status, and every customer balance (M9.3)
  @GET('/v1/reports/orders')
  Future<OrdersReport> getOrdersReport({
    @Query('from') required LocalDate from,
    @Query('to') required LocalDate to,
    @Query('branchId') String? branchId,
  });

  /// Customer balances as CSV or Excel.
  ///
  /// Pesos with two decimals; CSV is UTF-8 with a BOM so Excel reads the accents (M9.4).
  @GET('/v1/reports/orders/export')
  @DioResponseType(ResponseType.stream)
  Stream<String> exportBalances({
    @Query('from') required LocalDate from,
    @Query('to') required LocalDate to,
    @Query('format') required Format format,
    @Query('branchId') String? branchId,
  });
}
