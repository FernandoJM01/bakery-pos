// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_report_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockReportRow _$StockReportRowFromJson(Map<String, dynamic> json) =>
    StockReportRow(
      branchId: json['branchId'] as String,
      branchName: json['branchName'] as String,
      variantId: json['variantId'] as String,
      productName: json['productName'] as String,
      variantName: json['variantName'] as String,
      produced: (json['produced'] as num).toInt(),
      sold: (json['sold'] as num).toInt(),
      dayOldSold: (json['dayOldSold'] as num).toInt(),
      returned: (json['returned'] as num).toInt(),
      wasted: (json['wasted'] as num).toInt(),
      transferredIn: (json['transferredIn'] as num).toInt(),
      transferredOut: (json['transferredOut'] as num).toInt(),
      adjusted: (json['adjusted'] as num).toInt(),
      onHand: (json['onHand'] as num).toInt(),
      wasteCostCents: (json['wasteCostCents'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StockReportRowToJson(StockReportRow instance) =>
    <String, dynamic>{
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'variantId': instance.variantId,
      'productName': instance.productName,
      'variantName': instance.variantName,
      'produced': instance.produced,
      'sold': instance.sold,
      'dayOldSold': instance.dayOldSold,
      'returned': instance.returned,
      'wasted': instance.wasted,
      'transferredIn': instance.transferredIn,
      'transferredOut': instance.transferredOut,
      'adjusted': instance.adjusted,
      'onHand': instance.onHand,
      'wasteCostCents': ?instance.wasteCostCents,
    };
