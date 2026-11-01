// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/sale.dart';
import '../models/sale_page.dart';

part 'sales_api_client.g.dart';

@RestApi()
abstract class SalesApiClient {
  factory SalesApiClient(Dio dio, {String? baseUrl}) = _SalesApiClient;

  /// Sales for the back office, newest first.
  ///
  /// Owners (`reports.all`) see every branch. Staff with only `reports.branch` see their own branches;.
  /// asking for another branch returns 403.
  ///
  /// [from] - Sales that occurred at or after this time.
  ///
  /// [to] - Sales that occurred before this time.
  ///
  /// [folio] - Exact folio, for example `SUC1-02-000153`.
  @GET('/v1/sales')
  Future<SalePage> listSales({
    @Query('limit') int? limit = 50,
    @Query('from') DateTime? from,
    @Query('to') DateTime? to,
    @Query('branchId') String? branchId,
    @Query('deviceId') String? deviceId,
    @Query('folio') String? folio,
    @Query('cursor') String? cursor,
  });

  /// Find a sale of this till's branch by folio, to refund or void it
  @GET('/v1/sales/lookup')
  Future<Sale> lookupSale({@Query('folio') required String folio});

  /// One sale with its lines, discounts, payments and refunds
  @GET('/v1/sales/{saleId}')
  Future<Sale> getSale({@Path('saleId') required String saleId});
}
