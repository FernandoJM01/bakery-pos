// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/branch_stock.dart';
import '../models/get_v1_stock_levels_response.dart';
import '../models/stock_check.dart';
import '../models/stock_event_page.dart';
import '../models/transfer.dart';
import '../models/transfer_create.dart';
import '../models/transfer_page.dart';
import '../models/transfer_receive.dart';
import '../models/transfer_status.dart';
import '../models/waste_page.dart';
import '../models/waste_reason.dart';

part 'stock_api_client.g.dart';

@RestApi()
abstract class StockApiClient {
  factory StockApiClient(Dio dio, {String? baseUrl}) = _StockApiClient;

  /// Open lots of the device's branch, for the till's stock view.
  ///
  /// Lots with units left, plus negative on-hand per variant. The till works out fresh and day-old itself from.
  /// `producedOn`, so ageing at midnight needs no connection (M5 brief 4.3).
  @GET('/v1/stock/lots')
  Future<BranchStock> listBranchLots();

  /// On-hand per variant and branch, for the back office
  @GET('/v1/stock/levels')
  Future<GetV1StockLevelsResponse> listStockLevels({
    @Query('branchId') String? branchId,
  });

  /// The ledger of a variant in a branch, newest first
  @GET('/v1/stock/events')
  Future<StockEventPage> listStockEvents({
    @Query('branchId') required String branchId,
    @Query('variantId') required String variantId,
    @Query('limit') int? limit = 50,
    @Query('cursor') String? cursor,
  });

  /// Waste by date, with its cost
  @GET('/v1/stock/waste')
  Future<WastePage> listWaste({
    @Query('limit') int? limit = 50,
    @Query('from') DateTime? from,
    @Query('to') DateTime? to,
    @Query('branchId') String? branchId,
    @Query('reason') WasteReason? reason,
    @Query('cursor') String? cursor,
  });

  /// Transfers from or to the caller's branches, newest first
  @GET('/v1/stock/transfers')
  Future<TransferPage> listTransfers({
    @Query('limit') int? limit = 50,
    @Query('status') TransferStatus? status,
    @Query('cursor') String? cursor,
  });

  /// Sends stock to another branch, which leaves the sender at once
  @POST('/v1/stock/transfers')
  Future<Transfer> sendTransfer({@Body() required TransferCreate body});

  /// Records what arrived; a difference from what was sent is flagged
  @POST('/v1/stock/transfers/{transferId}/receive')
  Future<Transfer> receiveTransfer({
    @Path('transferId') required String transferId,
    @Body() required TransferReceive body,
  });

  /// The last nightly ledger check
  @GET('/v1/stock/checks/latest')
  Future<StockCheck> latestStockCheck();
}
