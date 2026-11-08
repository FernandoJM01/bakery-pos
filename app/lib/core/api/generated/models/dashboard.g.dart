// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dashboard _$DashboardFromJson(Map<String, dynamic> json) => Dashboard(
  date: json['date'] as LocalDate,
  compareDate: json['compareDate'] as LocalDate,
  netCents: (json['netCents'] as num).toInt(),
  saleCount: (json['saleCount'] as num).toInt(),
  averageTicketCents: (json['averageTicketCents'] as num).toInt(),
  refundCents: (json['refundCents'] as num).toInt(),
  compareNetCents: (json['compareNetCents'] as num).toInt(),
  compareSaleCount: (json['compareSaleCount'] as num).toInt(),
  wasteCostCents: (json['wasteCostCents'] as num).toInt(),
  wasteUnits: (json['wasteUnits'] as num).toInt(),
  flaggedShifts: (json['flaggedShifts'] as num).toInt(),
  prepaidCollectedCents: (json['prepaidCollectedCents'] as num).toInt(),
  customersOwing: (json['customersOwing'] as num).toInt(),
  hours: (json['hours'] as List<dynamic>)
      .map((e) => Hours.fromJson(e as Map<String, dynamic>))
      .toList(),
  topProducts: (json['topProducts'] as List<dynamic>)
      .map((e) => TopProducts.fromJson(e as Map<String, dynamic>))
      .toList(),
  days: (json['days'] as List<dynamic>)
      .map((e) => Days.fromJson(e as Map<String, dynamic>))
      .toList(),
  branches: (json['branches'] as List<dynamic>)
      .map((e) => Branches.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DashboardToJson(Dashboard instance) => <String, dynamic>{
  'date': instance.date,
  'compareDate': instance.compareDate,
  'netCents': instance.netCents,
  'saleCount': instance.saleCount,
  'averageTicketCents': instance.averageTicketCents,
  'refundCents': instance.refundCents,
  'compareNetCents': instance.compareNetCents,
  'compareSaleCount': instance.compareSaleCount,
  'wasteCostCents': instance.wasteCostCents,
  'wasteUnits': instance.wasteUnits,
  'flaggedShifts': instance.flaggedShifts,
  'prepaidCollectedCents': instance.prepaidCollectedCents,
  'customersOwing': instance.customersOwing,
  'hours': instance.hours,
  'topProducts': instance.topProducts,
  'days': instance.days,
  'branches': instance.branches,
};
