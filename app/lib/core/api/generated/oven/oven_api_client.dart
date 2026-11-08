// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_v1_oven_fees_response.dart';
import '../models/local_date.dart';
import '../models/oven_board.dart';
import '../models/oven_fee_rule.dart';
import '../models/oven_fee_rule_create.dart';
import '../models/oven_fee_rule_update.dart';
import '../models/oven_ticket_list.dart';
import '../models/put_v1_oven_branches_branch_id_response.dart';
import '../models/v1_oven_branches_branch_id_request_body.dart';

part 'oven_api_client.g.dart';

@RestApi()
abstract class OvenApiClient {
  factory OvenApiClient(Dio dio, {String? baseUrl}) = _OvenApiClient;

  /// The device's branch: whether the service is on, the fees, and dishes not picked up or picked up today
  @GET('/v1/oven/board')
  Future<OvenBoard> getOvenBoard();

  /// Dish types and what baking each costs
  @GET('/v1/oven/fees')
  Future<GetV1OvenFeesResponse> listOvenFees();

  /// Adds a dish type; its fee is sold as a hidden service product
  @POST('/v1/oven/fees')
  Future<OvenFeeRule> createOvenFee({@Body() required OvenFeeRuleCreate body});

  /// Changes a dish type's name, fee or order, or turns it off
  @PATCH('/v1/oven/fees/{ruleId}')
  Future<OvenFeeRule> updateOvenFee({
    @Path('ruleId') required String ruleId,
    @Body() required OvenFeeRuleUpdate body,
  });

  /// Turns the oven service on or off for a branch (M8.5)
  @PUT('/v1/oven/branches/{branchId}')
  Future<PutV1OvenBranchesBranchIdResponse> setOvenBranch({
    @Path('branchId') required String branchId,
    @Body() required V1OvenBranchesBranchIdRequestBody body,
  });

  /// Dishes by requested day, for the back office (M9.3)
  @GET('/v1/oven/tickets')
  Future<OvenTicketList> listOvenTickets({
    @Query('from') required LocalDate from,
    @Query('to') required LocalDate to,
    @Query('branchId') String? branchId,
  });
}
