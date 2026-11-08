// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'branches.dart';
import 'days.dart';
import 'hours.dart';
import 'local_date.dart';
import 'top_products.dart';

part 'dashboard.g.dart';

@JsonSerializable()
class Dashboard {
  const Dashboard({
    required this.date,
    required this.compareDate,
    required this.netCents,
    required this.saleCount,
    required this.averageTicketCents,
    required this.refundCents,
    required this.compareNetCents,
    required this.compareSaleCount,
    required this.wasteCostCents,
    required this.wasteUnits,
    required this.flaggedShifts,
    required this.prepaidCollectedCents,
    required this.customersOwing,
    required this.hours,
    required this.topProducts,
    required this.days,
    required this.branches,
  });

  factory Dashboard.fromJson(Map<String, Object?> json) =>
      _$DashboardFromJson(json);

  final LocalDate date;
  final LocalDate compareDate;

  /// Sales minus refunds
  final int netCents;
  final int saleCount;
  final int averageTicketCents;
  final int refundCents;
  final int compareNetCents;
  final int compareSaleCount;
  final int wasteCostCents;
  final int wasteUnits;
  final int flaggedShifts;
  final int prepaidCollectedCents;
  final int customersOwing;
  final List<Hours> hours;
  final List<TopProducts> topProducts;

  /// The 14 days ending on `date`, days with sales only
  final List<Days> days;
  final List<Branches> branches;

  Map<String, Object?> toJson() => _$DashboardToJson(this);
}
