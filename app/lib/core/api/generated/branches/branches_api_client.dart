// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/branch.dart';
import '../models/branch_create.dart';
import '../models/branch_update.dart';

part 'branches_api_client.g.dart';

@RestApi()
abstract class BranchesApiClient {
  factory BranchesApiClient(Dio dio, {String? baseUrl}) = _BranchesApiClient;

  /// List branches.
  ///
  /// Owners see all branches; others see the branches they work in.
  @GET('/v1/branches')
  Future<List<Branch>> listBranches();

  /// Create a branch
  @POST('/v1/branches')
  Future<Branch> createBranch({@Body() required BranchCreate body});

  /// Update a branch
  @PATCH('/v1/branches/{branchId}')
  Future<Branch> updateBranch({
    @Path('branchId') required String branchId,
    @Body() required BranchUpdate body,
  });
}
