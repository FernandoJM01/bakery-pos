// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_changes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogChanges _$CatalogChangesFromJson(Map<String, dynamic> json) =>
    CatalogChanges(
      nextSince: (json['nextSince'] as num).toInt(),
      hasMore: json['hasMore'] as bool,
      serverTime: DateTime.parse(json['serverTime'] as String),
      taxRates: (json['taxRates'] as List<dynamic>)
          .map((e) => TaxRate.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      products: (json['products'] as List<dynamic>)
          .map((e) => CatalogProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      variants: (json['variants'] as List<dynamic>)
          .map((e) => CatalogVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
      branchPrices: (json['branchPrices'] as List<dynamic>)
          .map((e) => CatalogBranchPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CatalogChangesToJson(CatalogChanges instance) =>
    <String, dynamic>{
      'nextSince': instance.nextSince,
      'hasMore': instance.hasMore,
      'serverTime': instance.serverTime.toIso8601String(),
      'taxRates': instance.taxRates,
      'categories': instance.categories,
      'products': instance.products,
      'variants': instance.variants,
      'branchPrices': instance.branchPrices,
    };
