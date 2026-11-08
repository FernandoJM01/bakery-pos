// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/branch_price.dart';
import '../models/branch_price_set.dart';
import '../models/category.dart';
import '../models/category_create.dart';
import '../models/category_update.dart';
import '../models/day_old_rule_set.dart';
import '../models/get_v1_costs_response.dart';
import '../models/get_v1_day_old_rules_response.dart';
import '../models/photo.dart';
import '../models/product.dart';
import '../models/product_create.dart';
import '../models/product_page.dart';
import '../models/product_update.dart';
import '../models/put_v1_day_old_rules_response.dart';
import '../models/tax_rate.dart';
import '../models/tax_rate_create.dart';
import '../models/tax_rate_update.dart';
import '../models/v1_costs_variant_id_request_body.dart';
import '../models/variant.dart';
import '../models/variant_cost.dart';
import '../models/variant_create.dart';
import '../models/variant_update.dart';

part 'catalog_api_client.g.dart';

@RestApi()
abstract class CatalogApiClient {
  factory CatalogApiClient(Dio dio, {String? baseUrl}) = _CatalogApiClient;

  /// Every product with its day-old rule, for managing them together
  @GET('/v1/day-old-rules')
  Future<GetV1DayOldRulesResponse> listDayOldRules();

  /// Sets one day-old rule on many products at once.
  ///
  /// All three fields null removes the rule. The same checks as a product update apply, and each changed.
  /// product writes `catalog.product_updated`. Tills receive the rule through the catalog feed.
  @PUT('/v1/day-old-rules')
  Future<PutV1DayOldRulesResponse> setDayOldRules({
    @Body() required DayOldRuleSet body,
  });

  /// Active variants with price and cost, for branch managers to fill in
  @GET('/v1/costs')
  Future<GetV1CostsResponse> listCosts();

  /// Sets or clears a variant's unit cost; writes `catalog.cost_changed`
  @PUT('/v1/costs/{variantId}')
  Future<VariantCost> setCost({
    @Path('variantId') required String variantId,
    @Body() required V1CostsVariantIdRequestBody body,
  });

  /// List tax rates
  @GET('/v1/tax-rates')
  Future<List<TaxRate>> listTaxRates({
    @Query('includeInactive') bool? includeInactive = false,
  });

  /// Create a tax rate
  @POST('/v1/tax-rates')
  Future<TaxRate> createTaxRate({@Body() required TaxRateCreate body});

  /// Rename or deactivate a tax rate.
  ///
  /// The kind and rate of an existing tax rate never change; create a new rate instead. A rate used by an active product cannot be deactivated (`CONFLICT`).
  @PATCH('/v1/tax-rates/{taxRateId}')
  Future<TaxRate> updateTaxRate({
    @Path('taxRateId') required String taxRateId,
    @Body() required TaxRateUpdate body,
  });

  /// List categories in display order
  @GET('/v1/categories')
  Future<List<Category>> listCategories({
    @Query('includeInactive') bool? includeInactive = false,
  });

  /// Create a category
  @POST('/v1/categories')
  Future<Category> createCategory({@Body() required CategoryCreate body});

  /// Rename, recolor, reorder or deactivate a category
  @PATCH('/v1/categories/{categoryId}')
  Future<Category> updateCategory({
    @Path('categoryId') required String categoryId,
    @Body() required CategoryUpdate body,
  });

  /// Search products with their variants and branch prices.
  ///
  /// [q] - Matches product name, variant name, SKU or barcode (case and accent insensitive).
  @GET('/v1/products')
  Future<ProductPage> listProducts({
    @Query('includeInactive') bool? includeInactive = false,
    @Query('limit') int? limit = 50,
    @Query('q') String? q,
    @Query('categoryId') String? categoryId,
    @Query('cursor') String? cursor,
  });

  /// Create a product together with its variants
  @POST('/v1/products')
  Future<Product> createProduct({@Body() required ProductCreate body});

  /// Get one product with its variants and branch prices
  @GET('/v1/products/{productId}')
  Future<Product> getProduct({@Path('productId') required String productId});

  /// Update product fields (variants have their own routes).
  ///
  /// Send only changed fields; `null` clears a nullable field.
  @PATCH('/v1/products/{productId}')
  Future<Product> updateProduct({
    @Path('productId') required String productId,
    @Body() required ProductUpdate body,
  });

  /// Add a variant to a product
  @POST('/v1/products/{productId}/variants')
  Future<Variant> createVariant({
    @Path('productId') required String productId,
    @Body() required VariantCreate body,
  });

  /// Update a variant, including its base price.
  ///
  /// Deactivating the last active variant of an active product is refused (`CONFLICT`).
  @PATCH('/v1/variants/{variantId}')
  Future<Variant> updateVariant({
    @Path('variantId') required String variantId,
    @Body() required VariantUpdate body,
  });

  /// Set the variant's price in one branch
  @PUT('/v1/variants/{variantId}/branch-prices/{branchId}')
  Future<BranchPrice> setBranchPrice({
    @Path('variantId') required String variantId,
    @Path('branchId') required String branchId,
    @Body() required BranchPriceSet body,
  });

  /// Remove the branch override so the base price applies
  @DELETE('/v1/variants/{variantId}/branch-prices/{branchId}')
  Future<void> removeBranchPrice({
    @Path('variantId') required String variantId,
    @Path('branchId') required String branchId,
  });

  /// Upload a product photo.
  ///
  /// JPEG, PNG or WebP up to 5 MB, checked by content. Stored re-encoded as WebP, at most 800 × 800 px, without metadata.
  @MultiPart()
  @POST('/v1/photos')
  Future<Photo> uploadPhoto({@Part(name: 'file') required File file});

  /// Download a product photo.
  ///
  /// Photo IDs are random and photos are not sensitive, so no token is needed. Sent with `Cache-Control public, max-age=31536000, immutable`.
  @GET('/v1/photos/{photoId}')
  @DioResponseType(ResponseType.stream)
  Stream<String> getPhoto({@Path('photoId') required String photoId});
}
